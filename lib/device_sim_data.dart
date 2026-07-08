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
