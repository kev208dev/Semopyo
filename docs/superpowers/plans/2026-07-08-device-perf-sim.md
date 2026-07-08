# 전자기기 성능 비교 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 홈 화면에 "전자기기 성능 비교" 진입점을 추가해, 폰/태블릿/워치/데스크탑/노트북 5개 기기 종류를 고르고 부품·스펙을 배치해 예상 성능을 시뮬레이션 + 견적 A/B 비교할 수 있는 프레임(구조 + 자리표시자 데이터)을 만든다.

**Architecture:** 공통 엔진(`device_sim_data.dart`: 슬롯/부품/축/지표/시뮬레이션 로직 + 카테고리별 정의)과 카테고리별 시각 위젯(`device_shapes.dart`: 실제 기기 모양 + 슬롯 배지 + 완성 시 연출)을 분리하고, 진입 화면(`device_category_page.dart`)과 빌더 화면(`device_builder_page.dart`)이 이 둘을 조합한다. 기존 `pc_builder_data.dart`/`pc_builder_page.dart`는 이 구조로 흡수되어 삭제된다.

**Tech Stack:** Flutter/Dart. 외부 패키지 추가 없음(`AnimationController`, `CustomPainter`, `Stack`/`Positioned`만 사용).

**참고 문서:** `docs/superpowers/specs/2026-07-08-device-perf-sim-design.md`

**테스트 방침(스펙에서 확정):** 이 저장소의 다른 도메인 페이지들(피자/신발/음료 등)과 동일하게 자동화 테스트는 만들지 않는다. 각 태스크는 `flutter analyze`로 정적 검증하고, 마지막 태스크에서 앱을 실제로 띄워 수동으로 확인한다.

---

## Task 1: 공통 시뮬레이션 엔진 + 카테고리 정의

**Files:**
- Create: `lib/device_sim_data.dart`

- [ ] **Step 1: 파일 작성**

