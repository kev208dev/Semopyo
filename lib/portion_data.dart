// data/food_portions.csv 핵심만 정리.
// 모든 항목 g 또는 mL 정량 + (있으면) kcal.
// 기준 앵커: 밥 한공기 210g.

const int riceBowlG = 210;

const String _pImgRice    = 'assets/products/rice.png';
const String _pImgRamen   = 'assets/products/ramen.png';
const String _pImgCereal  = 'assets/products/cereal.png';
const String _pImgIce     = 'assets/products/icecream.png';
const String _pImgBread   = 'assets/products/bread.png';
const String _pImgMilk    = 'assets/products/milk.png';
const String _pImgPop     = 'assets/products/popcorn.png';
const String _pImgBurger  = 'assets/products/burger.png';
const String _pImgGimbap  = 'assets/products/gimbap.png';
const String _pImgTteok   = 'assets/products/tteokbokki.png';
const String _pImgChicken = 'assets/products/chicken.png';
const String _pImgStew    = 'assets/products/stew.png';
const String _pImgSushi   = 'assets/products/sushi.png';
const String _pImgBento   = 'assets/products/bento.png';
const String _pImgShrimp  = 'assets/products/shrimp.png';
const String _pImgSake    = 'assets/products/sake.png';
const String _pImgBeer    = 'assets/products/beer.png';

/// PortionItem 의 이모지/이름 기반 카테고리 이미지.
String portionImageFor(PortionItem p) {
  if (p.image.isNotEmpty) return p.image;
  switch (p.emoji) {
    case '🍚': return _pImgRice;
    case '🍜': return _pImgRamen;
    case '🥣': return _pImgCereal;
    case '🍨': return _pImgIce;
    case '🍞': return _pImgBread;
    case '🥛': return _pImgMilk;
    case '🍿': return _pImgPop;
    case '🍔': return _pImgBurger;
    case '🍙': return _pImgGimbap;
    case '🍢': return _pImgTteok;
    case '🍗': return _pImgChicken;
    case '🍲': return _pImgStew;
    case '🍣': return _pImgSushi;
    case '🍱': return _pImgBento;
    case '🍤': return _pImgShrimp;
    case '🍶': return _pImgSake;
    case '🍺': return _pImgBeer;
  }
  return _pImgRice;
}

class PortionItem {
  final String name;
  final String brand;
  final int amount;       // g 또는 mL 중앙값
  final String unit;      // g | mL
  final int? kcal;        // 없으면 null
  final String type;      // 섭취참고량 | 완제품 | 1인분
  final String emoji;
  /// 상품 이미지(번들 에셋 경로 또는 URL). 없으면 브랜드 로고로 폴백.
  final String image;
  const PortionItem({
    required this.name,
    required this.brand,
    required this.amount,
    required this.unit,
    required this.type,
    required this.emoji,
    this.image = '',
    this.kcal,
  });
}

