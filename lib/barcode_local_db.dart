// 오프라인 바코드 DB (식약처 유통바코드 I2570, 51,158건 스냅샷).
// assets/barcode_db.json 을 1회 로드해 메모리 맵으로 캐시한다.
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'barcode_api.dart';

class BarcodeLocalDb {
  BarcodeLocalDb._();
  static final BarcodeLocalDb instance = BarcodeLocalDb._();

  Map<String, dynamic>? _db;
  Future<void>? _loading;

  Future<void> _ensureLoaded() {
    if (_db != null) return Future.value();
    return _loading ??= rootBundle
        .loadString('assets/barcode_db.json')
        .then((s) => _db = jsonDecode(s) as Map<String, dynamic>);
  }

  /// 로컬 DB에서 바코드 조회. 없으면 null.
  Future<BarcodeProduct?> lookup(String barcode) async {
    await _ensureLoaded();
    final raw = _db?[barcode.trim()];
    if (raw is! Map) return null;
    return BarcodeProduct(
      barcode: barcode.trim(),
      productName: (raw['n'] ?? '').toString(),
      company: (raw['c'] ?? '').toString(),
      reportNo: (raw['r'] ?? '').toString(),
      classification: (raw['cat'] ?? '').toString(),
      source: BarcodeSource.foodSafetyKorea,
    );
  }

  /// 제품명/회사명/분류로 부분 일치 검색. 51k 전체 순회.
  Future<List<BarcodeProduct>> searchByName(String query,
      {int limit = 50}) async {
    await _ensureLoaded();
    final db = _db;
    if (db == null) return const [];
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final results = <BarcodeProduct>[];
    for (final entry in db.entries) {
      final raw = entry.value;
      if (raw is! Map) continue;
      final name = (raw['n'] ?? '').toString().toLowerCase();
      final company = (raw['c'] ?? '').toString().toLowerCase();
      final cat = (raw['cat'] ?? '').toString().toLowerCase();
      if (name.contains(q) || company.contains(q) || cat.contains(q)) {
        results.add(BarcodeProduct(
          barcode: entry.key,
          productName: (raw['n'] ?? '').toString(),
          company: (raw['c'] ?? '').toString(),
          reportNo: (raw['r'] ?? '').toString(),
          classification: (raw['cat'] ?? '').toString(),
          source: BarcodeSource.foodSafetyKorea,
        ));
        if (results.length >= limit) break;
      }
    }
    return results;
  }
}