```dart
/// 전자기기 성능 비교 — 공통 시뮬레이션 엔진 + 기기별 정의.
///
/// 프레임 단계: 샘플 부품/자리표시자 가중치만 있고 실데이터는 없다.
/// TODO: data/pc_parts/*.csv 등 실데이터 연결, simulate()를 벤치마크 기반으로 교체.
library;

enum DeviceCategory { phone, tablet, watch, desktop, laptop }

extension DeviceCategoryInfo on DeviceCategory {
  String get label => switch (this) {
        DeviceCategory.phone => '폰',
        DeviceCategory.tablet => '태블릿',
        DeviceCategory.watch => '워치',
        DeviceCategory.desktop => '데스크탑',
        DeviceCategory.laptop => '노트북',
      };

  String get emoji => switch (this) {
        DeviceCategory.phone => '📱',
        DeviceCategory.tablet => '🗒️',
        DeviceCategory.watch => '⌚',
        DeviceCategory.desktop => '🖥️',
        DeviceCategory.laptop => '💻',
      };
}

/// 기기 하나의 부품/스펙 슬롯 (예: CPU, 배터리, 디스플레이).
class DeviceSlot {
  final String id;
  final String label;
  final String emoji;
  const DeviceSlot({required this.id, required this.label, required this.emoji});
}

/// 슬롯에 들어갈 수 있는 부품/스펙 선택지.
class DevicePart {
  final String id;
  final String slotId;
  final String name;

  /// 0~100 상대 성능 점수. 샘플 값 — 실데이터 교체 대상.
  final int perfScore;

  /// 부가 지표 (statId -> 값). 예: {'watt': 125}, {'battery_mah': 4500}.
  /// 이 슬롯이 그 지표와 무관하면 비워둔다.
  final Map<String, int> stats;

  /// 참고 가격(원). 샘플 값.
  final int price;

  const DevicePart({
    required this.id,
    required this.slotId,
    required this.name,
    required this.perfScore,
    required this.stats,
    required this.price,
  });
}

/// 성능 축 하나 (예: 게임 성능). 슬롯별 가중치의 가중합으로 계산한다.
class ScoreAxis {
  final String id;
  final String label;
  final Map<String, double> weights; // slotId -> weight
  const ScoreAxis({required this.id, required this.label, required this.weights});
}

/// 점수 외에 보여줄 보조 지표 정의 (예: 예상 전력, 배터리 용량).
class StatDef {
  final String id;
  final String label;
  final String unit;
  const StatDef({required this.id, required this.label, required this.unit});
}

/// 기기 카테고리 하나의 전체 정의: 슬롯 구성 + 성능 축 + 보조 지표 + 병목 규칙 + 샘플 부품.
class DeviceCategoryDef {
  final DeviceCategory category;
  final List<DeviceSlot> slots;
  final List<ScoreAxis> axes;
  final List<StatDef> stats;

  /// 병목 문구를 반환하는 함수. 해당 없으면 null.
  final String? Function(DeviceBuild build)? bottleneck;
  final List<DevicePart> sampleParts;

  DeviceCategoryDef({
    required this.category,
    required this.slots,
    required this.axes,
    required this.stats,
    this.bottleneck,
    required this.sampleParts,
  });

  String get label => category.label;
  String get emoji => category.emoji;

  List<DevicePart> partsOf(String slotId) =>
      sampleParts.where((p) => p.slotId == slotId).toList();
}

/// 한 견적(빌드): 슬롯별로 부품 하나씩.
class DeviceBuild {
  final DeviceCategoryDef def;
  final Map<String, DevicePart?> slots;

  DeviceBuild(this.def) : slots = {for (final s in def.slots) s.id: null};

  int get pickedCount => slots.values.whereType<DevicePart>().length;
  bool get isEmpty => pickedCount == 0;
  bool get isComplete => pickedCount == def.slots.length;

  DevicePart? operator [](String slotId) => slots[slotId];
  void operator []=(String slotId, DevicePart? p) => slots[slotId] = p;
}

/// 시뮬레이션 결과.
class SimResult {
  final Map<String, int> axisScores; // axisId -> 0~100
  final Map<String, int> statTotals; // statId -> 합산값
  final int totalPrice;
  final String? bottleneck;

  const SimResult({
    required this.axisScores,
    required this.statTotals,
    required this.totalPrice,
    this.bottleneck,
  });

  static SimResult empty(DeviceCategoryDef def) => SimResult(
        axisScores: {for (final a in def.axes) a.id: 0},
        statTotals: {for (final s in def.stats) s.id: 0},
        totalPrice: 0,
      );
}

/// 자리표시자 시뮬레이션.
///
/// 슬롯별 perfScore를 축(axis)별 가중치로 합산하는 단순 모델.
/// TODO: 실제 벤치마크(게임 fps, 렌더링 시간, 배터리 실측 등) 기반 모델로 교체.
SimResult simulate(DeviceBuild build) {
  final def = build.def;
  if (build.isEmpty) return SimResult.empty(def);

  int scoreOf(String slotId) => build[slotId]?.perfScore ?? 0;

  final axisScores = <String, int>{};
  for (final axis in def.axes) {
    var total = 0.0;
    axis.weights.forEach((slotId, w) => total += scoreOf(slotId) * w);
    axisScores[axis.id] = total.round().clamp(0, 100);
  }

  final statTotals = <String, int>{};
  for (final stat in def.stats) {
    var total = 0;
    for (final part in build.slots.values.whereType<DevicePart>()) {
      total += part.stats[stat.id] ?? 0;
    }
    statTotals[stat.id] = total;
  }

  final price = build.slots.values
      .whereType<DevicePart>()
      .fold(0, (sum, p) => sum + p.price);

  return SimResult(
    axisScores: axisScores,
    statTotals: statTotals,
    totalPrice: price,
    bottleneck: def.bottleneck?.call(build),
  );
}

// ── 데스크탑 ──────────────────────────────────────────────────────

final desktopDef = DeviceCategoryDef(
  category: DeviceCategory.desktop,
  slots: const [
    DeviceSlot(id: 'cpu', label: 'CPU', emoji: '🧠'),
    DeviceSlot(id: 'gpu', label: '그래픽카드', emoji: '🎮'),
    DeviceSlot(id: 'ram', label: '메모리', emoji: '📊'),
    DeviceSlot(id: 'storage', label: '저장장치', emoji: '💾'),
    DeviceSlot(id: 'board', label: '메인보드', emoji: '🧩'),
    DeviceSlot(id: 'psu', label: '파워', emoji: '🔌'),
  ],
  axes: const [
    ScoreAxis(id: 'gaming', label: '게임 성능', weights: {'gpu': 0.60, 'cpu': 0.30, 'ram': 0.10}),
    ScoreAxis(id: 'work', label: '작업 성능', weights: {'cpu': 0.50, 'ram': 0.25, 'storage': 0.15, 'gpu': 0.10}),
  ],
  stats: const [StatDef(id: 'watt', label: '예상 전력', unit: 'W')],
  bottleneck: (build) {
    final cpu = build['cpu'];
    final gpu = build['gpu'];
    if (cpu == null || gpu == null) return null;
    final gap = cpu.perfScore - gpu.perfScore;
    if (gap >= 25) return 'GPU가 CPU를 못 따라가요 (그래픽카드 병목)';
    if (gap <= -25) return 'CPU가 GPU를 못 따라가요 (CPU 병목)';
    return null;
  },
  sampleParts: const [
    DevicePart(id: 'cpu-hi', slotId: 'cpu', name: '고급 CPU (샘플)', perfScore: 90, stats: {'watt': 125}, price: 550000),
    DevicePart(id: 'cpu-mid', slotId: 'cpu', name: '중급 CPU (샘플)', perfScore: 65, stats: {'watt': 88}, price: 280000),
    DevicePart(id: 'cpu-lo', slotId: 'cpu', name: '보급 CPU (샘플)', perfScore: 40, stats: {'watt': 65}, price: 130000),
    DevicePart(id: 'gpu-hi', slotId: 'gpu', name: '고급 GPU (샘플)', perfScore: 92, stats: {'watt': 320}, price: 1500000),
    DevicePart(id: 'gpu-mid', slotId: 'gpu', name: '중급 GPU (샘플)', perfScore: 60, stats: {'watt': 200}, price: 600000),
    DevicePart(id: 'gpu-lo', slotId: 'gpu', name: '보급 GPU (샘플)', perfScore: 35, stats: {'watt': 115}, price: 250000),
    DevicePart(id: 'ram-32', slotId: 'ram', name: '32GB 메모리 (샘플)', perfScore: 80, stats: {'watt': 10}, price: 120000),
    DevicePart(id: 'ram-16', slotId: 'ram', name: '16GB 메모리 (샘플)', perfScore: 55, stats: {'watt': 6}, price: 60000),
    DevicePart(id: 'ssd-nvme', slotId: 'storage', name: 'NVMe SSD 1TB (샘플)', perfScore: 85, stats: {'watt': 8}, price: 110000),
    DevicePart(id: 'ssd-sata', slotId: 'storage', name: 'SATA SSD 1TB (샘플)', perfScore: 50, stats: {'watt': 5}, price: 80000),
    DevicePart(id: 'board-hi', slotId: 'board', name: '고급 보드 (샘플)', perfScore: 70, stats: {'watt': 45}, price: 300000),
    DevicePart(id: 'board-mid', slotId: 'board', name: '보급 보드 (샘플)', perfScore: 50, stats: {'watt': 35}, price: 130000),
    DevicePart(id: 'psu-850', slotId: 'psu', name: '850W 파워 (샘플)', perfScore: 80, stats: {'watt': 0}, price: 150000),
    DevicePart(id: 'psu-600', slotId: 'psu', name: '600W 파워 (샘플)', perfScore: 55, stats: {'watt': 0}, price: 80000),
  ],
);

// ── 노트북 ────────────────────────────────────────────────────────

final laptopDef = DeviceCategoryDef(
  category: DeviceCategory.laptop,
  slots: const [
    DeviceSlot(id: 'cpu', label: 'CPU', emoji: '🧠'),
    DeviceSlot(id: 'gpu', label: '그래픽', emoji: '🎮'),
    DeviceSlot(id: 'ram', label: '메모리', emoji: '📊'),
    DeviceSlot(id: 'storage', label: '저장장치', emoji: '💾'),
    DeviceSlot(id: 'battery', label: '배터리', emoji: '🔋'),
  ],
  axes: const [
    ScoreAxis(id: 'gaming', label: '게임 성능', weights: {'gpu': 0.55, 'cpu': 0.35, 'ram': 0.10}),
    ScoreAxis(id: 'work', label: '작업 성능', weights: {'cpu': 0.55, 'ram': 0.25, 'storage': 0.20}),
  ],
  stats: const [StatDef(id: 'battery_wh', label: '배터리 용량', unit: 'Wh')],
  sampleParts: const [
    DevicePart(id: 'lt-cpu-hi', slotId: 'cpu', name: '상급 노트북 CPU (샘플)', perfScore: 85, stats: {}, price: 700000),
    DevicePart(id: 'lt-cpu-mid', slotId: 'cpu', name: '보급 노트북 CPU (샘플)', perfScore: 60, stats: {}, price: 400000),
    DevicePart(id: 'lt-gpu-hi', slotId: 'gpu', name: '외장 그래픽 (샘플)', perfScore: 80, stats: {}, price: 350000),
    DevicePart(id: 'lt-gpu-lo', slotId: 'gpu', name: '내장 그래픽 (샘플)', perfScore: 30, stats: {}, price: 0),
    DevicePart(id: 'lt-ram-32', slotId: 'ram', name: '32GB 메모리 (샘플)', perfScore: 78, stats: {}, price: 150000),
    DevicePart(id: 'lt-ram-16', slotId: 'ram', name: '16GB 메모리 (샘플)', perfScore: 55, stats: {}, price: 80000),
    DevicePart(id: 'lt-ssd-1t', slotId: 'storage', name: 'NVMe SSD 1TB (샘플)', perfScore: 82, stats: {}, price: 130000),
    DevicePart(id: 'lt-ssd-512', slotId: 'storage', name: 'NVMe SSD 512GB (샘플)', perfScore: 60, stats: {}, price: 70000),
    DevicePart(id: 'lt-bat-99', slotId: 'battery', name: '99Wh 대용량 배터리 (샘플)', perfScore: 70, stats: {'battery_wh': 99}, price: 0),
    DevicePart(id: 'lt-bat-55', slotId: 'battery', name: '55Wh 배터리 (샘플)', perfScore: 50, stats: {'battery_wh': 55}, price: 0),
  ],
);

// ── 폰 ────────────────────────────────────────────────────────────

final phoneDef = DeviceCategoryDef(
  category: DeviceCategory.phone,
  slots: const [
    DeviceSlot(id: 'chipset', label: '칩셋', emoji: '🧠'),
    DeviceSlot(id: 'ram', label: '메모리', emoji: '📊'),
    DeviceSlot(id: 'storage', label: '저장공간', emoji: '💾'),
    DeviceSlot(id: 'battery', label: '배터리', emoji: '🔋'),
  ],
  axes: const [
    ScoreAxis(id: 'everyday', label: '일상 성능', weights: {'chipset': 0.60, 'ram': 0.30, 'storage': 0.10}),
    ScoreAxis(id: 'heavy', label: '고사양 성능', weights: {'chipset': 0.55, 'ram': 0.35, 'storage': 0.10}),
  ],
  stats: const [StatDef(id: 'battery_mah', label: '배터리 용량', unit: 'mAh')],
  sampleParts: const [
    DevicePart(id: 'ph-chip-hi', slotId: 'chipset', name: '플래그십 칩셋 (샘플)', perfScore: 90, stats: {}, price: 400000),
    DevicePart(id: 'ph-chip-mid', slotId: 'chipset', name: '준수한 칩셋 (샘플)', perfScore: 65, stats: {}, price: 200000),
    DevicePart(id: 'ph-chip-lo', slotId: 'chipset', name: '보급 칩셋 (샘플)', perfScore: 40, stats: {}, price: 100000),
    DevicePart(id: 'ph-ram-12', slotId: 'ram', name: '12GB (샘플)', perfScore: 75, stats: {}, price: 60000),
    DevicePart(id: 'ph-ram-8', slotId: 'ram', name: '8GB (샘플)', perfScore: 55, stats: {}, price: 30000),
    DevicePart(id: 'ph-store-256', slotId: 'storage', name: '256GB (샘플)', perfScore: 70, stats: {}, price: 50000),
    DevicePart(id: 'ph-store-128', slotId: 'storage', name: '128GB (샘플)', perfScore: 50, stats: {}, price: 20000),
    DevicePart(id: 'ph-bat-5000', slotId: 'battery', name: '5000mAh (샘플)', perfScore: 75, stats: {'battery_mah': 5000}, price: 20000),
    DevicePart(id: 'ph-bat-4000', slotId: 'battery', name: '4000mAh (샘플)', perfScore: 55, stats: {'battery_mah': 4000}, price: 10000),
  ],
);

// ── 태블릿 ────────────────────────────────────────────────────────

final tabletDef = DeviceCategoryDef(
  category: DeviceCategory.tablet,
  slots: const [
    DeviceSlot(id: 'chipset', label: '칩셋', emoji: '🧠'),
    DeviceSlot(id: 'ram', label: '메모리', emoji: '📊'),
    DeviceSlot(id: 'storage', label: '저장공간', emoji: '💾'),
    DeviceSlot(id: 'battery', label: '배터리', emoji: '🔋'),
  ],
  axes: const [
    ScoreAxis(id: 'everyday', label: '일상 성능', weights: {'chipset': 0.55, 'ram': 0.35, 'storage': 0.10}),
    ScoreAxis(id: 'heavy', label: '고사양 성능', weights: {'chipset': 0.50, 'ram': 0.35, 'storage': 0.15}),
  ],
  stats: const [StatDef(id: 'battery_mah', label: '배터리 용량', unit: 'mAh')],
  sampleParts: const [
    DevicePart(id: 'tb-chip-hi', slotId: 'chipset', name: '플래그십 태블릿 칩셋 (샘플)', perfScore: 88, stats: {}, price: 450000),
    DevicePart(id: 'tb-chip-mid', slotId: 'chipset', name: '보급 태블릿 칩셋 (샘플)', perfScore: 55, stats: {}, price: 220000),
    DevicePart(id: 'tb-ram-8', slotId: 'ram', name: '8GB (샘플)', perfScore: 70, stats: {}, price: 60000),
    DevicePart(id: 'tb-ram-6', slotId: 'ram', name: '6GB (샘플)', perfScore: 50, stats: {}, price: 30000),
    DevicePart(id: 'tb-store-256', slotId: 'storage', name: '256GB (샘플)', perfScore: 70, stats: {}, price: 70000),
    DevicePart(id: 'tb-store-128', slotId: 'storage', name: '128GB (샘플)', perfScore: 50, stats: {}, price: 30000),
    DevicePart(id: 'tb-bat-8000', slotId: 'battery', name: '8000mAh (샘플)', perfScore: 75, stats: {'battery_mah': 8000}, price: 30000),
    DevicePart(id: 'tb-bat-6000', slotId: 'battery', name: '6000mAh (샘플)', perfScore: 55, stats: {'battery_mah': 6000}, price: 15000),
  ],
);

// ── 워치 ──────────────────────────────────────────────────────────

final watchDef = DeviceCategoryDef(
  category: DeviceCategory.watch,
  slots: const [
    DeviceSlot(id: 'chipset', label: '칩셋', emoji: '🧠'),
    DeviceSlot(id: 'battery', label: '배터리', emoji: '🔋'),
    DeviceSlot(id: 'display', label: '디스플레이', emoji: '🖼️'),
  ],
  axes: const [
    ScoreAxis(id: 'responsiveness', label: '반응 속도', weights: {'chipset': 0.80, 'display': 0.20}),
    ScoreAxis(id: 'battery_life', label: '배터리 지속', weights: {'battery': 0.75, 'chipset': 0.25}),
  ],
  stats: const [StatDef(id: 'battery_mah', label: '배터리 용량', unit: 'mAh')],
  sampleParts: const [
    DevicePart(id: 'wt-chip-hi', slotId: 'chipset', name: '고성능 워치칩 (샘플)', perfScore: 80, stats: {}, price: 150000),
    DevicePart(id: 'wt-chip-lo', slotId: 'chipset', name: '보급형 워치칩 (샘플)', perfScore: 50, stats: {}, price: 80000),
    DevicePart(id: 'wt-bat-400', slotId: 'battery', name: '400mAh (샘플)', perfScore: 70, stats: {'battery_mah': 400}, price: 20000),
    DevicePart(id: 'wt-bat-300', slotId: 'battery', name: '300mAh (샘플)', perfScore: 50, stats: {'battery_mah': 300}, price: 10000),
    DevicePart(id: 'wt-disp-amoled', slotId: 'display', name: 'AMOLED 고해상도 (샘플)', perfScore: 80, stats: {}, price: 100000),
    DevicePart(id: 'wt-disp-lcd', slotId: 'display', name: 'LCD (샘플)', perfScore: 45, stats: {}, price: 40000),
  ],
);

/// 진입 화면에서 순서대로 보여줄 전체 카테고리 목록.
final List<DeviceCategoryDef> allDeviceCategoryDefs = [
  phoneDef,
  tabletDef,
  watchDef,
  desktopDef,
  laptopDef,
];
```

