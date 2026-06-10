#!/usr/bin/env node
'use strict';

const fs = require('fs');

function main() {
  const inputPath = process.argv[2];
  const outputPath = process.argv[3];
  if (!inputPath || !outputPath) {
    console.error('Usage: node ua-tour-analyze.js <input.json> <output.json>');
    process.exit(1);
  }

  const raw = fs.readFileSync(inputPath, 'utf8');
  const data = JSON.parse(raw);
  const nodes = data.nodes || [];
  const edges = data.edges || [];
  const layers = data.layers || [];

  // Index by id
  const nodeById = new Map();
  for (const n of nodes) nodeById.set(n.id, n);

  // Build adjacency (forward / reverse / by type)
  const outAdj = new Map();
  const inAdj = new Map();
  const outByType = new Map();
  const inByType = new Map();
  for (const n of nodes) {
    outAdj.set(n.id, []);
    inAdj.set(n.id, []);
  }
  for (const e of edges) {
    if (!nodeById.has(e.source) || !nodeById.has(e.target)) continue;
    outAdj.get(e.source).push(e);
    inAdj.get(e.target).push(e);
    if (!outByType.has(e.source)) outByType.set(e.source, new Map());
    if (!inByType.has(e.target)) inByType.set(e.target, new Map());
    const ot = outByType.get(e.source);
    ot.set(e.type, (ot.get(e.type) || 0) + 1);
    const it = inByType.get(e.target);
    it.set(e.type, (it.get(e.type) || 0) + 1);
  }

  // Fan-in / Fan-out ranking
  const fanInRanking = nodes
    .map((n) => ({ id: n.id, name: n.name, fanIn: inAdj.get(n.id).length }))
    .sort((a, b) => b.fanIn - a.fanIn)
    .slice(0, 20);
  const fanOutRanking = nodes
    .map((n) => ({ id: n.id, name: n.name, fanOut: outAdj.get(n.id).length }))
    .sort((a, b) => b.fanOut - a.fanOut)
    .slice(0, 20);

  // Compute thresholds for entry-point scoring
  const fanOutVals = nodes.map((n) => outAdj.get(n.id).length).sort((a, b) => b - a);
  const fanInVals = nodes.map((n) => inAdj.get(n.id).length).sort((a, b) => a - b);
  const top10FanOutThreshold = fanOutVals[Math.max(0, Math.floor(fanOutVals.length * 0.1) - 1)] || 0;
  const bottom25FanInThreshold = fanInVals[Math.max(0, Math.floor(fanInVals.length * 0.25) - 1)] || 0;

  const codeEntryNames = new Set([
    'index.ts','index.js','main.ts','main.js','app.ts','app.js','server.ts','server.js',
    'mod.rs','main.go','main.py','main.rs','manage.py','app.py','wsgi.py','asgi.py',
    'run.py','__main__.py','Application.java','Main.java','Program.cs','config.ru',
    'index.php','App.swift','Application.kt','main.cpp','main.c','main.dart','app.dart',
  ]);

  function entryScore(n) {
    let score = 0;
    const name = n.name || '';
    const path = n.filePath || '';
    const depth = path ? path.split('/').length : 99;
    if (n.type === 'document') {
      if (path === 'README.md') score += 5;
      else if (depth === 1 && /\.md$/i.test(name)) score += 2;
      return score;
    }
    if (codeEntryNames.has(name)) score += 3;
    if (depth <= 2) score += 1;
    if ((outAdj.get(n.id).length) >= top10FanOutThreshold && top10FanOutThreshold > 0) score += 1;
    if ((inAdj.get(n.id).length) <= bottom25FanInThreshold) score += 1;
    return score;
  }

  const entryPointCandidates = nodes
    .map((n) => ({ id: n.id, name: n.name, score: entryScore(n), summary: n.summary || '' }))
    .filter((x) => x.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, 5);

  // BFS from top code entry candidate
  const codeCandidates = nodes
    .map((n) => ({ id: n.id, score: entryScore(n), type: n.type }))
    .filter((x) => x.type !== 'document' && x.score > 0)
    .sort((a, b) => b.score - a.score);
  const startNode = codeCandidates.length > 0 ? codeCandidates[0].id : (entryPointCandidates[0] ? entryPointCandidates[0].id : null);

  const bfsOrder = [];
  const depthMap = {};
  if (startNode) {
    const visited = new Set();
    const queue = [{ id: startNode, depth: 0 }];
    visited.add(startNode);
    while (queue.length > 0) {
      const { id, depth } = queue.shift();
      bfsOrder.push(id);
      depthMap[id] = depth;
      const out = outAdj.get(id) || [];
      for (const e of out) {
        if (e.type !== 'imports' && e.type !== 'calls') continue;
        if (!visited.has(e.target) && nodeById.has(e.target)) {
          visited.add(e.target);
          queue.push({ id: e.target, depth: depth + 1 });
        }
      }
    }
  }
  const byDepth = {};
  for (const [id, d] of Object.entries(depthMap)) {
    if (!byDepth[d]) byDepth[d] = [];
    byDepth[d].push(id);
  }

  // Non-code inventory
  const nonCodeFiles = { documentation: [], infrastructure: [], data: [], config: [] };
  const docTypes = new Set(['document']);
  const infraTypes = new Set(['service', 'pipeline', 'resource']);
  const dataTypes = new Set(['table', 'schema', 'endpoint']);
  const configTypes = new Set(['config']);
  for (const n of nodes) {
    const entry = { id: n.id, name: n.name, summary: n.summary || '' };
    if (docTypes.has(n.type)) nonCodeFiles.documentation.push(entry);
    else if (infraTypes.has(n.type)) nonCodeFiles.infrastructure.push(entry);
    else if (dataTypes.has(n.type)) nonCodeFiles.data.push(entry);
    else if (configTypes.has(n.type)) nonCodeFiles.config.push(entry);
  }

  // Clusters: nodes with bidirectional relationships, expanded by 2+ links
  const pairKey = (a, b) => a < b ? `${a}||${b}` : `${b}||${a}`;
  const bidirPairs = new Set();
  const edgeIndex = new Map();
  for (const e of edges) {
    const key = `${e.source}->${e.target}:${e.type}`;
    edgeIndex.set(key, true);
  }
  for (const e of edges) {
    const reverse = `${e.target}->${e.source}:${e.type}`;
    if (edgeIndex.has(reverse) && e.source !== e.target) {
      bidirPairs.add(pairKey(e.source, e.target));
    }
  }

  // Build undirected adjacency for cluster expansion
  const undirected = new Map();
  for (const n of nodes) undirected.set(n.id, new Set());
  for (const e of edges) {
    if (e.source === e.target) continue;
    if (!nodeById.has(e.source) || !nodeById.has(e.target)) continue;
    undirected.get(e.source).add(e.target);
    undirected.get(e.target).add(e.source);
  }

  const seenClusterNodes = new Set();
  const clusters = [];
  for (const pair of bidirPairs) {
    const [a, b] = pair.split('||');
    if (seenClusterNodes.has(a) && seenClusterNodes.has(b)) continue;
    const cluster = new Set([a, b]);
    // Expand: add nodes connected to 2+ existing cluster members
    let changed = true;
    while (changed && cluster.size < 5) {
      changed = false;
      const candidates = new Map();
      for (const m of cluster) {
        for (const nb of undirected.get(m) || []) {
          if (cluster.has(nb)) continue;
          candidates.set(nb, (candidates.get(nb) || 0) + 1);
        }
      }
      for (const [cand, cnt] of candidates) {
        if (cnt >= 2 && cluster.size < 5) {
          cluster.add(cand);
          changed = true;
        }
      }
    }
    // Count edges between cluster members
    let edgeCount = 0;
    const arr = Array.from(cluster);
    for (let i = 0; i < arr.length; i++) {
      for (let j = 0; j < arr.length; j++) {
        if (i === j) continue;
        if ((undirected.get(arr[i]) || new Set()).has(arr[j])) edgeCount++;
      }
    }
    clusters.push({ nodes: arr, edgeCount: edgeCount / 2 });
    for (const m of cluster) seenClusterNodes.add(m);
  }
  clusters.sort((a, b) => b.edgeCount - a.edgeCount);
  const topClusters = clusters.slice(0, 10);

  // Layer list
  const layerInfo = {
    count: layers.length,
    list: layers.map((l) => ({ id: l.id, name: l.name, description: l.description || '' })),
  };

  // Node summary index
  const nodeSummaryIndex = {};
  for (const n of nodes) {
    nodeSummaryIndex[n.id] = { name: n.name, type: n.type, summary: n.summary || '' };
  }

  const out = {
    scriptCompleted: true,
    entryPointCandidates,
    fanInRanking,
    fanOutRanking,
    bfsTraversal: { startNode, order: bfsOrder, depthMap, byDepth },
    nonCodeFiles,
    clusters: topClusters,
    layers: layerInfo,
    nodeSummaryIndex,
    totalNodes: nodes.length,
    totalEdges: edges.length,
  };

  fs.writeFileSync(outputPath, JSON.stringify(out, null, 2));
  process.exit(0);
}

try {
  main();
} catch (err) {
  console.error('Script failed:', err && err.stack ? err.stack : err);
  process.exit(1);
}
