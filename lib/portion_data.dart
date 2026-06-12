// data/food_portions.csv 핵심만 정리.
// 모든 항목 g 또는 mL 정량 + (있으면) kcal.
// 기준 앵커: 밥 한공기 210g.

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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
  // === 한식 추가 ===
  PortionItem(name: '떡국 1그릇', brand: '한식집', amount: 650, unit: 'g', kcal: 540, type: '1인분', emoji: '🍲'),
  PortionItem(name: '만둣국 1그릇', brand: '한식집', amount: 650, unit: 'g', kcal: 580, type: '1인분', emoji: '🍲'),
  PortionItem(name: '삼겹살 1인분', brand: '한식집', amount: 250, unit: 'g', kcal: 660, type: '1인분', emoji: '🥩'),
  PortionItem(name: '돼지갈비 1인분', brand: '한식집', amount: 300, unit: 'g', kcal: 720, type: '1인분', emoji: '🥩'),
  PortionItem(name: '소갈비 1인분', brand: '한식집', amount: 250, unit: 'g', kcal: 700, type: '1인분', emoji: '🥩'),
  PortionItem(name: '닭갈비 1인분', brand: '한식집', amount: 400, unit: 'g', kcal: 600, type: '1인분', emoji: '🍗'),
  PortionItem(name: '콩나물국밥', brand: '한식집', amount: 650, unit: 'g', kcal: 480, type: '1인분', emoji: '🍲'),
  PortionItem(name: '순두부찌개 1인분', brand: '한식집', amount: 600, unit: 'g', kcal: 480, type: '1인분', emoji: '🍲'),
  PortionItem(name: '청국장 1인분', brand: '한식집', amount: 600, unit: 'g', kcal: 510, type: '1인분', emoji: '🍲'),
  PortionItem(name: '곱창전골 1인분', brand: '한식집', amount: 700, unit: 'g', kcal: 850, type: '1인분', emoji: '🍲'),
  PortionItem(name: '닭볶음탕 1인분', brand: '한식집', amount: 500, unit: 'g', kcal: 700, type: '1인분', emoji: '🍲'),
  PortionItem(name: '삼계탕 1그릇', brand: '한식집', amount: 800, unit: 'g', kcal: 800, type: '1인분', emoji: '🍲'),
  PortionItem(name: '육개장 1그릇', brand: '한식집', amount: 700, unit: 'g', kcal: 530, type: '1인분', emoji: '🍲'),
  PortionItem(name: '미역국 1그릇', brand: '한식집', amount: 500, unit: 'g', kcal: 280, type: '1인분', emoji: '🍲'),
  PortionItem(name: '추어탕 1그릇', brand: '한식집', amount: 700, unit: 'g', kcal: 540, type: '1인분', emoji: '🍲'),
  PortionItem(name: '김치볶음밥', brand: '한식집', amount: 400, unit: 'g', kcal: 720, type: '1인분', emoji: '🍚'),
  PortionItem(name: '새우볶음밥', brand: '한식집', amount: 400, unit: 'g', kcal: 700, type: '1인분', emoji: '🍚'),
  PortionItem(name: '잡채밥', brand: '한식집', amount: 400, unit: 'g', kcal: 850, type: '1인분', emoji: '🍚'),
  PortionItem(name: '카레라이스', brand: '한식집', amount: 500, unit: 'g', kcal: 700, type: '1인분', emoji: '🍚'),
  PortionItem(name: '오므라이스', brand: '한식집', amount: 400, unit: 'g', kcal: 740, type: '1인분', emoji: '🍚'),
  PortionItem(name: '햄버그스테이크', brand: '경양식', amount: 400, unit: 'g', kcal: 850, type: '1인분', emoji: '🍱'),
  // === 분식/간식 추가 ===
  PortionItem(name: '호떡 1개', brand: '노점', amount: 80, unit: 'g', kcal: 220, type: '완제품', emoji: '🥞'),
  PortionItem(name: '붕어빵 1개', brand: '노점', amount: 60, unit: 'g', kcal: 160, type: '완제품', emoji: '🐟'),
  PortionItem(name: '와플 1개', brand: '카페', amount: 120, unit: 'g', kcal: 360, type: '완제품', emoji: '🧇'),
  PortionItem(name: '토스트 1개', brand: '분식집', amount: 120, unit: 'g', kcal: 320, type: '완제품', emoji: '🍞'),
  PortionItem(name: '샌드위치 1개', brand: '편의점', amount: 200, unit: 'g', kcal: 380, type: '완제품', emoji: '🥪'),
  PortionItem(name: '핫도그 1개', brand: '편의점', amount: 100, unit: 'g', kcal: 290, type: '완제품', emoji: '🌭'),
  PortionItem(name: '크로아상 1개', brand: '카페', amount: 80, unit: 'g', kcal: 320, type: '완제품', emoji: '🥐'),
  PortionItem(name: '베이글 1개', brand: '카페', amount: 100, unit: 'g', kcal: 280, type: '완제품', emoji: '🥯'),
  PortionItem(name: '도넛 1개', brand: '던킨', amount: 70, unit: 'g', kcal: 280, type: '완제품', emoji: '🍩'),
  PortionItem(name: '마카롱 1개', brand: '카페', amount: 30, unit: 'g', kcal: 120, type: '완제품', emoji: '🍪'),
  // === 중식/양식 추가 ===
  PortionItem(name: '깐풍기', brand: '중국집', amount: 400, unit: 'g', kcal: 1200, type: '1인분', emoji: '🍗'),
  PortionItem(name: '마라탕 1인분', brand: '중국집', amount: 700, unit: 'g', kcal: 800, type: '1인분', emoji: '🍲'),
  PortionItem(name: '마라샹궈', brand: '중국집', amount: 500, unit: 'g', kcal: 1100, type: '1인분', emoji: '🍲'),
  PortionItem(name: '양꼬치 10꼬치', brand: '중국집', amount: 250, unit: 'g', kcal: 720, type: '1인분', emoji: '🍢'),
  PortionItem(name: '쌀국수 1그릇', brand: '베트남식', amount: 600, unit: 'g', kcal: 500, type: '1인분', emoji: '🍜'),
  PortionItem(name: '팟타이 1인분', brand: '태국식', amount: 400, unit: 'g', kcal: 700, type: '1인분', emoji: '🍜'),
  PortionItem(name: '스파게티 토마토', brand: '면류(파스타)', amount: 400, unit: 'g', kcal: 580, type: '1인분', emoji: '🍝'),
  PortionItem(name: '까르보나라', brand: '면류(파스타)', amount: 400, unit: 'g', kcal: 920, type: '1인분', emoji: '🍝'),
  PortionItem(name: '알리오올리오', brand: '면류(파스타)', amount: 350, unit: 'g', kcal: 600, type: '1인분', emoji: '🍝'),
  PortionItem(name: '리조또', brand: '양식', amount: 400, unit: 'g', kcal: 650, type: '1인분', emoji: '🍚'),
  // === 일식 추가 ===
  PortionItem(name: '라멘 1그릇', brand: '일식집', amount: 700, unit: 'g', kcal: 700, type: '1인분', emoji: '🍜'),
  PortionItem(name: '규동 1그릇', brand: '일식집', amount: 400, unit: 'g', kcal: 720, type: '1인분', emoji: '🍚'),
  PortionItem(name: '가츠동 1그릇', brand: '일식집', amount: 450, unit: 'g', kcal: 850, type: '1인분', emoji: '🍚'),
  PortionItem(name: '텐동 1그릇', brand: '일식집', amount: 450, unit: 'g', kcal: 880, type: '1인분', emoji: '🍚'),
  PortionItem(name: '오니기리 1개', brand: '편의점', amount: 110, unit: 'g', kcal: 180, type: '완제품', emoji: '🍙'),
  // === 즉석/편의 추가 ===
  PortionItem(name: '컵라면 작은컵', brand: '편의점', amount: 75, unit: 'g', kcal: 350, type: '완제품', emoji: '🍜'),
  PortionItem(name: '컵라면 큰컵', brand: '편의점', amount: 110, unit: 'g', kcal: 500, type: '완제품', emoji: '🍜'),
  PortionItem(name: '컵밥 1개', brand: '편의점', amount: 280, unit: 'g', kcal: 480, type: '완제품', emoji: '🍚'),
  PortionItem(name: '도시락 1개', brand: '편의점', amount: 400, unit: 'g', kcal: 720, type: '완제품', emoji: '🍱'),
  PortionItem(name: '냉동만두 10개', brand: '비비고', amount: 200, unit: 'g', kcal: 420, type: '1인분', emoji: '🥟'),
  PortionItem(name: '냉동피자 1판', brand: '오뚜기', amount: 400, unit: 'g', kcal: 900, type: '완제품', emoji: '🍕'),
  PortionItem(name: '햇반', brand: 'CJ', amount: 210, unit: 'g', kcal: 310, type: '완제품', emoji: '🍚'),
  // 음료/주류
  PortionItem(name: '소주 1병', brand: '하이트진로', amount: 360, unit: 'mL', kcal: 540, type: '완제품', emoji: '🍶'),
  PortionItem(name: '맥주 500cc', brand: '주점', amount: 500, unit: 'mL', kcal: 200, type: '1인분', emoji: '🍺'),
  PortionItem(name: '막걸리 1병', brand: '서울탁주', amount: 750, unit: 'mL', kcal: 360, type: '완제품', emoji: '🍶'),
];