- [ ] **Step 2: 정적 분석**

Run: `flutter analyze lib/device_sim_data.dart`
Expected: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/device_sim_data.dart
git commit -m "$(cat <<'EOF'
feat: 전자기기 성능 비교 공통 시뮬레이션 엔진 추가

폰/태블릿/워치/데스크탑/노트북 5개 카테고리를 슬롯·성능축·보조지표로
일반화하는 엔진. 샘플 부품만 포함, 실데이터는 후속 작업.
EOF
)"
```

---

## Task 2: 기기별 시각 위젯 (모양 + 완성 연출)

**Files:**
- Create: `lib/device_shapes.dart`

- [ ] **Step 1: 파일 작성**

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'device_sim_data.dart';

const Color _accent = Color(0xFF34D399);

typedef SlotTapCallback = void Function(String slotId);

/// 슬롯 배지: 탭하면 해당 슬롯 부품 선택 시트를 연다. 채워지면 초록, 비면 회색.
class SlotBadge extends StatelessWidget {
  final DeviceSlot slot;
  final DevicePart? part;
  final VoidCallback onTap;
  const SlotBadge({super.key, required this.slot, required this.part, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final filled = part != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: filled ? _accent.withAlpha(45) : Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: filled ? _accent : Colors.white38),
        ),
        child: Text(
          '${slot.emoji} ${slot.label}',
          style: TextStyle(
            color: filled ? _accent : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// 완성(isComplete) 시 0→1을 계속 반복하는 공용 애니메이션 티커.
/// 팬 회전, RGB 순환, 화면 발광 등 모든 "작동하는 것처럼" 연출의 기반.
class PoweredOnTicker extends StatefulWidget {
  final bool active;
  final Widget Function(BuildContext context, double t) builder;
  const PoweredOnTicker({super.key, required this.active, required this.builder});

  @override
  State<PoweredOnTicker> createState() => _PoweredOnTickerState();
}

class _PoweredOnTickerState extends State<PoweredOnTicker> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(PoweredOnTicker old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => widget.builder(context, _c.value),
    );
  }
}

/// 0~1 진행값을 3색 순환 색상으로 변환 (RGB 테두리 펄스용).
Color rgbCycle(double t) {
  const colors = [Color(0xFF34D399), Color(0xFF60A5FA), Color(0xFFF472B6)];
  final seg = (t * colors.length) % colors.length;
  final i = seg.floor() % colors.length;
  final j = (i + 1) % colors.length;
  final localT = seg - i;
  return Color.lerp(colors[i], colors[j], localT)!;
}

/// 0~1 진행값을 은은한 발광 강도(0~1)로 변환 (화면/링 글로우용).
double glowPulse(double t) => 0.5 + 0.5 * math.sin(t * 2 * math.pi);

/// [device]의 슬롯 정의에서 [id]에 해당하는 슬롯을 찾는다.
/// `device_sim_data.dart`의 슬롯 목록과 어긋나면(예: 리네이밍 누락) 화면이 조용히
/// 죽지 않도록 원인을 알 수 있는 메시지와 함께 던진다.
DeviceSlot _slotOf(DeviceBuild device, String id) => device.def.slots.firstWhere(
      (s) => s.id == id,
      orElse: () => throw StateError('Unknown slot "$id" for ${device.def.category}'),
    );

// ── 데스크탑 ──────────────────────────────────────────────────────

class DesktopShape extends StatelessWidget {
  final DeviceBuild device;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
  const DesktopShape({super.key, required this.device, required this.isComplete, required this.onSlotTap});

  @override
  Widget build(BuildContext context) {
    return PoweredOnTicker(
      active: isComplete,
      builder: (context, t) {
        final rgb = isComplete ? rgbCycle(t) : Colors.white24;
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0F14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 10, right: 10, bottom: 56,
                child: Container(height: 4, color: const Color(0xFF3A2A1A)),
              ),
              Positioned(
                left: 38, bottom: 66,
                child: Column(
                  children: [
                    Container(
                      width: 120, height: 76,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF444444), width: 4),
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(0xFF000733),
                      ),
                    ),
                    Container(width: 14, height: 16, color: const Color(0xFF444444)),
                    Container(
                      width: 46, height: 5,
                      decoration: BoxDecoration(color: const Color(0xFF444444), borderRadius: BorderRadius.circular(3)),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 30, bottom: 20,
                child: CustomPaint(size: const Size(80, 40), painter: _PowerCablePainter(active: isComplete, t: t)),
              ),
              Positioned(
                right: 20, bottom: 14,
                child: Container(
                  width: 14, height: 18,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF666666), width: 2),
                    borderRadius: BorderRadius.circular(2),
                    color: const Color(0xFF222222),
                  ),
                ),
              ),
              Positioned(
                right: 36, bottom: 60,
                child: Container(
                  width: 58, height: 130,
                  decoration: BoxDecoration(
                    border: Border.all(color: rgb, width: 3),
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1A1C22), Color(0xFF0D0F14)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 15, top: 34,
                        child: Transform.rotate(
                          angle: isComplete ? t * 2 * math.pi : 0.0,
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white54, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 6, bottom: 6,
                        child: Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isComplete ? _accent : Colors.white24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(left: 20, top: 16, child: SlotBadge(slot: _slotOf(device, 'cpu'), part: device['cpu'], onTap: () => onSlotTap('cpu'))),
              Positioned(left: 20, top: 48, child: SlotBadge(slot: _slotOf(device, 'gpu'), part: device['gpu'], onTap: () => onSlotTap('gpu'))),
              Positioned(right: 20, top: 16, child: SlotBadge(slot: _slotOf(device, 'ram'), part: device['ram'], onTap: () => onSlotTap('ram'))),
              Positioned(right: 20, top: 48, child: SlotBadge(slot: _slotOf(device, 'storage'), part: device['storage'], onTap: () => onSlotTap('storage'))),
              Positioned(left: 20, top: 80, child: SlotBadge(slot: _slotOf(device, 'board'), part: device['board'], onTap: () => onSlotTap('board'))),
              Positioned(right: 20, top: 80, child: SlotBadge(slot: _slotOf(device, 'psu'), part: device['psu'], onTap: () => onSlotTap('psu'))),
            ],
          ),
        );
      },
    );
  }
}

/// 타워 뒤에서 콘센트로 이어지는 곡선 전원선. 완성 시 점선이 흐르는 것처럼 보이게 위상을 이동한다.
class _PowerCablePainter extends CustomPainter {
  final bool active;
  final double t;
  _PowerCablePainter({required this.active, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width - 10, 5)
      ..cubicTo(size.width - 40, 5, size.width - 50, size.height - 5, size.width - 75, size.height - 5);
    final paint = Paint()
      ..color = active ? _accent.withAlpha(180) : Colors.white38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(_dashPath(path, active ? t : 0), paint);
  }

  Path _dashPath(Path source, double phase) {
    final dashed = Path();
    const dashLen = 6.0;
    const gapLen = 4.0;
    for (final metric in source.computeMetrics()) {
      var distance = -phase * (dashLen + gapLen);
      while (distance < metric.length) {
        final start = distance < 0 ? 0.0 : distance;
        final end = (distance + dashLen) > metric.length ? metric.length : (distance + dashLen);
        if (end > start) {
          dashed.addPath(metric.extractPath(start, end), Offset.zero);
        }
        distance += dashLen + gapLen;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(covariant _PowerCablePainter old) => old.active != active || old.t != t;
}

// ── 노트북 ────────────────────────────────────────────────────────

class LaptopShape extends StatelessWidget {
  final DeviceBuild device;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
  const LaptopShape({super.key, required this.device, required this.isComplete, required this.onSlotTap});

  @override
  Widget build(BuildContext context) {
    return PoweredOnTicker(
      active: isComplete,
      builder: (context, t) {
        final glowAlpha = isComplete ? (glowPulse(t) * 160).round() : 0;
        return Container(
          height: 260,
          width: double.infinity,
          // No `alignment:` here on purpose: Container wraps its child in an
          // Align when alignment is set, and Align *always* loosens the width
          // constraint it passes to its child (see RenderPositionedBox in the
          // Flutter SDK) -- which would undo the tight width from `width:
          // double.infinity` above before it ever reaches the Stack below.
          // Stack's own `alignment: Alignment.center` already centers the
          // non-positioned body, so this outer alignment was redundant anyway.
          decoration: BoxDecoration(
            color: const Color(0xFF0D0F14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 220, height: 130,
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3A4048),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.circular(2)),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF20242A),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isComplete ? [BoxShadow(color: _accent.withAlpha(glowAlpha), blurRadius: 18)] : null,
                      ),
                    ),
                  ),
                  Container(
                    width: 250, height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC8CCD0),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                    ),
                  ),
                ],
              ),
              Positioned(left: 30, top: 30, child: SlotBadge(slot: _slotOf(device, 'cpu'), part: device['cpu'], onTap: () => onSlotTap('cpu'))),
              Positioned(right: 30, top: 30, child: SlotBadge(slot: _slotOf(device, 'gpu'), part: device['gpu'], onTap: () => onSlotTap('gpu'))),
              Positioned(left: 30, bottom: 40, child: SlotBadge(slot: _slotOf(device, 'ram'), part: device['ram'], onTap: () => onSlotTap('ram'))),
              Positioned(right: 30, bottom: 40, child: SlotBadge(slot: _slotOf(device, 'storage'), part: device['storage'], onTap: () => onSlotTap('storage'))),
              Positioned(bottom: 8, child: SlotBadge(slot: _slotOf(device, 'battery'), part: device['battery'], onTap: () => onSlotTap('battery'))),
            ],
          ),
        );
      },
    );
  }
}

