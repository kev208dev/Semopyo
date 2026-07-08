import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const pizzaList = [
  dominoPizzaL,
  dominoPizzaM,
  dominoPizzaR,

  pizzaHutPizzaL,
  pizzaHutPizzaM,
  pizzaHutPizzaR,

  papajohnsPizzaL,
  papajohnsPizzaM,

  mrPizzaL,
  mrPizzaM,
];

const dominoPizzaL = {
  'name': '도미노피자',
  'pizzaName': '슈퍼디럭스',
  'size': 'L',
  'diameter': 33.0,
  'price': 28900,
  'thumbnail': 'assets/images/domino.png',
  'logo': 'assets/images/domino_logo.png',
};

const dominoPizzaM = {
  'name': '도미노피자',
  'pizzaName': '슈퍼디럭스',
  'size': 'M',
  'diameter': 28.0,
  'price': 22900,
  'thumbnail': 'assets/images/domino.png',
  'logo': 'assets/images/domino_logo.png',
};

const dominoPizzaR = {
  'name': '도미노피자',
  'pizzaName': '포테이토',
  'size': 'R',
  'diameter': 25.0,
  'price': 19900,
  'thumbnail': 'assets/images/domino.png',
  'logo': 'assets/images/domino_logo.png',
};

const pizzaHutPizzaL = {
  'name': '피자헛',
  'pizzaName': '팬피자',
  'size': 'L',
  'diameter': 31.0,
  'price': 27900,
  'thumbnail': 'assets/images/pizzahut.png',
  'logo': 'assets/images/pizzahut_logo.png',
};

const pizzaHutPizzaM = {
  'name': '피자헛',
  'pizzaName': '팬피자',
  'size': 'M',
  'diameter': 26.0,
  'price': 21900,
  'thumbnail': 'assets/images/pizzahut.png',
  'logo': 'assets/images/pizzahut_logo.png',
};

const pizzaHutPizzaR = {
  'name': '피자헛',
  'pizzaName': '페퍼로니',
  'size': 'R',
  'diameter': 23.0,
  'price': 18900,
  'thumbnail': 'assets/images/pizzahut.png',
  'logo': 'assets/images/pizzahut_logo.png',
};

const papajohnsPizzaL = {
  'name': '파파존스',
  'pizzaName': '슈퍼파파스',
  'size': 'L',
  'diameter': 30.0,
  'price': 29500,
  'thumbnail': 'assets/images/papajohns.png',
  'logo': 'assets/images/papajohns_logo.png',
};

const papajohnsPizzaM = {
  'name': '파파존스',
  'pizzaName': '슈퍼파파스',
  'size': 'M',
  'diameter': 26.0,
  'price': 23500,
  'thumbnail': 'assets/images/papajohns.png',
  'logo': 'assets/images/papajohns_logo.png',
};

const mrPizzaL = {
  'name': '미스터피자',
  'pizzaName': '포테이토골드',
  'size': 'L',
  'diameter': 32.0,
  'price': 29900,
  'thumbnail': 'assets/images/mrpizza.png',
  'logo': 'assets/images/mrpizza_logo.png',
};

const mrPizzaM = {
  'name': '미스터피자',
  'pizzaName': '포테이토골드',
  'size': 'M',
  'diameter': 27.0,
  'price': 23900,
  'thumbnail': 'assets/images/mrpizza.png',
  'logo': 'assets/images/mrpizza_logo.png',
};

// === 전세계 피자 데이터셋 (assets/pizza_global.json 65건, 19개 브랜드) ===

/// 브랜드명 → 번들 썸네일 경로. 없으면 빈 문자열 (UI에서 이모지 폴백).
String pizzaThumbnailFor(String brand) {
  switch (brand) {
    case '도미노피자':
      return 'assets/images/domino.png';
    case '피자헛':
      return 'assets/images/pizzahut.png';
    case '파파존스':
      return 'assets/images/papajohns.png';
    case '미스터피자':
      return 'assets/images/mrpizza.png';
  }
  return '';
}

