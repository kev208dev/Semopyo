// data/apparel_official.csv + apparel_perception.csv 요약.
// 상의 기준만 (남성 95 라벨 ≈ M 표준 매핑).

/// 의류 기본 이미지(흰 와이셔츠). 카테고리 매칭 안 되는 브랜드용.
const String kApparelDefaultImage = 'assets/products/apparel_default.png';

/// 카테고리별 기본 의류 이미지.
const String _imgTshirt     = 'assets/products/tshirt.png';
const String _imgSweatshirt = 'assets/products/sweatshirt.png';
const String _imgJacket     = 'assets/products/jacket.png';
const String _imgDress      = 'assets/products/dress.png';

class FitTendency {
  final String tendency; // 작게 | 정사이즈 | 크게
  final String adjust;   // 정사이즈 | 한치수작게 | 한치수크게
  final String silhouette;
  const FitTendency(this.tendency, this.adjust, this.silhouette);
}

class ApparelBrand {
  final String name;
  final String category;
  final FitTendency fit;
  /// L(100) 라벨 기준 단면 cm (어깨/가슴단면/총장). 없으면 표준매핑.
  final double shoulder;
  final double chestHalf;
  final double length;
  /// 카드에 표시할 옷 사진. 비면 kApparelDefaultImage(와이셔츠) 폴백.
  final String image;
  const ApparelBrand({
    required this.name,
    required this.category,
    required this.fit,
    required this.shoulder,
    required this.chestHalf,
    required this.length,
    this.image = '',
  });
}

/// 윌슨 표준매핑(국가표준): S(90)~XL(105) 상의 어깨/가슴단면/총장 중앙값.
const Map<String, List<double>> stdMen = {
  'S':  [46.0, 48.5, 64.5],
  'M':  [47.5, 51.0, 66.5],
  'L':  [49.0, 53.5, 68.5],
  'XL': [50.5, 56.0, 70.5],
};

