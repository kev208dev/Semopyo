#!/usr/bin/env node
/* Architecture structural analyzer. */
const fs = require('fs');
const path = require('path');

function main() {
  const [, , inputPath, outputPath] = process.argv;
  if (!inputPath || !outputPath) {
    console.error('Usage: ua-arch-analyze.js <input.json> <output.json>');
    process.exit(1);
  }
  const raw = fs.readFileSync(inputPath, 'utf8');
  const data = JSON.parse(raw);

  const fileNodes = data.fileNodes || [];
  // Support both `importEdges` and `imports` keys.
  const importEdges = data.importEdges || data.imports || [];
  const allEdges = data.allEdges || importEdges;

  // Build map: id -> node
  const nodeById = new Map();
  for (const n of fileNodes) nodeById.set(n.id, n);

  // === A. Common prefix for filePaths ===
  function commonPrefix(paths) {
    if (paths.length === 0) return '';
    // Get common directory prefix using path segments
    const split = paths.map((p) => p.split('/'));
    const min = Math.min(...split.map((s) => s.length));
    const out = [];
    for (let i = 0; i < min; i++) {
      const seg = split[0][i];
      if (split.every((s) => s[i] === seg)) {
        // Only count as common prefix if all paths have more segments after (i.e. it's a directory)
        if (split.every((s) => s.length > i + 1)) {
          out.push(seg);
        } else break;
      } else break;
    }
    return out.length ? out.join('/') + '/' : '';
  }

  const filePaths = fileNodes.map((n) => n.filePath || '');
  const prefix = commonPrefix(filePaths);

  // === A. Directory grouping ===
  const directoryGroups = {};
  for (const n of fileNodes) {
    const fp = n.filePath || '';
    let rel = fp.startsWith(prefix) ? fp.slice(prefix.length) : fp;
    const segs = rel.split('/');
    let group;
    if (segs.length > 1) {
      group = segs[0];
    } else {
      // Single segment - file at root of prefix
      group = '(root)';
    }
    if (!directoryGroups[group]) directoryGroups[group] = [];
    directoryGroups[group].push(n.id);
  }

  // === B. Node type grouping ===
  const nodeTypeGroups = {};
  for (const n of fileNodes) {
    const t = n.type || 'file';
    if (!nodeTypeGroups[t]) nodeTypeGroups[t] = [];
    nodeTypeGroups[t].push(n.id);
  }

  // === C. Import adjacency + fan-in/out ===
  const fanIn = {};
  const fanOut = {};
  for (const n of fileNodes) {
    fanIn[n.id] = 0;
    fanOut[n.id] = 0;
  }
  for (const e of importEdges) {
    if (fanOut[e.source] !== undefined) fanOut[e.source]++;
    if (fanIn[e.target] !== undefined) fanIn[e.target]++;
  }

  // id -> group
  const idToGroup = {};
  for (const [g, ids] of Object.entries(directoryGroups)) {
    for (const id of ids) idToGroup[id] = g;
  }

  // === D. Cross-category edges by type ===
  const crossCounts = {};
  for (const e of allEdges) {
    const src = nodeById.get(e.source);
    const tgt = nodeById.get(e.target);
    if (!src || !tgt) continue;
    if (src.type === tgt.type) continue;
    const key = `${src.type}|${tgt.type}|${e.type}`;
    crossCounts[key] = (crossCounts[key] || 0) + 1;
  }
  const crossCategoryEdges = Object.entries(crossCounts).map(([k, count]) => {
    const [fromType, toType, edgeType] = k.split('|');
    return { fromType, toType, edgeType, count };
  });

  // === E. Inter-group import frequency ===
  const interGroupMap = {};
  for (const e of importEdges) {
    const sg = idToGroup[e.source];
    const tg = idToGroup[e.target];
    if (!sg || !tg || sg === tg) continue;
    const key = `${sg}|${tg}`;
    interGroupMap[key] = (interGroupMap[key] || 0) + 1;
  }
  const interGroupImports = Object.entries(interGroupMap).map(([k, count]) => {
    const [from, to] = k.split('|');
    return { from, to, count };
  });

  // === F. Intra-group density ===
  const intraGroupDensity = {};
  for (const g of Object.keys(directoryGroups)) {
    let internal = 0;
    let total = 0;
    for (const e of importEdges) {
      const sg = idToGroup[e.source];
      const tg = idToGroup[e.target];
      if (sg === g || tg === g) total++;
      if (sg === g && tg === g) internal++;
    }
    intraGroupDensity[g] = {
      internalEdges: internal,
      totalEdges: total,
      density: total > 0 ? internal / total : 0,
    };
  }

  // === G. Pattern matching ===
  const dirPatterns = {
    routes: 'api', api: 'api', controllers: 'api', endpoints: 'api', handlers: 'api',
    services: 'service', core: 'service', lib: 'service', domain: 'service', logic: 'service',
    models: 'data', db: 'data', data: 'data', persistence: 'data', repository: 'data', entities: 'data',
    components: 'ui', views: 'ui', pages: 'ui', ui: 'ui', layouts: 'ui', screens: 'ui',
    middleware: 'middleware', plugins: 'middleware', interceptors: 'middleware', guards: 'middleware',
    utils: 'utility', helpers: 'utility', common: 'utility', shared: 'utility', tools: 'utility',
    config: 'config', constants: 'config', env: 'config', settings: 'config',
    __tests__: 'test', test: 'test', tests: 'test', spec: 'test', specs: 'test',
    types: 'types', interfaces: 'types', schemas: 'types', contracts: 'types', dtos: 'types',
    hooks: 'hooks',
    store: 'state', state: 'state', reducers: 'state', actions: 'state', slices: 'state',
    assets: 'assets', static: 'assets', public: 'assets',
    migrations: 'data',
    management: 'config', commands: 'config',
    templatetags: 'utility',
    signals: 'service',
    serializers: 'api',
    cmd: 'entry',
    internal: 'service',
    pkg: 'utility',
    dto: 'types', request: 'types', response: 'types',
    entity: 'data',
    controller: 'api',
    routers: 'api',
    composables: 'service',
    blueprints: 'api',
    mailers: 'service', jobs: 'service', channels: 'service',
    bin: 'entry',
    docs: 'documentation', documentation: 'documentation', wiki: 'documentation',
    deploy: 'infrastructure', deployment: 'infrastructure', infra: 'infrastructure', infrastructure: 'infrastructure',
    '.github': 'ci-cd', '.gitlab': 'ci-cd', '.circleci': 'ci-cd',
    k8s: 'infrastructure', kubernetes: 'infrastructure', helm: 'infrastructure', charts: 'infrastructure',
    terraform: 'infrastructure', tf: 'infrastructure',
    docker: 'infrastructure',
    sql: 'data', database: 'data', schema: 'data',
    scripts: 'utility',
  };
  const patternMatches = {};
  for (const g of Object.keys(directoryGroups)) {
    patternMatches[g] = dirPatterns[g] || null;
  }

  // === H. Deployment topology ===
  const infraFiles = [];
  let hasDockerfile = false, hasCompose = false, hasK8s = false, hasTerraform = false, hasCI = false;
  for (const n of fileNodes) {
    const fp = (n.filePath || '').toLowerCase();
    const name = (n.name || '').toLowerCase();
    if (name === 'dockerfile' || name.startsWith('dockerfile.')) { hasDockerfile = true; infraFiles.push(n.filePath); }
    if (name.startsWith('docker-compose')) { hasCompose = true; infraFiles.push(n.filePath); }
    if (fp.includes('k8s/') || fp.includes('kubernetes/') || fp.includes('helm/')) { hasK8s = true; infraFiles.push(n.filePath); }
    if (fp.endsWith('.tf') || fp.endsWith('.tfvars')) { hasTerraform = true; infraFiles.push(n.filePath); }
    if (fp.includes('.github/workflows/') || fp.includes('.gitlab-ci.yml') || name === 'jenkinsfile') { hasCI = true; infraFiles.push(n.filePath); }
  }

  // === I. Data pipeline detection ===
  const schemaFiles = [];
  const migrationFiles = [];
  const dataModelFiles = [];
  const apiHandlerFiles = [];
  for (const n of fileNodes) {
    const fp = n.filePath || '';
    const tags = n.tags || [];
    if (fp.endsWith('.sql') || fp.endsWith('.graphql') || fp.endsWith('.proto') || fp.endsWith('.gql')) {
      schemaFiles.push(fp);
    }
    if (fp.includes('/migrations/')) migrationFiles.push(fp);
    if (tags.includes('data-model') || tags.includes('orm-model')) dataModelFiles.push(fp);
    if (tags.includes('api-handler') || tags.includes('route-handler')) apiHandlerFiles.push(fp);
  }

  // === J. Documentation coverage ===
  const docByGroup = {};
  for (const n of fileNodes) {
    if (n.type !== 'document') continue;
    const g = idToGroup[n.id];
    if (g) docByGroup[g] = (docByGroup[g] || 0) + 1;
  }
  const totalGroups = Object.keys(directoryGroups).length;
  const groupsWithDocs = Object.keys(docByGroup).length;
  const undocumentedGroups = Object.keys(directoryGroups).filter((g) => !docByGroup[g]);

  // === K. Dependency direction ===
  const pairCounts = {};
  for (const { from, to, count } of interGroupImports) {
    pairCounts[`${from}|${to}`] = count;
  }
  const seen = new Set();
  const dependencyDirection = [];
  for (const { from, to } of interGroupImports) {
    const key = [from, to].sort().join('|');
    if (seen.has(key)) continue;
    seen.add(key);
    const fwd = pairCounts[`${from}|${to}`] || 0;
    const bwd = pairCounts[`${to}|${from}`] || 0;
    if (fwd >= bwd) dependencyDirection.push({ dependent: from, dependsOn: to });
    else dependencyDirection.push({ dependent: to, dependsOn: from });
  }

  // === File stats ===
  const filesPerGroup = {};
  for (const [g, ids] of Object.entries(directoryGroups)) filesPerGroup[g] = ids.length;
  const nodeTypeCounts = {};
  for (const [t, ids] of Object.entries(nodeTypeGroups)) nodeTypeCounts[t] = ids.length;

  const result = {
    scriptCompleted: true,
    commonPrefix: prefix,
    directoryGroups,
    nodeTypeGroups,
    crossCategoryEdges,
    interGroupImports,
    intraGroupDensity,
    patternMatches,
    deploymentTopology: {
      hasDockerfile, hasCompose, hasK8s, hasTerraform, hasCI,
      infraFiles,
    },
    dataPipeline: {
      schemaFiles, migrationFiles, dataModelFiles, apiHandlerFiles,
    },
    docCoverage: {
      groupsWithDocs,
      totalGroups,
      coverageRatio: totalGroups > 0 ? groupsWithDocs / totalGroups : 0,
      undocumentedGroups,
    },
    dependencyDirection,
    fileStats: {
      totalFileNodes: fileNodes.length,
      filesPerGroup,
      nodeTypeCounts,
    },
    fileFanIn: fanIn,
    fileFanOut: fanOut,
  };

  fs.writeFileSync(outputPath, JSON.stringify(result, null, 2));
}

try { main(); } catch (e) {
  console.error('Fatal error:', e.message);
  console.error(e.stack);
  process.exit(1);
}
