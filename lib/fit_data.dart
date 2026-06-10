// 신발 체감사이즈 계산 로직.
// data/shoes_sizing.csv 의 perception(체감) 행에서 뽑은 보정값을 코드로 옮긴 것.
//
// offsetMm 규약: + 면 "크게 나옴"(라벨보다 크게 신김), - 면 "작게 나옴".
//   - adjustment_reco '-5mm'(반다운) → 크게 나옴 → offset +5
//   - adjustment_reco '+5mm'(반업)   → 작게 나옴 → offset -5
//   - '1업'                          → offset -10
//   - '정사이즈'                      → offset 0

class FitInfo {
  final int offsetMm; // + 크게 나옴 / - 작게 나옴
  final String toebox; // 좁음 | 표준 | 넓음
  final String verdict; // 작게 | 정사이즈 | 크게
  const FitInfo({
    required this.offsetMm,
    required this.toebox,
    required this.verdict,
  });
}

class _Rule {
  final String brand; // brand_en 부분일치(소문자)
  final String name; // model_line 부분일치(소문자), '' = 브랜드 일반
  final FitInfo info;
  const _Rule(this.brand, this.name, this.info);
}

// 위에서부터 먼저 매칭되는 규칙을 쓴다(구체적 모델 → 브랜드 일반 순서).
const List<_Rule> _rules = [
  // 나이키
  _Rule('nike', 'air force', FitInfo(offsetMm: 5, toebox: '좁음', verdict: '크게')),
  _Rule('nike', 'dunk', FitInfo(offsetMm: -5, toebox: '좁음', verdict: '작게')),
  _Rule('nike', 'jordan', FitInfo(offsetMm: -5, toebox: '좁음', verdict: '작게')),
  _Rule('nike', '', FitInfo(offsetMm: 0, toebox: '좁음', verdict: '정사이즈')),
  // 아디다스
  _Rule('adidas', 'samba', FitInfo(offsetMm: -5, toebox: '좁음', verdict: '작게')),
  _Rule('adidas', 'gazelle', FitInfo(offsetMm: -5, toebox: '좁음', verdict: '작게')),
  _Rule('adidas', 'superstar', FitInfo(offsetMm: 5, toebox: '표준', verdict: '크게')),
  _Rule('adidas', 'yeezy', FitInfo(offsetMm: -10, toebox: '좁음', verdict: '작게')),
  _Rule('adidas', '', FitInfo(offsetMm: 0, toebox: '표준', verdict: '정사이즈')),
  // 뉴발란스
  _Rule('new balance', '993', FitInfo(offsetMm: 5, toebox: '넓음', verdict: '크게')),
  _Rule('new balance', '574', FitInfo(offsetMm: 5, toebox: '넓음', verdict: '크게')),
  _Rule('new balance', '990', FitInfo(offsetMm: 5, toebox: '넓음', verdict: '크게')),
  _Rule('new balance', '327', FitInfo(offsetMm: 5, toebox: '표준', verdict: '크게')),
  _Rule('new balance', '2002', FitInfo(offsetMm: -5, toebox: '좁음', verdict: '작게')),
  _Rule('new balance', '1906', FitInfo(offsetMm: -5, toebox: '좁음', verdict: '작게')),
  _Rule('new balance', '', FitInfo(offsetMm: 0, toebox: '표준', verdict: '정사이즈')),
  // 기타 글로벌
  _Rule('asics', '', FitInfo(offsetMm: 0, toebox: '표준', verdict: '정사이즈')),
  _Rule('converse', '', FitInfo(offsetMm: 5, toebox: '표준', verdict: '크게')),
  _Rule('vans', '', FitInfo(offsetMm: -5, toebox: '좁음', verdict: '작게')),
  _Rule('hoka', '', FitInfo(offsetMm: -5, toebox: '좁음', verdict: '작게')),
  _Rule('salomon', '', FitInfo(offsetMm: -5, toebox: '좁음', verdict: '작게')),
  _Rule('crocs', '', FitInfo(offsetMm: 5, toebox: '넓음', verdict: '크게')),
  _Rule('puma', '', FitInfo(offsetMm: 0, toebox: '표준', verdict: '정사이즈')),
];

const FitInfo _defaultFit =
    FitInfo(offsetMm: 0, toebox: '표준', verdict: '정사이즈');

FitInfo fitFor(String brand, String name) {
  final b = brand.toLowerCase();
  final n = name.toLowerCase();
  for (final r in _rules) {
    if (b.contains(r.brand) && (r.name.isEmpty || n.contains(r.name))) {
      return r.info;
    }
  }
  return _defaultFit;
}

/// 현재 신발(라벨 currentLabel mm)을 기준으로, target 신발에서 같은 착화감을 주는
/// 추천 라벨 사이즈(mm). 5mm 단위 반올림.
int recommendedLabel(int currentLabel, FitInfo current, FitInfo target) {
  final raw = currentLabel + current.offsetMm - target.offsetMm;
  final rounded = (raw / 5).round() * 5;
  return rounded.clamp(220, 330);
}

/// 현재 신발 착화감 기준 추정 발 사이즈(mm) = 라벨 + 크게 나온 정도.
int estimatedFootLength(int currentLabel, FitInfo current) =>
    currentLabel + current.offsetMm;

/// "크게 나오는 편" 같은 서술용 문구.
String verdictPhrase(FitInfo f) {
  switch (f.verdict) {
    case '크게':
      return '크게 나오는 편';
    case '작게':
      return '작게 나오는 편';
    default:
      return '정사이즈';
  }
}