const List<ApparelBrand> apparelBrands = [
  // 표준 (정사이즈 기준점)
  ApparelBrand(
    name: '윌슨(국가표준)',
    category: '상의 표준매핑',
    fit: FitTendency('정사이즈', '정사이즈', '레귤러'),
    shoulder: 49.0, chestHalf: 53.5, length: 68.5,
    image: kApparelDefaultImage,
  ),
  ApparelBrand(
    name: '스파오',
    category: '맨투맨',
    fit: FitTendency('정사이즈', '정사이즈', '레귤러'),
    shoulder: 60.0, chestHalf: 63.0, length: 70.0, // 105 라벨 기준 일반화
    image: _imgSweatshirt,
  ),
  ApparelBrand(
    name: '탑텐',
    category: '반팔티 베이직',
    fit: FitTendency('정사이즈', '정사이즈', '베이식 레귤러'),
    shoulder: 49.0, chestHalf: 53.5, length: 68.5,
    image: _imgTshirt,
  ),
  ApparelBrand(
    name: '에잇세컨즈',
    category: '셔츠·팬츠',
    fit: FitTendency('정사이즈', '정사이즈', '슬림핏'),
    shoulder: 47.0, chestHalf: 51.0, length: 67.0,
    image: kApparelDefaultImage,
  ),
  // 오버핏 (크게)
  ApparelBrand(
    name: '무신사 스탠다드',
    category: '맨투맨·후드',
    fit: FitTendency('크게', '정사이즈', '오버핏'),
    shoulder: 58.0, chestHalf: 62.0, length: 70.0,
    image: _imgSweatshirt,
  ),
  ApparelBrand(
    name: '커버낫',
    category: '맨투맨(헤비웨이트 오버핏)',
    fit: FitTendency('크게', '정사이즈', '오버핏'),
    shoulder: 91.0, chestHalf: 67.5, length: 71.0, // 화장 기준
    image: _imgSweatshirt,
  ),
  ApparelBrand(
    name: '디스이즈네버댓',
    category: '반팔티 스트릿',
    fit: FitTendency('크게', '정사이즈', '스트릿 오버핏'),
    shoulder: 47.0, chestHalf: 53.0, length: 71.0,
    image: _imgTshirt,
  ),
  ApparelBrand(
    name: '마하그리드',
    category: '맨투맨',
    fit: FitTendency('크게', '정사이즈', '오버핏'),
    shoulder: 56.0, chestHalf: 62.0, length: 68.0,
    image: _imgSweatshirt,
  ),
  ApparelBrand(
    name: '인사일런스',
    category: '맨투맨 드롭숄더',
    fit: FitTendency('크게', '정사이즈', '오버핏(드롭숄더)'),
    shoulder: 63.0, chestHalf: 62.0, length: 68.0,
    image: _imgSweatshirt,
  ),
  ApparelBrand(
    name: '라이풀',
    category: '미니멀 오버핏',
    fit: FitTendency('크게', '정사이즈', '미니멀 오버핏'),
    shoulder: 57.0, chestHalf: 60.0, length: 70.0,
    image: _imgSweatshirt,
  ),
  // 한치수 작게 추천 (크게 나옴 강함)
  ApparelBrand(
    name: 'ZARA',
    category: '티·팬츠',
    fit: FitTendency('크게', '한치수작게', '오버핏'),
    shoulder: 50.0, chestHalf: 55.0, length: 69.0,
    image: _imgTshirt,
  ),
  ApparelBrand(
    name: '노스페이스',
    category: '눕시 자켓',
    fit: FitTendency('크게', '한치수작게', '오버핏'),
    shoulder: 52.0, chestHalf: 58.0, length: 70.0,
    image: _imgJacket,
  ),
  // 작게 나옴
  ApparelBrand(
    name: '츄(CHUU)',
    category: '원피스',
    fit: FitTendency('작게', '정사이즈', '슬림·크롭'),
    shoulder: 36.0, chestHalf: 42.0, length: 60.0,
    image: _imgDress,
  ),
  ApparelBrand(
    name: '육육걸즈',
    category: '블라우스·원피스',
    fit: FitTendency('작게', '정사이즈', '슬림'),
    shoulder: 36.0, chestHalf: 42.5, length: 60.0,
    image: _imgDress,
  ),
  // 글로벌 표준
  ApparelBrand(
    name: 'UNIQLO',
    category: 'AIRism 오버사이즈',
    fit: FitTendency('정사이즈', '정사이즈', '오버사이즈 드롭숄더'),
    shoulder: 56.0, chestHalf: 59.0, length: 68.0,
    image: _imgTshirt,
  ),
];

const List<String> sizeLabels = ['S', 'M', 'L', 'XL'];

/// 브랜드의 카테고리에 맞는 옷 이미지 경로를 고른다.
/// brand.image 가 지정돼 있으면 그걸 우선, 없으면 카테고리 키워드로 매칭.
String apparelImageFor(ApparelBrand b) {
  if (b.image.isNotEmpty) return b.image;
  final c = b.category;
  if (c.contains('원피스') || c.contains('블라우스')) return _imgDress;
  if (c.contains('자켓') || c.contains('눕시') || c.contains('재킷')) return _imgJacket;
  if (c.contains('맨투맨') || c.contains('후드') || c.contains('스웨트')) return _imgSweatshirt;
  if (c.contains('반팔') || c.contains('티') || c.contains('셔츠') ||
      c.contains('AIRism')) {
    return _imgTshirt;
  }
  return kApparelDefaultImage; // 표준매핑 등 → 기본 와이셔츠
}

/// 라벨 size 기준 추천 사이즈 환산. 크게→한치수작게, 작게→한치수크게.
String recommendedSize(String fromSize, ApparelBrand to) {
  final i = sizeLabels.indexOf(fromSize);
  if (i < 0) return fromSize;
  int j = i;
  if (to.fit.adjust == '한치수작게') j -= 1;
  if (to.fit.adjust == '한치수크게') j += 1;
  return sizeLabels[j.clamp(0, sizeLabels.length - 1)];
}

String fitPhrase(FitTendency f) {
  if (f.tendency == '크게') return '크게 나오는 편';
  if (f.tendency == '작게') return '작게 나오는 편';
  return '정사이즈';
}