/// 브랜드별 로고 색상.
const Map<String, Color> _brandColors = {
  '도미노피자': Color(0xFF006491),
  '피자헛': Color(0xFFE3000F),
  '파파존스': Color(0xFF00733E),
  '미스터피자': Color(0xFFD4A11A),
  '피자스쿨': Color(0xFF1E88E5),
  '피자마루': Color(0xFFEF6C00),
  '빨간모자피자': Color(0xFFD32F2F),
  '7번가피자': Color(0xFF1976D2),
  '피자라': Color(0xFF2E7D32),
  '피자알볼로': Color(0xFF1A237E),
  '라운드테이블': Color(0xFF8D6E63),
  '리틀시저스': Color(0xFFFF6F00),
  '마르코스피자': Color(0xFF5D4037),
  '반올림피자': Color(0xFFAD1457),
  '스바로': Color(0xFFC62828),
  '시시스': Color(0xFFE91E63),
  '아오키스피자': Color(0xFF00838F),
  '제츠피자': Color(0xFFFFA000),
  '청년피자': Color(0xFF388E3C),
  '코스트코': Color(0xFFE53935),
  '파파머피스': Color(0xFF6A1B9A),
  '피자비스트로': Color(0xFFF57C00),
  '헝그리하우이스': Color(0xFFFF8F00),
  '고피자': Color(0xFFF9A825),
  '나폴리 정통피자': Color(0xFFC62828),
  '임실치즈피자': Color(0xFFFBC02D),
};

/// 브랜드명 → 짧은 라벨 (1~2자).
String _brandShortLabel(String brand) {
  switch (brand) {
    case '도미노피자':
      return 'D';
    case '피자헛':
      return 'PH';
    case '파파존스':
      return 'PJ';
    case '미스터피자':
      return 'MR';
    case '피자스쿨':
      return 'PS';
    case '피자마루':
      return 'PM';
    case '7번가피자':
      return '7';
    case '피자라':
      return 'PR';
    case '피자알볼로':
      return 'AV';
    case '라운드테이블':
      return 'RT';
    case '리틀시저스':
      return 'LC';
    case '마르코스피자':
      return 'MK';
    case '스바로':
      return 'SB';
    case '시시스':
      return 'CC';
    case '아오키스피자':
      return 'AK';
    case '제츠피자':
      return 'JT';
    case '청년피자':
      return 'CN';
    case '코스트코':
      return 'CO';
    case '파파머피스':
      return 'PP';
    case '헝그리하우이스':
      return 'HH';
    case '고피자':
      return 'GO';
    case '나폴리 정통피자':
      return 'NP';
    case '임실치즈피자':
      return 'IS';
    case '반올림피자':
      return 'BO';
    case '빨간모자피자':
      return 'RH';
  }
  if (brand.isEmpty) return '?';
  return brand.characters.first;
}

/// 브랜드명 → 로고 색상. 없으면 해시 기반 폴백 색.
Color brandLogoColor(String brand) {
  final c = _brandColors[brand];
  if (c != null) return c;
  final palette = [
    const Color(0xFF1E88E5),
    const Color(0xFF43A047),
    const Color(0xFFFB8C00),
    const Color(0xFF8E24AA),
    const Color(0xFFE53935),
    const Color(0xFF00897B),
  ];
  return palette[brand.hashCode.abs() % palette.length];
}

/// 브랜드 로고 원형 위젯. 색배경 + 짧은 라벨.
Widget pizzaBrandLogo(String brand, double size, {bool ring = false}) {
  final color = brandLogoColor(brand);
  final label = _brandShortLabel(brand);
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(Colors.white.withAlpha(40), color),
          color,
        ],
      ),
      border: ring
          ? Border.all(color: Colors.white, width: 2)
          : Border.all(color: Colors.white.withAlpha(60), width: 1),
      boxShadow: [
        BoxShadow(
          color: color.withAlpha(120),
          blurRadius: size * 0.18,
          offset: Offset(0, size * 0.06),
        ),
      ],
    ),
    child: Text(
      label,
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.42,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ),
  );
}

