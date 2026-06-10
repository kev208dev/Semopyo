// data/spiciness.csv 에서 대중적 항목만 추려 정리. 범위는 중앙값.
// scoville_shu — 스코빌 척도. 로그 스케일로 시각화 권장.

import 'package:flutter/material.dart';

/// 상품 이미지가 없는 맵기 항목의 기본 이미지(빨간 고추+불꽃 아이콘).
const String kSpiceDefaultImage = 'assets/products/spice_default.png';

const String _spiceImgRamen  = 'assets/products/ramen.png';
const String _spiceImgChili  = 'assets/products/chili.png';
const String _spiceImgSauce  = 'assets/products/sauce.png';
const String _spiceImgPop    = 'assets/products/popcorn.png';
const String _spiceImgTteok  = 'assets/products/tteokbokki.png';

/// SpiceItem 의 이모지/이름 기반으로 카테고리 이미지를 결정.
String spiceImageFor(SpiceItem s) {
  if (s.image.isNotEmpty) return s.image;
  if (s.name.contains('떡볶이')) return _spiceImgTteok;
  switch (s.emoji) {
    case '🍜':
    case '🔥':
    case '☢️':
    case '👑':
    case '😈':
    case '💀':
      return _spiceImgRamen;
    case '🥡':
      return _spiceImgRamen;
    case '🥫':
      return _spiceImgSauce;
    case '🌶️':
      return _spiceImgChili;
    case '🍿':
      return _spiceImgPop;
  }
  return kSpiceDefaultImage;
}

class SpiceItem {
  final String name;
  final String brand;
  final int shu;
  final String emoji;
  /// 상품 이미지(번들 에셋 경로 또는 URL). 없으면 브랜드 로고로 폴백.
  final String image;
  /// 기준선(고추/캡사이신/타바스코 등)이면 true.
  final bool reference;
  const SpiceItem({
    required this.name,
    required this.brand,
    required this.shu,
    required this.emoji,
    this.image = '',
    this.reference = false,
  });
}

