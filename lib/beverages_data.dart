// data/beverages.csv 에서 카페체인별 size_label + volume_ml 만 뽑아 정리.
// HOT/ICE 구분: hot/iced/공용. 공식 우선 + 체감 보강.

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// 카페/음료 기본 이미지(아이스 컵 아이콘).
/// 파일을 assets/products/beverage_default.png 에 두면 자동 표시.
const String kBeverageDefaultImage = 'assets/products/beverage_default.png';

class BevSize {
  final String label;
  final int ml;
  final String temp; // 핫 | 아이스 | 공용
  const BevSize(this.label, this.ml, this.temp);
}

class BevBrand {
  final String name;
  final String emoji;
  final List<BevSize> sizes;
  const BevBrand(this.name, this.emoji, this.sizes);
}

const List<BevBrand> beverageBrands = [
  BevBrand('스타벅스', '☕', [
    BevSize('숏', 237, '공용'),
    BevSize('톨', 355, '공용'),
    BevSize('그란데', 473, '공용'),
    BevSize('벤티', 591, '핫'),
    BevSize('트렌타', 887, '아이스'),
  ]),
  BevBrand('투썸플레이스', '🍰', [
    BevSize('레귤러(핫)', 355, '핫'),
    BevSize('레귤러(아이스)', 414, '아이스'),
    BevSize('라지', 474, '공용'),
    BevSize('맥스', 591, '공용'),
  ]),
  BevBrand('이디야', '🟦', [
    BevSize('레귤러', 420, '공용'),
    BevSize('라지', 532, '공용'),
    BevSize('엑스트라', 709, '공용'),
  ]),
  BevBrand('할리스', '🟥', [
    BevSize('레귤러', 354, '공용'),
    BevSize('그란데', 472, '공용'),
    BevSize('벤티', 591, '공용'),
  ]),
  BevBrand('컴포즈커피', '🟨', [
    BevSize('14oz', 414, '공용'),
    BevSize('20oz', 591, '공용'),
    BevSize('빅포즈', 946, '아이스'),
  ]),
  BevBrand('메가커피', '🟧', [
    BevSize('기본(핫)', 500, '핫'),
    BevSize('기본(아이스)', 590, '아이스'),
    BevSize('24oz', 710, '공용'),
    BevSize('메가리카노', 960, '아이스'),
  ]),
  BevBrand('빽다방', '🤎', [
    BevSize('기본(핫)', 400, '핫'),
    BevSize('기본(아이스)', 625, '아이스'),
    BevSize('빽사이즈', 946, '아이스'),
  ]),
  BevBrand('더벤티', '🟩', [
    BevSize('라지(핫)', 570, '핫'),
    BevSize('라지(아이스)', 680, '아이스'),
    BevSize('더벤티', 955, '아이스'),
  ]),
  BevBrand('더리터', '💧', [
    BevSize('스몰리터', 414, '아이스'),
    BevSize('미니리터', 710, '아이스'),
    BevSize('리터', 946, '아이스'),
  ]),
  BevBrand('매머드커피', '🦣', [
    BevSize('S', 355, '공용'),
    BevSize('M', 473, '공용'),
    BevSize('L', 600, '공용'),
  ]),
  BevBrand('공차', '🧋', [
    BevSize('레귤러', 355, '공용'),
    BevSize('라지', 473, '아이스'),
    BevSize('점보', 700, '아이스'),
  ]),
  BevBrand('맥도날드', '🍔', [
    BevSize('콜라 S', 320, '아이스'),
    BevSize('콜라 M', 425, '아이스'),
    BevSize('콜라 L', 610, '아이스'),
  ]),
];

/// 같은 mL 와 가장 가까운 사이즈(절댓값 최소). 핫/아이스 호환 필터링.
BevSize closestSize(BevBrand brand, int targetMl, String temp) {
  final compatible = brand.sizes.where((s) =>
      s.temp == '공용' || temp == '공용' || s.temp == temp).toList();
  final pool = compatible.isEmpty ? brand.sizes : compatible;
  pool.sort((a, b) =>
      (a.ml - targetMl).abs().compareTo((b.ml - targetMl).abs()));
  return pool.first;
}

String _normalizeBev(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[\s\(\)\[\]\.\-_/]+'), '');

/// 확장된 글로벌 음료 DB 1회 로드.
/// assets/data/beverages_global.json (107건) → BevBrand 리스트로 그룹화.
Future<List<BevBrand>> loadGlobalBeverages() async {
  final raw = await rootBundle.loadString('assets/data/beverages_global.json');
  final list = jsonDecode(raw) as List;
  final byBrand = <String, List<BevSize>>{};
  for (final e in list) {
    final m = e as Map<String, dynamic>;
    final brand = (m['brand'] ?? '').toString();
    final label = (m['size_label'] ?? '').toString();
    final ml = (m['volume_ml'] as num?)?.toInt() ?? 0;
    final temp = (m['temp'] ?? '공용').toString();
    if (brand.isEmpty || ml <= 0) continue;
    byBrand.putIfAbsent(brand, () => []).add(BevSize(label, ml, temp));
  }
  return byBrand.entries
      .map((e) => BevBrand(e.key, _emojiForBrand(e.key), e.value))
      .toList();
}

String _emojiForBrand(String name) {
  for (final b in beverageBrands) {
    if (b.name == name) return b.emoji;
  }
  return '🥤';
}

/// 스캔된 제품명에서 beverageBrands 항목을 찾는다. 가장 긴 매치 우선.
BevBrand? matchBeverageBrandFromName(String? scanned) {
  if (scanned == null || scanned.isEmpty) return null;
  final n = _normalizeBev(scanned);
  if (n.isEmpty) return null;
  BevBrand? best;
  int bestLen = 0;
  for (final b in beverageBrands) {
    final bn = _normalizeBev(b.name);
    if (bn.length < 2) continue;
    if (n.contains(bn) && bn.length > bestLen) {
      best = b;
      bestLen = bn.length;
    }
  }
  return best;
}