// ── 폰 / 태블릿 (공유 몸체) ─────────────────────────────────────────

class _MobileBodyShape extends StatelessWidget {
  final DeviceBuild device;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
  final double bodyWidth;
  final double bodyHeight;
  const _MobileBodyShape({
    required this.device,
    required this.isComplete,
    required this.onSlotTap,
    required this.bodyWidth,
    required this.bodyHeight,
  });

  @override
  Widget build(BuildContext context) {
    return PoweredOnTicker(
      active: isComplete,
      builder: (context, t) {
        final glowAlpha = isComplete ? (140 + glowPulse(t) * 100).round() : 0;
        return Container(
          height: 280,
          width: double.infinity,
          // No `alignment:` here on purpose: Container wraps its child in an
          // Align when alignment is set, and Align *always* loosens the width
          // constraint it passes to its child (see RenderPositionedBox in the
          // Flutter SDK) -- which would undo the tight width from `width:
          // double.infinity` above before it ever reaches the Stack below.
          // Stack's own `alignment: Alignment.center` already centers the
          // non-positioned body, so this outer alignment was redundant anyway.
          decoration: BoxDecoration(
            color: const Color(0xFF0D0F14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: bodyWidth, height: bodyHeight,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF444444), width: 4),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF000733),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isComplete ? [BoxShadow(color: _accent.withAlpha(glowAlpha), blurRadius: 20)] : null,
                  ),
                ),
              ),
              Positioned(top: 24, child: SlotBadge(slot: _slotOf(device, 'chipset'), part: device['chipset'], onTap: () => onSlotTap('chipset'))),
              Positioned(left: 8, child: SlotBadge(slot: _slotOf(device, 'ram'), part: device['ram'], onTap: () => onSlotTap('ram'))),
              Positioned(right: 8, child: SlotBadge(slot: _slotOf(device, 'storage'), part: device['storage'], onTap: () => onSlotTap('storage'))),
              Positioned(bottom: 24, child: SlotBadge(slot: _slotOf(device, 'battery'), part: device['battery'], onTap: () => onSlotTap('battery'))),
            ],
          ),
        );
      },
    );
  }
}