/// 전세계 피자 JSON 1회 로드 + KR 가격표 병합.
/// - pizza_global.json (145건 사이즈/지름/추정가)
/// - kr_pizza_prices.json (26건 KR 실제 메뉴/가격) → brand+size_label 매칭 시 가격/메뉴명 덮어쓰기
Future<List<Map<String, dynamic>>> loadGlobalPizzas() async {
  final krPrices = await _loadKrPizzaPriceMap();
  final raw = await rootBundle.loadString('assets/data/pizza_global.json');
  final list = jsonDecode(raw) as List;
  return list.map<Map<String, dynamic>>((e) {
    final m = e as Map<String, dynamic>;
    final brand = (m['brand'] ?? '').toString();
    final size = (m['size_label'] ?? '').toString();
    final dia = (m['diameter_cm'] as num).toDouble();
    int price = (m['price'] is num) ? (m['price'] as num).toInt() : 0;
    String pizzaName = (m['brand_en'] ?? '').toString();
    final krKey = '$brand|$size';
    final kr = krPrices[krKey];
    if (kr != null) {
      final krPrice = (kr['price_krw'] as num?)?.toInt() ?? 0;
      if (krPrice > 0) price = krPrice;
      final krMenu = (kr['menu'] ?? '').toString();
      if (krMenu.isNotEmpty) pizzaName = krMenu;
    }
    return {
      'name': brand,
      'pizzaName': pizzaName,
      'size': size,
      'diameter': dia,
      'price': price,
      'thumbnail': pizzaThumbnailFor(brand),
      'logo': pizzaThumbnailFor(brand),
      'slices': m['slices'] is num ? (m['slices'] as num).toInt() : 8,
      'kcalPerSlice':
          m['calories_per_slice'] is num ? (m['calories_per_slice'] as num).toInt() : null,
      'country': (m['country'] ?? '').toString(),
      'source': 'global',
    };
  }).toList();
}

Future<Map<String, Map<String, dynamic>>> _loadKrPizzaPriceMap() async {
  try {
    final raw =
        await rootBundle.loadString('assets/data/kr_pizza_prices.json');
    final list = jsonDecode(raw) as List;
    final m = <String, Map<String, dynamic>>{};
    for (final e in list) {
      final r = e as Map<String, dynamic>;
      final brand = (r['brand'] ?? '').toString();
      final size = (r['size_label'] ?? '').toString();
      if (brand.isEmpty || size.isEmpty) continue;
      m['$brand|$size'] = r;
    }
    return m;
  } catch (_) {
    return const {};
  }
}

/// 냉동피자 17종 로드. 기존 피자 schema와 호환.
Future<List<Map<String, dynamic>>> loadFrozenPizzas() async {
  final raw = await rootBundle.loadString('assets/data/pizza_frozen.json');
  final list = jsonDecode(raw) as List;
  return list.map<Map<String, dynamic>>((e) {
    final m = e as Map<String, dynamic>;
    final brand = (m['brand'] ?? '').toString();
    final product = (m['product'] ?? '').toString();
    final diaRaw = m['diameter_cm'];
    final weightRaw = m['weight_g'];
    final dia = diaRaw is num
        ? diaRaw.toDouble()
        : (weightRaw is num ? _diameterFromWeight(weightRaw.toDouble()) : 0.0);
    return {
      'name': brand,
      'pizzaName': product,
      'size': '냉동',
      'diameter': dia,
      'price': 0,
      'thumbnail': pizzaThumbnailFor(brand),
      'logo': pizzaThumbnailFor(brand),
      'slices': 6,
      'kcalPerSlice': null,
      'weight_g': weightRaw is num ? weightRaw.toInt() : null,
      'country': (m['country'] ?? '').toString(),
      'source': 'frozen',
    };
  }).toList();
}

/// 냉동피자는 지름 미상 → 무게에서 추정 (밀도 0.6 g/cm²).
double _diameterFromWeight(double g) {
  final area = g / 0.6;
  return 2 * math.sqrt(area / math.pi);
}
