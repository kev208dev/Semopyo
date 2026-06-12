// data/spiciness.csv 에서 대중적 항목만 추려 정리. 범위는 중앙값.
// scoville_shu — 스코빌 척도. 로그 스케일로 시각화 권장.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  // === 추가 라면 (시중 인기) ===
  SpiceItem(name: '짜파게티', brand: '농심', shu: 200, emoji: '🍜'),
  SpiceItem(name: '짜파구리', brand: '농심', shu: 250, emoji: '🍜'),
  SpiceItem(name: '사리곰탕면', brand: '농심', shu: 400, emoji: '🍜'),
  SpiceItem(name: '진짜장', brand: '오뚜기', shu: 500, emoji: '🍜'),
  SpiceItem(name: '쇠고기미역국라면', brand: '오뚜기', shu: 600, emoji: '🍜'),
  SpiceItem(name: '참깨라면', brand: '오뚜기', shu: 700, emoji: '🍜'),
  SpiceItem(name: '컵누들 우동', brand: '오뚜기', shu: 500, emoji: '🍜'),
  SpiceItem(name: '쇠고기면', brand: '삼양식품', shu: 600, emoji: '🍜'),
  SpiceItem(name: '짜짜로니', brand: '삼양식품', shu: 350, emoji: '🍜'),
  SpiceItem(name: '도시락', brand: '팔도', shu: 1500, emoji: '🍜'),
  SpiceItem(name: '일품짜장면', brand: '팔도', shu: 600, emoji: '🍜'),
  SpiceItem(name: '왕뚜껑', brand: '팔도', shu: 2000, emoji: '🍜'),
  SpiceItem(name: '무파마탕면', brand: '농심', shu: 1800, emoji: '🍜'),
  SpiceItem(name: '스낵면', brand: '오뚜기', shu: 1500, emoji: '🍜'),
  SpiceItem(name: '진짬뽕', brand: '오뚜기', shu: 2200, emoji: '🍜'),
  SpiceItem(name: '콩나물국밥라면', brand: '오뚜기', shu: 1200, emoji: '🍜'),
  SpiceItem(name: '부대찌개라면', brand: '오뚜기', shu: 2500, emoji: '🍜'),
  SpiceItem(name: '신라면 블랙', brand: '농심', shu: 3500, emoji: '🍜'),
  SpiceItem(name: '신라면 컵', brand: '농심', shu: 3400, emoji: '🍜'),
  SpiceItem(name: '보글보글 부대찌개면', brand: '농심', shu: 2000, emoji: '🍜'),
  SpiceItem(name: '오징어짬뽕 큰사발', brand: '농심', shu: 2300, emoji: '🍜'),
  SpiceItem(name: '김치불닭볶음면', brand: '삼양식품', shu: 3200, emoji: '🔥'),
  SpiceItem(name: '야끼소바불닭볶음면', brand: '삼양식품', shu: 3000, emoji: '🔥'),
  SpiceItem(name: '커리불닭볶음면', brand: '삼양식품', shu: 3100, emoji: '🔥'),
  SpiceItem(name: '치즈불닭볶음면', brand: '삼양식품', shu: 2755, emoji: '🔥'),
  SpiceItem(name: '쿨불닭볶음면', brand: '삼양식품', shu: 2200, emoji: '🍜'),
  SpiceItem(name: '핵불닭소스', brand: '삼양식품', shu: 12000, emoji: '🥫'),
  SpiceItem(name: '불닭소스', brand: '삼양식품', shu: 4404, emoji: '🥫'),
  SpiceItem(name: '순창고추장', brand: '청정원', shu: 6000, emoji: '🥫'),
  SpiceItem(name: '해찬들고추장', brand: '청정원', shu: 6000, emoji: '🥫'),
  SpiceItem(name: '비비고 김치찌개', brand: 'CJ', shu: 1800, emoji: '🍲'),
  SpiceItem(name: '비비고 사골곰탕', brand: 'CJ', shu: 300, emoji: '🍲'),
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