class PhoneShape extends StatelessWidget {
  final DeviceBuild device;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
  const PhoneShape({super.key, required this.device, required this.isComplete, required this.onSlotTap});

  @override
  Widget build(BuildContext context) =>
      _MobileBodyShape(device: device, isComplete: isComplete, onSlotTap: onSlotTap, bodyWidth: 130, bodyHeight: 240);
}

class TabletShape extends StatelessWidget {
  final DeviceBuild device;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
  const TabletShape({super.key, required this.device, required this.isComplete, required this.onSlotTap});

  @override
  Widget build(BuildContext context) =>
      _MobileBodyShape(device: device, isComplete: isComplete, onSlotTap: onSlotTap, bodyWidth: 210, bodyHeight: 230);
}

// ── 워치 ──────────────────────────────────────────────────────────

class WatchShape extends StatelessWidget {
  final DeviceBuild device;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
  const WatchShape({super.key, required this.device, required this.isComplete, required this.onSlotTap});

  @override
  Widget build(BuildContext context) {
    return PoweredOnTicker(
      active: isComplete,
      builder: (context, t) {
        final glowAlpha = isComplete ? (glowPulse(t) * 220).round() : 0;
        return Container(
          height: 260,
          width: double.infinity,
          // No `alignment:` here on purpose -- see the same note in
          // LaptopShape/_MobileBodyShape above. WatchShape also has
          // non-Positioned children below (strap + watch face), so it needs
          // the same tight-width treatment to keep the chipset/battery/
          // display badges from crowding into a shrink-wrapped Stack.
          decoration: BoxDecoration(
            color: const Color(0xFF0D0F14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 26, height: 150, color: const Color(0xFF2A2A2A)),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF000733),
                  border: Border.all(color: const Color(0xFF555555), width: 4),
                  boxShadow: isComplete ? [BoxShadow(color: _accent.withAlpha(glowAlpha), blurRadius: 22, spreadRadius: 2)] : null,
                ),
              ),
              Positioned(top: 40, child: SlotBadge(slot: _slotOf(device, 'chipset'), part: device['chipset'], onTap: () => onSlotTap('chipset'))),
              Positioned(bottom: 60, left: 60, child: SlotBadge(slot: _slotOf(device, 'battery'), part: device['battery'], onTap: () => onSlotTap('battery'))),
              Positioned(bottom: 60, right: 60, child: SlotBadge(slot: _slotOf(device, 'display'), part: device['display'], onTap: () => onSlotTap('display'))),
            ],
          ),
        );
      },
    );
  }
}

