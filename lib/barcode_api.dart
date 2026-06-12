// 바코드 → 제품정보 조회 + 카테고리 라우팅.
//
// 데이터 출처: 식품의약품안전처 "유통바코드" OpenAPI (식품안전나라, 서비스 I2570).
//   엔드포인트: https://openapi.foodsafetykorea.go.kr/api/{KEY}/I2570/json/{start}/{end}/BRCD_NO={바코드}
//   응답(JSON): { "I2570": { "total_count": "...", "row": [ {...} ], "RESULT": {"CODE","MSG"} } }
//
// ⚠️ 커버리지 한계: 이 무료 API는 2018년까지 등록분 위주라 최신 제품은 조회 안 되는 경우가 많다.
//   조회 실패 시 반드시 수동 카테고리 선택으로 폴백한다 (UI에서 처리).
//   완전한 최신 커버리지가 필요하면 GS1 코리안넷(유료 제휴)로 교체한다.
//
// 🔑 인증키 발급(무료, 즉시): https://www.foodsafetykorea.go.kr/apiMain.do 회원가입 →
//   API 신청에서 "유통바코드(I2570)" 활용신청 → 발급된 키를 아래 kFoodSafetyApiKey 에 넣는다.

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'barcode_local_db.dart';

/// 식품안전나라 OpenAPI 인증키. 발급 후 여기에 넣으세요.
/// (테스트용으로 'sample' 입력 시 일부 서비스에서 샘플데이터가 반환됩니다.)
const String kFoodSafetyApiKey = '4930aea774dd431ebf92';

const String _serviceId = 'I2570';

/// 앱의 비교 카테고리.
enum BarcodeCategory { beverage, spiciness, portion, pizza, unknown }

/// 조회 출처.
enum BarcodeSource { foodSafetyKorea, openFoodFacts }

/// 바코드로 조회한 제품 정보.
class BarcodeProduct {
  final String barcode;
  final String productName; // PRDT_NM
  final String company; // CMPNY_NM
  final String reportNo; // PRDLST_REPORT_NO (품목보고번호)
  final String classification; // PRDLST_NM / 품목분류 (있으면)
  final String imageUrl; // (Open Food Facts 등) 제품 이미지
  final BarcodeSource source;

  const BarcodeProduct({
    required this.barcode,
    required this.productName,
    required this.company,
    required this.reportNo,
    required this.classification,
    this.imageUrl = '',
    this.source = BarcodeSource.foodSafetyKorea,
  });

  bool get isEmpty => productName.isEmpty && reportNo.isEmpty;
}

/// 조회 결과 상태.
enum BarcodeLookupStatus { found, notFound, missingKey, networkError }

class BarcodeLookupResult {
  final BarcodeLookupStatus status;
  final BarcodeProduct? product;
  final String? message;
  const BarcodeLookupResult(this.status, {this.product, this.message});
}

/// 바코드로 제품을 조회한다. 실패해도 예외를 던지지 않고 상태로 표현.
///
/// 순서: ① 식약처 유통바코드(키 있을 때) → ② Open Food Facts(키 불필요 폴백).
/// 둘 다 없으면 notFound. 식약처 키가 없으면 OFF만 시도한다.
Future<BarcodeLookupResult> lookupBarcode(String barcode) async {
  final code = barcode.trim();
  final hasKey = kFoodSafetyApiKey.isNotEmpty &&
      kFoodSafetyApiKey != 'YOUR_FOODSAFETY_API_KEY';

  // ① 오프라인 내장 DB (식약처 유통바코드 51k 스냅샷) — 즉시·무네트워크
  final local = await BarcodeLocalDb.instance.lookup(code);
  if (local != null) {
    return BarcodeLookupResult(BarcodeLookupStatus.found, product: local);
  }

  // ② 식약처 유통바코드 실시간 (키 있을 때)
  if (hasKey) {
    final r = await _lookupFoodSafety(code);
    if (r.status == BarcodeLookupStatus.found) return r;
  }

  // ③ Open Food Facts 폴백 (키 불필요)
  final off = await _lookupOpenFoodFacts(code);
  if (off.status == BarcodeLookupStatus.found) return off;

  // 둘 다 실패
  if (!hasKey) {
    return const BarcodeLookupResult(
      BarcodeLookupStatus.notFound,
      message: '식약처 키 미설정 + 공개 DB에도 없는 제품이에요. '
          'lib/barcode_api.dart 의 kFoodSafetyApiKey 를 채우면 조회율이 올라가요.',
    );
  }
  return const BarcodeLookupResult(BarcodeLookupStatus.notFound);
}

/// Open Food Facts (전세계 오픈 DB, 키 불필요, 한국 커버리지는 낮음).
Future<BarcodeLookupResult> _lookupOpenFoodFacts(String code) async {
  final url = Uri.parse(
    'https://world.openfoodfacts.org/api/v2/product/$code.json'
    '?fields=product_name,product_name_ko,brands,quantity,image_url',
  );
  try {
    final resp = await http.get(url).timeout(const Duration(seconds: 8));
    if (resp.statusCode != 200) {
      return const BarcodeLookupResult(BarcodeLookupStatus.notFound);
    }
    final json = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    if (json['status'] != 1 || json['product'] is! Map) {
      return const BarcodeLookupResult(BarcodeLookupStatus.notFound);
    }
    final pr = json['product'] as Map<String, dynamic>;
    String f(String k) => (pr[k] ?? '').toString().trim();
    final name = f('product_name_ko').isNotEmpty
        ? f('product_name_ko')
        : f('product_name');
    if (name.isEmpty) {
      return const BarcodeLookupResult(BarcodeLookupStatus.notFound);
    }
    return BarcodeLookupResult(
      BarcodeLookupStatus.found,
      product: BarcodeProduct(
        barcode: code,
        productName: name,
        company: f('brands'),
        reportNo: '',
        classification: f('quantity'),
        imageUrl: f('image_url'),
        source: BarcodeSource.openFoodFacts,
      ),
    );
  } catch (_) {
    return const BarcodeLookupResult(BarcodeLookupStatus.notFound);
  }
}