const List<PortionItem> portionItems = [
  // 식약처 섭취참고량 (국가표준 앵커)
  PortionItem(name: '밥 한공기', brand: '식약처 기준', amount: 210, unit: 'g', type: '섭취참고량', emoji: '🍚'),
  PortionItem(name: '봉지라면 1봉', brand: '식약처 기준', amount: 120, unit: 'g', type: '섭취참고량', emoji: '🍜'),
  PortionItem(name: '시리얼', brand: '식약처 기준', amount: 30, unit: 'g', type: '섭취참고량', emoji: '🥣'),
  PortionItem(name: '아이스크림', brand: '식약처 기준', amount: 100, unit: 'g', type: '섭취참고량', emoji: '🍨'),
  PortionItem(name: '빵', brand: '식약처 기준', amount: 70, unit: 'g', type: '섭취참고량', emoji: '🍞'),
  PortionItem(name: '우유', brand: '식약처 기준', amount: 200, unit: 'mL', type: '섭취참고량', emoji: '🥛'),
  PortionItem(name: '과자(팝콘류)', brand: '식약처 기준', amount: 20, unit: 'g', type: '섭취참고량', emoji: '🍿'),
  PortionItem(name: '음료베이스(농축액·분말)', brand: '식약처 기준', amount: 150, unit: 'mL', type: '섭취참고량', emoji: '🥛'),
  // 패스트푸드 완제품 (공식)
  PortionItem(name: '빅맥', brand: '맥도날드', amount: 223, unit: 'g', kcal: 582, type: '완제품', emoji: '🍔'),
  PortionItem(name: '쿼터파운더 치즈', brand: '맥도날드', amount: 199, unit: 'g', kcal: 522, type: '완제품', emoji: '🍔'),
  PortionItem(name: '맥치킨', brand: '맥도날드', amount: 173, unit: 'g', kcal: 401, type: '완제품', emoji: '🍔'),
  PortionItem(name: '한우불고기버거', brand: '롯데리아', amount: 263, unit: 'g', kcal: 572, type: '완제품', emoji: '🍔'),
  PortionItem(name: '불고기버거', brand: '롯데리아', amount: 188, unit: 'g', kcal: 476, type: '완제품', emoji: '🍔'),
  PortionItem(name: '더블한우불고기버거', brand: '롯데리아', amount: 352, unit: 'g', kcal: 802, type: '완제품', emoji: '🍔'),
  PortionItem(name: '새우버거', brand: '롯데리아', amount: 196, unit: 'g', kcal: 460, type: '완제품', emoji: '🍔'),
  PortionItem(name: '와퍼', brand: '버거킹', amount: 271, unit: 'g', kcal: 657, type: '완제품', emoji: '🍔'),
  PortionItem(name: '징거버거', brand: 'KFC', amount: 195, unit: 'g', kcal: 514, type: '완제품', emoji: '🍔'),
  PortionItem(name: '맘스터치 싸이버거', brand: '맘스터치', amount: 270, unit: 'g', kcal: 596, type: '완제품', emoji: '🍔'),
  // 치킨 1인분 (체감)
  PortionItem(name: '후라이드 치킨 1마리', brand: '교촌', amount: 900, unit: 'g', kcal: 2400, type: '1인분', emoji: '🍗'),
  PortionItem(name: '양념치킨 1마리', brand: 'BBQ', amount: 950, unit: 'g', kcal: 2600, type: '1인분', emoji: '🍗'),
  // 분식 1인분 (체감 집계)
  PortionItem(name: '김밥 1줄', brand: '김밥천국', amount: 250, unit: 'g', kcal: 485, type: '1인분', emoji: '🍙'),
  PortionItem(name: '야채김밥 1줄', brand: '김밥천국', amount: 225, unit: 'g', kcal: 360, type: '1인분', emoji: '🍙'),
  PortionItem(name: '참치김밥 1줄', brand: '김밥천국', amount: 280, unit: 'g', kcal: 530, type: '1인분', emoji: '🍙'),
  PortionItem(name: '떡볶이 1인분', brand: '김밥천국', amount: 250, unit: 'g', kcal: 366, type: '1인분', emoji: '🍢'),
  PortionItem(name: '치즈떡볶이 1인분', brand: '김밥천국', amount: 300, unit: 'g', kcal: 486, type: '1인분', emoji: '🍢'),
  PortionItem(name: '라볶이 1인분', brand: '김밥천국', amount: 350, unit: 'g', kcal: 600, type: '1인분', emoji: '🍢'),
  PortionItem(name: '순대 1인분', brand: '분식집', amount: 200, unit: 'g', kcal: 420, type: '1인분', emoji: '🍢'),
  PortionItem(name: '튀김 1인분(혼합)', brand: '분식집', amount: 150, unit: 'g', kcal: 500, type: '1인분', emoji: '🍤'),
  // 한식 1인분 (체감)
  PortionItem(name: '비빔밥', brand: '한식집', amount: 500, unit: 'g', kcal: 707, type: '1인분', emoji: '🍚'),
  PortionItem(name: '제육덮밥', brand: '한식집', amount: 450, unit: 'g', kcal: 680, type: '1인분', emoji: '🍚'),
  PortionItem(name: '김치찌개 1인분(밥포함)', brand: '한식집', amount: 600, unit: 'g', kcal: 580, type: '1인분', emoji: '🍲'),
  PortionItem(name: '된장찌개 1인분(밥포함)', brand: '한식집', amount: 600, unit: 'g', kcal: 540, type: '1인분', emoji: '🍲'),
  PortionItem(name: '부대찌개 1인분', brand: '한식집', amount: 500, unit: 'g', kcal: 720, type: '1인분', emoji: '🍲'),
  PortionItem(name: '갈비탕 1그릇', brand: '한식집', amount: 700, unit: 'g', kcal: 600, type: '1인분', emoji: '🍲'),
  PortionItem(name: '설렁탕 1그릇', brand: '한식집', amount: 700, unit: 'g', kcal: 520, type: '1인분', emoji: '🍲'),
  PortionItem(name: '국밥 1그릇', brand: '한식집', amount: 650, unit: 'g', kcal: 580, type: '1인분', emoji: '🍲'),
  PortionItem(name: '냉면 1그릇', brand: '한식집', amount: 700, unit: 'g', kcal: 530, type: '1인분', emoji: '🍜'),
  // 중식
  PortionItem(name: '짜장면 1그릇', brand: '중국집', amount: 650, unit: 'g', kcal: 797, type: '1인분', emoji: '🍜'),
  PortionItem(name: '짬뽕 1그릇', brand: '중국집', amount: 800, unit: 'g', kcal: 688, type: '1인분', emoji: '🍜'),
  PortionItem(name: '탕수육(소)', brand: '중국집', amount: 500, unit: 'g', kcal: 1300, type: '1인분', emoji: '🍤'),
  PortionItem(name: '볶음밥 1인분', brand: '중국집', amount: 400, unit: 'g', kcal: 750, type: '1인분', emoji: '🍚'),
  // 일식
  PortionItem(name: '돈가스 1인분', brand: '일식집', amount: 350, unit: 'g', kcal: 870, type: '1인분', emoji: '🍱'),
  PortionItem(name: '회덮밥', brand: '일식집', amount: 450, unit: 'g', kcal: 550, type: '1인분', emoji: '🍣'),
  PortionItem(name: '초밥 10피스', brand: '일식집', amount: 250, unit: 'g', kcal: 440, type: '1인분', emoji: '🍣'),
  PortionItem(name: '우동 1그릇', brand: '일식집', amount: 600, unit: 'g', kcal: 420, type: '1인분', emoji: '🍜'),
  // 음료/주류
  PortionItem(name: '소주 1병', brand: '하이트진로', amount: 360, unit: 'mL', kcal: 540, type: '완제품', emoji: '🍶'),
  PortionItem(name: '맥주 500cc', brand: '주점', amount: 500, unit: 'mL', kcal: 200, type: '1인분', emoji: '🍺'),
  PortionItem(name: '막걸리 1병', brand: '서울탁주', amount: 750, unit: 'mL', kcal: 360, type: '완제품', emoji: '🍶'),
];