String _normalizePortion(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[\s\(\)\[\]\.\-_/]+'), '');

/// DB 분류 + 제품명 기반 추정 PortionItem. 정적 리스트에 없는 5만건 커버용.
PortionItem? buildEstimatedPortion(String? name, String? classification) {
  if (name == null || name.isEmpty) return null;
  final cls = (classification ?? '').toLowerCase();
  final nm = name.toLowerCase();
  bool inCls(List<String> kws) => kws.any(cls.contains);
  bool inName(List<String> kws) => kws.any(nm.contains);

  if (inCls(['음료', '다류'])
      || inName(['우유', '주스', '탄산', '콜라', '사이다', '커피', '에이드'])) {
    return PortionItem(name: name, brand: '스캔 제품', amount: 250,
        unit: 'mL', kcal: 110, type: '완제품(추정)', emoji: '🥤');
  }
  if (inCls(['주류']) || inName(['소주', '맥주', '와인', '막걸리'])) {
    return PortionItem(name: name, brand: '스캔 제품', amount: 360,
        unit: 'mL', kcal: 220, type: '완제품(추정)', emoji: '🍶');
  }
  if (inCls(['면류']) || inName(['라면', '국수', '냉면', '우동'])) {
    return PortionItem(name: name, brand: '스캔 제품', amount: 120,
        unit: 'g', kcal: 500, type: '완제품(추정)', emoji: '🍜');
  }
  if (inCls(['즉석', '편의'])) {
    return PortionItem(name: name, brand: '스캔 제품', amount: 280,
        unit: 'g', kcal: 480, type: '완제품(추정)', emoji: '🍱');
  }
  if (inCls(['초콜릿']) || inName(['초콜릿', '초코'])) {
    return PortionItem(name: name, brand: '스캔 제품', amount: 30,
        unit: 'g', kcal: 160, type: '완제품(추정)', emoji: '🍫');
  }
  if (inCls(['과자', '빵', '떡'])) {
    return PortionItem(name: name, brand: '스캔 제품', amount: 80,
        unit: 'g', kcal: 320, type: '완제품(추정)', emoji: '🍪');
  }
  if (inCls(['김치', '절임'])) {
    return PortionItem(name: name, brand: '스캔 제품', amount: 200,
        unit: 'g', kcal: 60, type: '1인분(추정)', emoji: '🥬');
  }
  if (inCls(['수산'])) {
    return PortionItem(name: name, brand: '스캔 제품', amount: 100,
        unit: 'g', kcal: 200, type: '완제품(추정)', emoji: '🐟');
  }
  if (inCls(['장류', '소스'])) {
    return PortionItem(name: name, brand: '스캔 제품', amount: 15,
        unit: 'g', kcal: 30, type: '섭취량(추정)', emoji: '🥫');
  }
  if (inCls(['아이스크림', '빙과'])) {
    return PortionItem(name: name, brand: '스캔 제품', amount: 100,
        unit: 'g', kcal: 200, type: '완제품(추정)', emoji: '🍨');
  }
  if (inCls(['식육', '가공'])) {
    return PortionItem(name: name, brand: '스캔 제품', amount: 100,
        unit: 'g', kcal: 250, type: '완제품(추정)', emoji: '🥩');
  }
  if (inCls(['두부', '묵', '두유'])) {
    return PortionItem(name: name, brand: '스캔 제품', amount: 150,
        unit: 'g', kcal: 100, type: '1인분(추정)', emoji: '🥣');
  }
  // 분류 없거나 기타 — 일반 가공식품 평균
  return PortionItem(name: name, brand: '스캔 제품', amount: 100,
      unit: 'g', kcal: 250, type: '완제품(추정)', emoji: '🍴');
}

/// 확장 포션 DB 1회 로드 (assets/data/portions_global.json, 63건).
Future<List<PortionItem>> loadGlobalPortions() async {
  final raw = await rootBundle.loadString('assets/data/portions_global.json');
  final list = jsonDecode(raw) as List;
  return list.map<PortionItem>((e) {
    final m = e as Map<String, dynamic>;
    final amt = (m['amount'] as num?)?.toInt() ?? 0;
    final unit = (m['amount_unit'] ?? 'g').toString();
    final cat = (m['category'] ?? '').toString();
    return PortionItem(
      name: (m['food'] ?? '').toString(),
      brand: (m['source'] ?? '').toString(),
      amount: amt,
      unit: unit,
      kcal: (m['kcal'] as num?)?.toInt(),
      type: (m['portion_type'] ?? '1인분').toString(),
      emoji: _emojiForCategory(cat),
    );
  }).where((p) => p.amount > 0 && p.name.isNotEmpty).toList();
}

String _emojiForCategory(String cat) {
  if (cat.contains('밥') || cat.contains('주식')) return '🍚';
  if (cat.contains('면') || cat.contains('라면')) return '🍜';
  if (cat.contains('시리얼')) return '🥣';
  if (cat.contains('아이스크림') || cat.contains('빙수')) return '🍨';
  if (cat.contains('빵') || cat.contains('제과')) return '🍞';
  if (cat.contains('우유') || cat.contains('유제품')) return '🥛';
  if (cat.contains('스낵') || cat.contains('과자')) return '🍿';
  if (cat.contains('버거') || cat.contains('샌드')) return '🍔';
  if (cat.contains('김밥') || cat.contains('주먹밥')) return '🍙';
  if (cat.contains('떡볶이') || cat.contains('떡')) return '🍢';
  if (cat.contains('치킨')) return '🍗';
  if (cat.contains('찌개') || cat.contains('국') || cat.contains('탕')) return '🍲';
  if (cat.contains('초밥') || cat.contains('스시')) return '🍣';
  if (cat.contains('도시락') || cat.contains('편의')) return '🍱';
  if (cat.contains('새우') || cat.contains('해산물')) return '🍤';
  if (cat.contains('주류') || cat.contains('맥주')) return '🍺';
  if (cat.contains('음료') || cat.contains('다류')) return '🥤';
  return '🍴';
}

/// 스캔된 제품명에서 portionItems 항목을 찾는다. 가장 긴 매치 우선.
PortionItem? matchPortionFromName(String? scanned) {
  if (scanned == null || scanned.isEmpty) return null;
  final n = _normalizePortion(scanned);
  if (n.isEmpty) return null;
  PortionItem? best;
  int bestLen = 0;
  for (final p in portionItems) {
    final pn = _normalizePortion(p.name);
    if (pn.length < 2) continue;
    if (n.contains(pn) && pn.length > bestLen) {
      best = p;
      bestLen = pn.length;
    }
  }
  return best;
}