// ── 카테고리 -> 위젯 매핑 ────────────────────────────────────────────

/// 빌더 화면에서 쓰는 실사용 위젯 (탭 가능, isComplete로 연출 전환).
Widget deviceShapeFor(DeviceBuild build, bool isComplete, SlotTapCallback onSlotTap) {
  return switch (build.def.category) {
    DeviceCategory.desktop => DesktopShape(device: build, isComplete: isComplete, onSlotTap: onSlotTap),
    DeviceCategory.laptop => LaptopShape(device: build, isComplete: isComplete, onSlotTap: onSlotTap),
    DeviceCategory.phone => PhoneShape(device: build, isComplete: isComplete, onSlotTap: onSlotTap),
    DeviceCategory.tablet => TabletShape(device: build, isComplete: isComplete, onSlotTap: onSlotTap),
    DeviceCategory.watch => WatchShape(device: build, isComplete: isComplete, onSlotTap: onSlotTap),
  };
}

/// 진입 화면 카드용 미니 프리뷰 (탭 비활성, 항상 빈 상태).
Widget devicePreviewFor(DeviceCategoryDef def) {
  final dummyBuild = DeviceBuild(def);
  return IgnorePointer(
    child: FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 280,
        height: 300,
        child: deviceShapeFor(dummyBuild, false, (_) {}),
      ),
    ),
  );
}
```

- [ ] **Step 2: 정적 분석**

Run: `flutter analyze lib/device_shapes.dart`
Expected: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/device_shapes.dart
git commit -m "$(cat <<'EOF'
feat: 기기별 시각 위젯(모양 + 완성 연출) 추가

데스크탑(모니터+타워+전원선+팬회전+RGB), 노트북/폰/태블릿(화면 발광),
워치(링 글로우)를 Container/Stack/AnimationController로 구현.
슬롯 배지는 탭하면 콜백으로 slotId를 넘긴다.
EOF
)"
```

---

## Task 3: 빌더 화면 (기존 pc_builder_page.dart 일반화)

**Files:**
- Create: `lib/device_builder_page.dart`

- [ ] **Step 1: 파일 작성**