String _normalizeName(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[\s\(\)\[\]\.\-_/]+'), '');

/// DB 분류 + 제품명 기반 추정 SpiceItem. 정적 리스트에 없는 매운 제품 커버.
SpiceItem? buildEstimatedSpice(String? name, String? classification) {
  if (name == null || name.isEmpty) return null;
  final cls = (classification ?? '').toLowerCase();
  final nm = name.toLowerCase();
  bool inAny(List<String> kws) =>
      kws.any((k) => nm.contains(k) || cls.contains(k));

  // 매운 키워드 강도순
  if (inAny(['핵불닭', '하바네로', '캐롤라이나'])) {
    return SpiceItem(name: name, brand: '스캔 제품(추정)',
        shu: 10000, emoji: '☢️');
  }
  if (inAny(['불닭', '엽기'])) {
    return SpiceItem(name: name, brand: '스캔 제품(추정)',
        shu: 5000, emoji: '🔥');
  }
  if (inAny(['청양', '매운맛', '매운', '핫', '스파이시'])) {
    return SpiceItem(name: name, brand: '스캔 제품(추정)',
        shu: 4000, emoji: '🌶️');
  }
  if (inAny(['고추장', '고추가루', '고춧가루'])) {
    return SpiceItem(name: name, brand: '스캔 제품(추정)',
        shu: 6000, emoji: '🥫');
  }
  if (inAny(['짬뽕', '얼큰', '마라'])) {
    return SpiceItem(name: name, brand: '스캔 제품(추정)',
        shu: 2500, emoji: '🍜');
  }
  if (inAny(['떡볶이'])) {
    return SpiceItem(name: name, brand: '스캔 제품(추정)',
        shu: 3500, emoji: '🌶️');
  }
  if (cls.contains('소스')) {
    return SpiceItem(name: name, brand: '스캔 제품(추정)',
        shu: 2000, emoji: '🥫');
  }
  if (cls.contains('장류')) {
    return SpiceItem(name: name, brand: '스캔 제품(추정)',
        shu: 1500, emoji: '🥫');
  }
  if (cls.contains('면류')) {
    return SpiceItem(name: name, brand: '스캔 제품(추정)',
        shu: 1500, emoji: '🍜');
  }
  return null; // 맵기 추정 불가
}

/// 스캔된 제품명에서 spiceItems 항목을 찾는다. 가장 긴 매치 우선.
SpiceItem? matchSpiceFromName(String? scanned) {
  if (scanned == null || scanned.isEmpty) return null;
  final n = _normalizeName(scanned);
  if (n.isEmpty) return null;
  SpiceItem? best;
  int bestLen = 0;
  for (final s in spiceItems) {
    final sn = _normalizeName(s.name);
    if (sn.length < 2) continue;
    if (n.contains(sn) && sn.length > bestLen) {
      best = s;
      bestLen = sn.length;
    }
  }
  return best;
}

/// 확장 맵기 DB 1회 로드 (assets/data/spiciness_global.json, 62건).
/// 한글 매핑이 없는 글로벌 항목 다수 포함.
Future<List<SpiceItem>> loadGlobalSpice() async {
  final raw = await rootBundle.loadString('assets/data/spiciness_global.json');
  final list = jsonDecode(raw) as List;
  return list.map<SpiceItem>((e) {
    final m = e as Map<String, dynamic>;
    final shu = (m['shu'] as num?)?.toInt() ?? 0;
    return SpiceItem(
      name: (m['item'] ?? '').toString(),
      brand: (m['brand'] ?? '').toString(),
      shu: shu,
      emoji: _emojiForShu(shu, (m['category'] ?? '').toString()),
    );
  }).where((s) => s.shu > 0 && s.name.isNotEmpty).toList();
}

String _emojiForShu(int shu, String cat) {
  if (cat.contains('스낵')) return '🍿';
  if (cat.contains('소스') || cat.contains('양념')) return '🥫';
  if (cat.contains('떡볶이')) return '🌶️';
  if (cat.contains('라면') || cat.contains('면')) {
    if (shu >= 100000) return '💀';
    if (shu >= 10000) return '☢️';
    if (shu >= 4000) return '🔥';
    return '🍜';
  }
  if (shu >= 1000000) return '💀';
  if (shu >= 100000) return '☢️';
  if (shu >= 10000) return '🔥';
  return '🌶️';
}
