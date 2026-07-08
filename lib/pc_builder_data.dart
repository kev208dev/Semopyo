/// PC 부품 조합 성능 시뮬레이션 — 데이터/로직 골격.
///
/// 지금은 프레임 확인용 샘플 부품 몇 개만 들어있다.
/// TODO: 실제 부품 데이터(assets/data/pc_parts.json)로 교체하고
///       simulate()를 벤치마크 기반 모델로 바꾼다.
library;

/// 견적 슬롯 종류. 프레임 단계에서는 핵심 6종만.
enum PcPartType { cpu, gpu, ram, storage, board, psu }

extension PcPartTypeInfo on PcPartType {
  String get label => switch (this) {
        PcPartType.cpu => 'CPU',
        PcPartType.gpu => '그래픽카드',
        PcPartType.ram => '메모리',
        PcPartType.storage => '저장장치',
        PcPartType.board => '메인보드',
        PcPartType.psu => '파워',
      };

  String get emoji => switch (this) {
        PcPartType.cpu => '🧠',
        PcPartType.gpu => '🎮',
        PcPartType.ram => '📊',
        PcPartType.storage => '💾',
        PcPartType.board => '🧩',
        PcPartType.psu => '🔌',
      };
}

class PcPart {
  final String id;
  final PcPartType type;
  final String brand;
  final String name;

  /// 0~100 상대 성능 점수. 샘플 값 — 실데이터 교체 대상.
  final int perfScore;

  /// 대략적인 소비 전력(W).
  final int watt;

  /// 참고 가격(원). 샘플 값.
  final int price;

  const PcPart({
    required this.id,
    required this.type,
    required this.brand,
    required this.name,
    required this.perfScore,
    required this.watt,
    required this.price,
  });
}

/// 한 견적(빌드): 슬롯별로 부품 하나씩.
class PcBuild {
  final Map<PcPartType, PcPart?> slots = {
    for (final t in PcPartType.values) t: null,
  };

  int get pickedCount => slots.values.whereType<PcPart>().length;
  bool get isEmpty => pickedCount == 0;
  bool get isComplete => pickedCount == PcPartType.values.length;

  PcPart? operator [](PcPartType t) => slots[t];
  void operator []=(PcPartType t, PcPart? p) => slots[t] = p;
}

/// 시뮬레이션 결과 골격.
class SimResult {
  /// 0~100. 게임 위주 성능 추정치.
  final int gamingScore;

  /// 0~100. 작업(영상 편집·개발 등) 성능 추정치.
  final int workScore;

  final int totalWatt;
  final int totalPrice;

  /// 병목 요약 문구. 없으면 null.
  final String? bottleneck;

  const SimResult({
    required this.gamingScore,
    required this.workScore,
    required this.totalWatt,
    required this.totalPrice,
    this.bottleneck,
  });

  static const empty = SimResult(
      gamingScore: 0, workScore: 0, totalWatt: 0, totalPrice: 0);
}

/// 자리표시자 시뮬레이션.
///
/// 슬롯별 perfScore를 용도별 가중치로 합산하는 단순 모델.
/// TODO: 실제 벤치마크(게임 fps, 렌더링 시간 등) 기반 모델로 교체.
SimResult simulate(PcBuild build) {
  if (build.isEmpty) return SimResult.empty;

  int score(PcPartType t) => build[t]?.perfScore ?? 0;

  final gaming = (score(PcPartType.gpu) * 0.60 +
          score(PcPartType.cpu) * 0.30 +
          score(PcPartType.ram) * 0.10)
      .round();
  final work = (score(PcPartType.cpu) * 0.50 +
          score(PcPartType.ram) * 0.25 +
          score(PcPartType.storage) * 0.15 +
          score(PcPartType.gpu) * 0.10)
      .round();

  final watt = build.slots.values
      .whereType<PcPart>()
      .fold(0, (sum, p) => sum + p.watt);
  final price = build.slots.values
      .whereType<PcPart>()
      .fold(0, (sum, p) => sum + p.price);

  String? bottleneck;
  final cpu = build[PcPartType.cpu];
  final gpu = build[PcPartType.gpu];
  if (cpu != null && gpu != null) {
    final gap = cpu.perfScore - gpu.perfScore;
    if (gap >= 25) {
      bottleneck = 'GPU가 CPU를 못 따라가요 (그래픽카드 병목)';
    } else if (gap <= -25) {
      bottleneck = 'CPU가 GPU를 못 따라가요 (CPU 병목)';
    }
  }

  return SimResult(
    gamingScore: gaming.clamp(0, 100),
    workScore: work.clamp(0, 100),
    totalWatt: watt,
    totalPrice: price,
    bottleneck: bottleneck,
  );
}

/// 프레임 확인용 샘플 부품. 수치는 대충 넣은 자리표시자.
/// TODO: 실데이터로 교체.
const samplePcParts = <PcPart>[
  // CPU
  PcPart(id: 'cpu-hi', type: PcPartType.cpu, brand: '샘플', name: '고급 CPU (샘플)', perfScore: 90, watt: 125, price: 550000),
  PcPart(id: 'cpu-mid', type: PcPartType.cpu, brand: '샘플', name: '중급 CPU (샘플)', perfScore: 65, watt: 88, price: 280000),
  PcPart(id: 'cpu-lo', type: PcPartType.cpu, brand: '샘플', name: '보급 CPU (샘플)', perfScore: 40, watt: 65, price: 130000),
  // GPU
  PcPart(id: 'gpu-hi', type: PcPartType.gpu, brand: '샘플', name: '고급 GPU (샘플)', perfScore: 92, watt: 320, price: 1500000),
  PcPart(id: 'gpu-mid', type: PcPartType.gpu, brand: '샘플', name: '중급 GPU (샘플)', perfScore: 60, watt: 200, price: 600000),
  PcPart(id: 'gpu-lo', type: PcPartType.gpu, brand: '샘플', name: '보급 GPU (샘플)', perfScore: 35, watt: 115, price: 250000),
  // RAM
  PcPart(id: 'ram-32', type: PcPartType.ram, brand: '샘플', name: '32GB 메모리 (샘플)', perfScore: 80, watt: 10, price: 120000),
  PcPart(id: 'ram-16', type: PcPartType.ram, brand: '샘플', name: '16GB 메모리 (샘플)', perfScore: 55, watt: 6, price: 60000),
  // 저장장치
  PcPart(id: 'ssd-nvme', type: PcPartType.storage, brand: '샘플', name: 'NVMe SSD 1TB (샘플)', perfScore: 85, watt: 8, price: 110000),
  PcPart(id: 'ssd-sata', type: PcPartType.storage, brand: '샘플', name: 'SATA SSD 1TB (샘플)', perfScore: 50, watt: 5, price: 80000),
  // 메인보드
  PcPart(id: 'board-hi', type: PcPartType.board, brand: '샘플', name: '고급 보드 (샘플)', perfScore: 70, watt: 45, price: 300000),
  PcPart(id: 'board-mid', type: PcPartType.board, brand: '샘플', name: '보급 보드 (샘플)', perfScore: 50, watt: 35, price: 130000),
  // 파워
  PcPart(id: 'psu-850', type: PcPartType.psu, brand: '샘플', name: '850W 파워 (샘플)', perfScore: 80, watt: 0, price: 150000),
  PcPart(id: 'psu-600', type: PcPartType.psu, brand: '샘플', name: '600W 파워 (샘플)', perfScore: 55, watt: 0, price: 80000),
];

List<PcPart> partsOf(PcPartType t) =>
    samplePcParts.where((p) => p.type == t).toList();