const List<SpiceItem> spiceItems = [
  // 순한 라면 / 베이스라인
  SpiceItem(name: '안성탕면', brand: '농심', shu: 570, emoji: '🍜'),
  SpiceItem(name: '진라면 순한맛', brand: '오뚜기', shu: 640, emoji: '🍜'),
  SpiceItem(name: '삼양라면', brand: '삼양식품', shu: 950, emoji: '🍜'),
  SpiceItem(name: '너구리', brand: '농심', shu: 2300, emoji: '🍜'),
  SpiceItem(name: '오징어짬뽕', brand: '농심', shu: 2300, emoji: '🍜'),
  SpiceItem(name: '진라면 매운맛', brand: '오뚜기', shu: 2500, emoji: '🍜'),
  SpiceItem(name: '팔도비빔면', brand: '팔도', shu: 2652, emoji: '🥡'),
  SpiceItem(name: '팔도 쫄비빔면', brand: '팔도', shu: 2769, emoji: '🥡'),
  SpiceItem(name: '삼양라면 매운맛', brand: '삼양식품', shu: 3000, emoji: '🍜'),
  SpiceItem(name: '신라면', brand: '농심', shu: 3400, emoji: '🍜'),
  // 매움 라인
  SpiceItem(name: '짜장불닭볶음면', brand: '삼양식품', shu: 2000, emoji: '🍜'),
  SpiceItem(name: '까르보불닭볶음면', brand: '삼양식품', shu: 2350, emoji: '🍜'),
  SpiceItem(name: '치즈불닭볶음면(큰컵)', brand: '삼양식품', shu: 2755, emoji: '🍜'),
  SpiceItem(name: '불닭볶음면(큰컵)', brand: '삼양식품', shu: 3210, emoji: '🔥'),
  SpiceItem(name: '마라불닭볶음면', brand: '삼양식품', shu: 4400, emoji: '🔥'),
  SpiceItem(name: '불닭볶음면', brand: '삼양식품', shu: 4404, emoji: '🔥'),
  SpiceItem(name: '불닭볶음탕면', brand: '삼양식품', shu: 4705, emoji: '🔥'),
  SpiceItem(name: '열라면', brand: '오뚜기', shu: 5013, emoji: '🍜'),
  SpiceItem(name: '괄도네넴띤', brand: '팔도', shu: 5894, emoji: '🥡'),
  SpiceItem(name: '도전 하바네로라면', brand: '이마트', shu: 5930, emoji: '🍜'),
  SpiceItem(name: '맵탱', brand: '삼양식품', shu: 6000, emoji: '🍜'),
  SpiceItem(name: '앵그리 너구리', brand: '농심', shu: 6080, emoji: '🍜'),
  SpiceItem(name: '핵불닭볶음면(큰컵)', brand: '삼양식품', shu: 6504, emoji: '☢️'),
  SpiceItem(name: '신라면 더 레드', brand: '농심', shu: 7500, emoji: '🔥'),
  SpiceItem(name: '장인라면 맵싸한맛', brand: '하림', shu: 8000, emoji: '🍜'),
  SpiceItem(name: '핵불닭볶음면', brand: '삼양식품', shu: 10000, emoji: '☢️'),
  SpiceItem(name: '핵불닭볶음면 미니', brand: '삼양식품', shu: 12000, emoji: '☢️'),
  SpiceItem(name: '킹뚜껑', brand: '팔도', shu: 12000, emoji: '👑'),
  SpiceItem(name: '핵불닭볶음면 3x', brand: '삼양식품(수출)', shu: 13000, emoji: '☢️'),
  SpiceItem(name: '틈새라면 빨계떡', brand: '팔도', shu: 9413, emoji: '🍜'),
  SpiceItem(name: '불마왕라면', brand: '금비유통', shu: 14444, emoji: '😈'),
  SpiceItem(name: '염라대왕라면', brand: '아름', shu: 21000, emoji: '💀'),
  // 떡볶이/소스
  SpiceItem(name: '엽기떡볶이 오리지널', brand: '엽기떡볶이', shu: 4000, emoji: '🌶️'),
  SpiceItem(name: '엽기떡볶이 매운맛', brand: '엽기떡볶이', shu: 9000, emoji: '🌶️'),
  SpiceItem(name: '타바스코 소스', brand: '맥일레니', shu: 3750, emoji: '🥫'),
  SpiceItem(name: '파퀴칩(죽음의 과자)', brand: 'Paqui', shu: 2100000, emoji: '🍿'),
  // 기준선 (고추류)
  SpiceItem(name: '풋고추', brand: '기준선', shu: 1500, emoji: '🌶️', reference: true),
  SpiceItem(name: '할라피뇨', brand: '기준선', shu: 6250, emoji: '🌶️', reference: true),
  SpiceItem(name: '청양고추', brand: '기준선', shu: 10000, emoji: '🌶️', reference: true),
  SpiceItem(name: '부트졸로키아(귀신고추)', brand: '기준선', shu: 540000, emoji: '🌶️', reference: true),
  SpiceItem(name: '캐롤라이나 리퍼', brand: '기준선', shu: 1885000, emoji: '🌶️', reference: true),
  SpiceItem(name: '순수 캡사이신', brand: '기준선', shu: 15500000, emoji: '🌶️', reference: true),
];

/// 0~5 단계 변환. 신라면 미만=1, 불닭=3, 핵불닭=4, 그 이상=5.
int spiceLevel(int shu) {
  if (shu < 1500) return 1;
  if (shu < 3500) return 2;
  if (shu < 5500) return 3;
  if (shu < 10000) return 4;
  return 5;
}

String spiceLabel(int level) =>
    const ['', '순한맛', '약간매움', '매움', '많이매움', '극강매움'][level];

Color spiceColor(int level) {
  switch (level) {
    case 1: return const Color(0xFFFFE082);
    case 2: return const Color(0xFFFFB74D);
    case 3: return const Color(0xFFFF7043);
    case 4: return const Color(0xFFE53935);
    case 5: return const Color(0xFF7B1FA2);
    default: return Colors.white;
  }
}