```dart
import 'package:flutter/material.dart';
import 'device_sim_data.dart';
import 'device_shapes.dart';

const Color _bg = Color(0xFF111111);
const Color _accent = Color(0xFF34D399);

String _formatWon(int won) {
  final s = won.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// 기기 부품/스펙 조합 → 성능 예측 시뮬레이션 페이지 (프레임).
/// 견적 A/B 두 개를 만들어 비교할 수 있다.
class DeviceBuilderPage extends StatefulWidget {
  final DeviceCategoryDef def;
  const DeviceBuilderPage({super.key, required this.def});

  @override
  State<DeviceBuilderPage> createState() => _DeviceBuilderPageState();
}

class _DeviceBuilderPageState extends State<DeviceBuilderPage> {
  late final List<DeviceBuild> _builds = [DeviceBuild(widget.def), DeviceBuild(widget.def)];
  int _active = 0;

  DeviceBuild get _build => _builds[_active];

  @override
  Widget build(BuildContext context) {
    final result = simulate(_build);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Text('${widget.def.label} 성능 시뮬',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(width: 6),
            const Icon(Icons.change_history, color: Colors.white, size: 26),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '부품을 골라 견적을 짜면\n예상 성능을 계산하고 두 견적을 비교해드려요.',
                style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ 지금은 프레임 단계 — 샘플 부품·임시 계산식이에요.',
                style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              _buildTabs(),
              const SizedBox(height: 16),
              deviceShapeFor(_build, _build.isComplete, (slotId) => _openPicker(slotId)),
              const SizedBox(height: 24),
              const Text('예상 성능', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _resultCard(result),
              const SizedBox(height: 24),
              const Text('견적 비교', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _compareCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ── 견적 A/B 토글 ──────────────────────────────────────────────

  Widget _buildTabs() {
    return Row(
      children: [
        for (var i = 0; i < _builds.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _tabButton(i)),
        ],
      ],
    );
  }

  Widget _tabButton(int i) {
    final selected = i == _active;
    final label = i == 0 ? '견적 A' : '견적 B';
    return GestureDetector(
      onTap: () => setState(() => _active = i),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _accent : Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _accent : Colors.white24),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    color: selected ? Colors.black : Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text('${_builds[i].pickedCount}/${widget.def.slots.length} 선택',
                style: TextStyle(
                    color: selected ? Colors.black54 : Colors.white54, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ── 부품 선택 바텀시트 ────────────────────────────────────────────

  Future<void> _openPicker(String slotId) async {
    final slot = widget.def.slots.firstWhere((s) => s.id == slotId);
    final picked = await showModalBottomSheet<_PickResult>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PartPickerSheet(def: widget.def, slot: slot, current: _build[slotId]),
    );
    if (picked == null) return;
    setState(() => _build[slotId] = picked.part);
  }

  // ── 예상 성능 카드 ─────────────────────────────────────────────

  Widget _resultCard(SimResult r) {
    if (_build.isEmpty) {
      return _emptyCard('부품을 선택하면 예상 성능이 여기 표시돼요.');
    }
    const axisColors = [_accent, Color(0xFF60A5FA)];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < widget.def.axes.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _scoreBar(widget.def.axes[i].label, r.axisScores[widget.def.axes[i].id] ?? 0, axisColors[i % axisColors.length]),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              for (final stat in widget.def.stats) ...[
                _statChip(Icons.bolt, stat.label, '${r.statTotals[stat.id] ?? 0}${stat.unit}'),
                const SizedBox(width: 8),
              ],
              _statChip(Icons.payments_outlined, '예상 가격', '${_formatWon(r.totalPrice)}원'),
            ],
          ),
          if (r.bottleneck != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade700),
              ),
              child: Text('⚠️ ${r.bottleneck}',
                  style: TextStyle(color: Colors.orange.shade300, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
          if (!_build.isComplete) ...[
            const SizedBox(height: 10),
            Text(
              '아직 ${widget.def.slots.length - _build.pickedCount}개 슬롯이 비어 있어요. 채울수록 정확해져요.',
              style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _scoreBar(String label, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('$score', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
            const Text(' /100', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withAlpha(15), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w700)),
                  Text(value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 견적 A vs B 비교 ──────────────────────────────────────────

  Widget _compareCard() {
    final a = simulate(_builds[0]);
    final b = simulate(_builds[1]);
    if (_builds[0].isEmpty || _builds[1].isEmpty) {
      return _emptyCard('견적 A와 B 둘 다 부품을 담으면 비교해드려요.');
    }
    final rows = <Widget>[];
    for (var i = 0; i < widget.def.axes.length; i++) {
      final axis = widget.def.axes[i];
      final aVal = a.axisScores[axis.id] ?? 0;
      final bVal = b.axisScores[axis.id] ?? 0;
      if (rows.isNotEmpty) rows.add(const Divider(color: Colors.white12, height: 20));
      rows.add(_compareRow(axis.label, '$aVal', '$bVal', higherWins: true, aVal: aVal.toDouble(), bVal: bVal.toDouble()));
    }
    for (final stat in widget.def.stats) {
      final aVal = a.statTotals[stat.id] ?? 0;
      final bVal = b.statTotals[stat.id] ?? 0;
      rows.add(const Divider(color: Colors.white12, height: 20));
      rows.add(_compareRow(stat.label, '$aVal${stat.unit}', '$bVal${stat.unit}',
          higherWins: false, aVal: aVal.toDouble(), bVal: bVal.toDouble()));
    }
    rows.add(const Divider(color: Colors.white12, height: 20));
    rows.add(_compareRow('예상 가격', '${_formatWon(a.totalPrice)}원', '${_formatWon(b.totalPrice)}원',
        higherWins: false, aVal: a.totalPrice.toDouble(), bVal: b.totalPrice.toDouble()));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(children: rows),
    );
  }

  Widget _compareRow(String label, String aText, String bText,
      {required bool higherWins, required double aVal, required double bVal}) {
    final aWins = higherWins ? aVal > bVal : aVal < bVal;
    final bWins = higherWins ? bVal > aVal : bVal < aVal;
    TextStyle style(bool wins) => TextStyle(
          color: wins ? _accent : Colors.white70,
          fontSize: 14,
          fontWeight: wins ? FontWeight.w900 : FontWeight.w700,
        );
    return Row(
      children: [
        Expanded(child: Text(aText, textAlign: TextAlign.left, style: style(aWins))),
        SizedBox(
          width: 90,
          child: Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        Expanded(child: Text(bText, textAlign: TextAlign.right, style: style(bWins))),
      ],
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// 바텀시트 선택 결과. part == null 이면 '선택 해제'.
class _PickResult {
  final DevicePart? part;
  const _PickResult(this.part);
}

class _PartPickerSheet extends StatelessWidget {
  final DeviceCategoryDef def;
  final DeviceSlot slot;
  final DevicePart? current;
  const _PartPickerSheet({required this.def, required this.slot, this.current});

  @override
  Widget build(BuildContext context) {
    final parts = def.partsOf(slot.id);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(slot.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text('${slot.label} 선택',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 14),
            for (final p in parts) _partTile(context, p),
            if (current != null) ...[
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, const _PickResult(null)),
                  child: const Text('선택 해제',
                      style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _partTile(BuildContext context, DevicePart p) {
    final selected = p.id == current?.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.pop(context, _PickResult(p)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _accent.withAlpha(30) : Colors.white.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? _accent : Colors.white24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('성능 ${p.perfScore} · ${_statsSummary(p)}${_formatWon(p.price)}원',
                        style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: _accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _statsSummary(DevicePart p) {
    final parts = <String>[];
    for (final stat in def.stats) {
      final v = p.stats[stat.id];
      if (v != null && v != 0) parts.add('$v${stat.unit}');
    }
    return parts.isEmpty ? '' : '${parts.join(' · ')} · ';
  }
}
```

- [ ] **Step 2: 정적 분석**