/// 식약처 유통바코드(I2570) 조회.
Future<BarcodeLookupResult> _lookupFoodSafety(String code) async {
  final url = Uri.parse(
    'https://openapi.foodsafetykorea.go.kr/api/'
    '$kFoodSafetyApiKey/$_serviceId/json/1/5/BRCD_NO=$code',
  );

  try {
    final resp = await http.get(url).timeout(const Duration(seconds: 8));
    if (resp.statusCode != 200) {
      return BarcodeLookupResult(BarcodeLookupStatus.networkError,
          message: 'HTTP ${resp.statusCode}');
    }
    final Map<String, dynamic> json =
        jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;

    // 키 오류 등 최상위 RESULT 에 에러가 실리는 경우
    final topResult = json['RESULT'];
    if (topResult is Map && topResult['CODE'] != null) {
      final codeStr = topResult['CODE'].toString();
      if (!codeStr.startsWith('INFO')) {
        return BarcodeLookupResult(BarcodeLookupStatus.networkError,
            message: topResult['MSG']?.toString() ?? codeStr);
      }
    }

    final svc = json[_serviceId];
    if (svc is! Map) {
      return const BarcodeLookupResult(BarcodeLookupStatus.notFound);
    }

    // 데이터 없음 코드(INFO-200) 처리
    final svcResult = svc['RESULT'];
    if (svcResult is Map && svcResult['CODE'] != null) {
      final codeStr = svcResult['CODE'].toString();
      if (codeStr.contains('200')) {
        return const BarcodeLookupResult(BarcodeLookupStatus.notFound);
      }
    }

    final rows = svc['row'];
    if (rows is! List || rows.isEmpty) {
      return const BarcodeLookupResult(BarcodeLookupStatus.notFound);
    }

    final row = rows.first as Map<String, dynamic>;
    String f(String k) => (row[k] ?? '').toString().trim();

    final product = BarcodeProduct(
      barcode: f('BRCD_NO').isNotEmpty ? f('BRCD_NO') : code,
      productName: f('PRDT_NM'),
      company: f('CMPNY_NM'),
      reportNo: f('PRDLST_REPORT_NO'),
      classification: f('PRDLST_NM'),
    );

    if (product.isEmpty) {
      return const BarcodeLookupResult(BarcodeLookupStatus.notFound);
    }
    return BarcodeLookupResult(BarcodeLookupStatus.found, product: product);
  } catch (e) {
    return BarcodeLookupResult(BarcodeLookupStatus.networkError,
        message: e.toString());
  }
}

/// 제품명/식품유형(HRNK_PRDLST_NM) 키워드로 비교 카테고리를 추정한다.
/// classification 에는 식약처 식품유형 분류(예: "음료류","면류","소스류")가 들어온다.
BarcodeCategory categoryForProduct(BarcodeProduct p) {
  final text = '${p.productName} ${p.classification}';
  bool has(List<String> kws) => kws.any(text.contains);

  // 피자 우선 (즉석식품에 묻히지 않도록)
  if (has(const ['피자'])) return BarcodeCategory.pizza;

  // 음료 — 식품유형: 음료류/다류/두유류/탄산음료류/과일.채소류음료
  if (has(const [
    '음료', '다류', '두유', '탄산', '주스', '커피', '우유',
    '사이다', '콜라', '이온', '에이드', '드링크', '워터', '차류',
  ])) {
    return BarcodeCategory.beverage;
  }

  // 맵기 — 식품유형: 소스류/장류/고춧가루/향신료, 매운 제품 키워드
  if (has(const [
    '고춧가루', '실고추', '향신료', '고추장', '핫소스', '불닭',
    '마라', '떡볶이', '짬뽕', '소스류', '청양', '매운',
  ])) {
    return BarcodeCategory.spiciness;
  }

  // 1인분/제공량 — 대부분의 가공식품 식품유형
  if (has(const [
    '과자', '빵류', '떡류', '면류', '라면', '즉석', '편의식품',
    '만두', '수산가공', '어육', '건포', '식육가공', '시리얼',
    '초콜릿', '스낵', '도시락', '밥', '죽', '김밥', '햄버거',
    '아이스크림', '빙과', '견과', '잼류', '두부', '묵',
  ])) {
    return BarcodeCategory.portion;
  }

  return BarcodeCategory.unknown;
}

/// 카테고리 한글 라벨.
String categoryLabel(BarcodeCategory c) {
  switch (c) {
    case BarcodeCategory.beverage:
      return '음료';
    case BarcodeCategory.spiciness:
      return '맵기';
    case BarcodeCategory.portion:
      return '1인분';
    case BarcodeCategory.pizza:
      return '피자';
    case BarcodeCategory.unknown:
      return '';
  }
}