Run: `flutter analyze lib/device_builder_page.dart`
Expected: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/device_builder_page.dart
git commit -m "$(cat <<'EOF'
feat: 기기 빌더 화면 추가 (기존 PC견적 페이지 일반화)

견적 A/B 탭 + 기기 시각 씬(슬롯 배지 탭→바텀시트) + 예상 성능 카드
(축별 점수바+보조지표+병목) + 견적 비교 카드를 def 메타데이터 기반
제너릭 루프로 렌더링. 5개 카테고리 전부 이 화면 하나로 처리.
EOF
)"
```

---

## Task 4: 진입 화면 (기기 종류 선택)

**Files:**
- Create: `lib/device_category_page.dart`

- [ ] **Step 1: 파일 작성**

```dart
import 'package:flutter/material.dart';
import 'device_sim_data.dart';
import 'device_shapes.dart';
import 'device_builder_page.dart';

const Color _bg = Color(0xFF111111);

/// "전자기기 성능 비교" 진입 화면. 기기 종류 5개 중 하나를 고르면
/// 그 카테고리의 DeviceBuilderPage로 이동한다.
class DeviceCategoryPage extends StatelessWidget {
  const DeviceCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Row(
          children: const [
            Text('전자기기 성능 비교',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            Icon(Icons.change_history, color: Colors.white, size: 26),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '기기 종류를 고르면\n부품을 배치하며 예상 성능을 비교할 수 있어요.',
                style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ 지금은 프레임 단계 — 샘플 부품·임시 계산식이에요.',
                style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [for (final def in allDeviceCategoryDefs) _categoryCard(context, def)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryCard(BuildContext context, DeviceCategoryDef def) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceBuilderPage(def: def))),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Expanded(child: devicePreviewFor(def)),
            const SizedBox(height: 8),
            Text('${def.emoji} ${def.label}',
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 정적 분석**

Run: `flutter analyze lib/device_category_page.dart`
Expected: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/device_category_page.dart
git commit -m "feat: 전자기기 성능 비교 기기 선택 진입 화면 추가"
```

---

## Task 5: 홈 화면 연결 + 옛 PC견적 파일 정리

**Files:**
- Modify: `lib/main.dart:9` (import), `lib/main.dart:102-108` (타일)
- Delete: `lib/pc_builder_data.dart`, `lib/pc_builder_page.dart`

- [ ] **Step 1: import 교체**

`lib/main.dart:9`의

```dart
import 'pc_builder_page.dart';
```

를 다음으로 교체:

```dart
import 'device_category_page.dart';
```

- [ ] **Step 2: 타일 교체**

`lib/main.dart:102-108`의

```dart
      _Tile(
        label: 'PC 견적',
        subtitle: '부품 조합 성능 예측',
        emoji: '🖥️',
        gradient: const [Color(0xFF34D399), Color(0xFF0F766E)],
        build: () => const PcBuilderPage(),
      ),
```

를 다음으로 교체:

```dart
      _Tile(
        label: '전자기기 성능 비교',
        subtitle: '부품 배치하고 성능 예측',
        emoji: '💻',
        gradient: const [Color(0xFF34D399), Color(0xFF0F766E)],
        build: () => const DeviceCategoryPage(),
      ),
```

- [ ] **Step 3: 옛 파일 삭제**

```bash
git rm lib/pc_builder_data.dart lib/pc_builder_page.dart
```

- [ ] **Step 4: 정적 분석 (프로젝트 전체)**

Run: `flutter analyze`
Expected: `No issues found!` (아무 파일에서도 `PcBuilderPage`/`pc_builder_data.dart` 참조가 남아있지 않아야 한다)

- [ ] **Step 5: 커밋**

```bash
git add lib/main.dart
git commit -m "$(cat <<'EOF'
feat: 홈 화면을 전자기기 성능 비교로 연결, 옛 PC견적 파일 제거

'PC 견적' 단일 타일을 '전자기기 성능 비교'로 교체하고
DeviceCategoryPage로 연결. pc_builder_data.dart/pc_builder_page.dart는
device_sim_data.dart/device_builder_page.dart로 완전히 대체되어 삭제.
EOF
)"
```

---

## Task 6: 수동 검증

**Files:** 없음 (검증만)

- [ ] **Step 1: 전체 정적 분석 재확인**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: 앱 실행 후 수동 확인**

시뮬레이터/디바이스가 연결돼 있으면 (`run` 스킬 또는 `flutter run` 사용) 아래를 전부 확인:

1. 홈 화면에 '전자기기 성능 비교'(💻) 타일이 보이고, 'PC 견적' 타일은 더 이상 없다.
2. 타일 탭 → 5개 카드(폰/태블릿/워치/데스크탑/노트북)가 보인다. 각 카드에 그 기기 모양의 작은 미리보기가 있다.
3. '데스크탑' 카드 탭 → 모니터+타워+키보드+마우스+전원선이 보이는 씬이 뜬다. 슬롯 배지 6개(CPU/그래픽카드/메모리/저장장치/메인보드/파워)를 순서대로 탭해 전부 채운다 → 채우는 즉시 타워 테두리가 RGB로 순환하고 팬이 회전하기 시작한다.
4. 예상 성능 카드에 게임/작업 점수, 예상 전력, 예상 가격이 보인다. CPU는 고급, GPU는 보급으로 골라 병목 경고 배지가 뜨는지 확인한다.
5. 견적 B 탭으로 전환해 다른 조합을 담고, 견적 비교 카드에서 A/B 숫자가 정확히 비교되는지 확인한다.
6. 뒤로 가서 '폰', '태블릿', '워치', '노트북' 각각 들어가 슬롯을 다 채웠을 때 화면(또는 워치는 링)이 발광하는지 확인한다.

시뮬레이터가 없으면: 이 단계를 건너뛰고 "시뮬레이터 미연결로 수동 확인 생략, `flutter analyze` 통과로 정적 검증만 완료"라고 보고한다.

- [ ] **Step 3: 결과 보고**

확인된 항목과 확인 못 한 항목(시뮬레이터 없어서 등)을 텍스트로 정리해 보고한다. 이 저장소 컨벤션상 자동화 테스트는 추가하지 않는다.
```

- [ ] **Step 4: 커밋 (수정사항 있었다면)**

수동 확인 중 발견한 사소한 버그를 고쳤다면:

```bash
git add lib/device_shapes.dart lib/device_builder_page.dart lib/device_category_page.dart lib/device_sim_data.dart
git commit -m "fix: 수동 검증 중 발견한 버그 수정"
```

버그가 없었다면 이 스텝은 생략.
