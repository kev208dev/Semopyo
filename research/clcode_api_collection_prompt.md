# 클로드 코드 작업 프롬프트 — data.go.kr API 대량 수집 & 세모표 통합

아래 전체를 복사해서 Claude Code에 붙여넣으세요.

---

너는 Flutter 앱 **세모표(Semopyo)** 레포에서 작업한다. 이 앱은 "브랜드·나라마다 제각각인 현실 단위(사이즈·용량·맵기·가격 등)를 공식 스펙과 체감으로 나눠 비교"해주는 앱이다. 지금 신규 도메인(자동차·화장품·가전)을 공공데이터 API로 대량 수집해서 앱에 붙이는 작업을 한다.

## 레포 데이터 파이프라인 (반드시 지킬 것)
- `data/*.csv` = 캐노니컬 소스(사람이 검증하는 원본). **모든 CSV는 UTF-8-sig(BOM) 인코딩**, 도메인 컬럼 + `reliability`(high/med/low) + `source` 컬럼을 가진다.
- `scripts/csv_to_json_assets.py` 가 `data/*.csv` → `assets/data/*.json` 으로 변환한다. **앱은 assets/data 의 JSON만 읽는다**(JSON 직접 수정 금지, 다음 빌드 때 덮어써짐).
- `lib/<도메인>_data.dart` 가 `rootBundle` 로 JSON을 로드하고, `lib/<도메인>_page.dart` 가 화면을 그린다.
- 기존 수집기: `scripts/datago_pull.py` (data.go.kr 공통규격 페이지네이션 수집기 → CSV). `DATASETS` dict에 엔드포인트가 등록돼 있다.

## 인증키 (data.go.kr 일반 인증키, 활용기간 2026-06-13~2028-06-13, 처리상태 승인)
```
<YOUR_SERVICE_KEY>
```

## 수집 대상 데이터셋
| 도메인 | data.go.kr ID | End Point | 비고 |
|---|---|---|---|
| 자동차 에너지효율등급/표시연비 | 15101093 / 15139827 | https://apis.data.go.kr/B553530/CAR (operation `CAR_01_LIST`) | 모델·제조사·연료·복합/도심/고속연비·CO2·등급. 메인 |
| 화장품 원료성분정보 | 15111774 | https://apis.data.go.kr/1471000/CsmtcsIngdInfoService01/getCsmtcsIngdInfoList01 | 성분 표준명·영문명·CAS·유래·정의 |
| 화장품 관련 정보(품목/업체) | 15020628 | https://apis.data.go.kr/1471000/CsmtcsMfcrtrInfoService01/getCsmtcsMfcrtrInfoList01 | operation 이름 불확실 → Swagger 확인 |
| 가전 고효율 에너지기자재 제품 | 15091362 | https://apis.data.go.kr/B553530/CRTIF | 제품·효율등급 |

## 작업 순서
1. **수집 실행.** 레포 루트에서 아래를 순서대로 돌린다.
   ```bash
   python3 scripts/datago_pull.py car_fuel_label       data/car_fuel_label.csv       "<YOUR_SERVICE_KEY>"
   python3 scripts/datago_pull.py cosmetic_ingredient  data/cosmetic_ingredient.csv  "<YOUR_SERVICE_KEY>"
   python3 scripts/datago_pull.py cosmetic_product     data/cosmetic_product.csv     "<YOUR_SERVICE_KEY>"
   python3 scripts/datago_pull.py appliance_efficiency data/appliance_efficiency.csv "<YOUR_SERVICE_KEY>"
   ```
2. **에러 처리.** 어떤 서비스가 `JSON 아님...` 또는 `데이터 0건`을 내면, 그 데이터셋의 data.go.kr 상세 페이지 / Swagger(`https://www.data.go.kr/data/<ID>/openapi.do`)에서 **정확한 operation 이름과 필수 파라미터**(예: `numOfRows`, `pageNo`, `type`, 추가 검색 파라미터)를 확인하고 `scripts/datago_pull.py` 의 `DATASETS` dict와 파라미터를 고쳐 재시도한다. http/https, 키 인코딩(이 키는 hex라 URL인코딩 불필요)도 점검.
3. **정규화.** 수집된 CSV는 원본 API 컬럼명 그대로다. 각 CSV에 **`reliability`, `source` 컬럼을 추가**한다(공공데이터는 `reliability=high`, `source=공공데이터포털 <ID>`). 핵심 비교 컬럼(자동차: 모델/제조사/연료/복합연비/등급, 화장품: 성분명/영문명/CAS, 가전: 제품/효율등급)만 추린 **슬림 버전**도 만들면 앱 로딩에 유리하다.
4. **JSON 변환 로직 추가.** `scripts/csv_to_json_assets.py` 에 새 도메인 변환 함수를 기존 패턴대로 추가해 `assets/data/car_fuel.json`, `cosmetic_ingredient.json`, `appliance_efficiency.json` 을 생성한다. 숫자 파싱은 기존 `_f`/`_i` 헬퍼 재사용.
5. **앱 연결(2차).** `lib/<도메인>_data.dart` 로더 + `lib/<도메인>_page.dart` 화면을 기존 도메인(예: `beverages_*`, `shoes_*`)과 동일한 구조로 추가하고, 홈 화면(`lib/main.dart`)에 진입 버튼을 단다.
6. **문서·검증.** `data/README.md` 의 데이터셋 표에 신규 도메인·행수를 추가하고, 가능하면 `scripts/validate_extra.py` 스타일로 스키마 검증을 돌린다.

## 참고: 이미 만들어둔 무(無)API 도메인 CSV (정규화 기준 동일)
`data/` 에 다음이 이미 있다 — 같은 컬럼 규칙(+reliability+source)을 따른다. JSON 변환/앱 연결 시 함께 처리하면 된다:
`airline_baggage, alcohol, beauty_perfume, beauty_sunscreen, beauty_foundation_shade, baby_diaper, baby_clothing, baby_shoes, baby_formula, pet_dog_feeding, pet_cat_feeding, pet_food_kcal, tech_tv_size, tech_usb_charger, tech_storage, tech_resolution, living_pyeong, car_fuel_economy, car_class_size, science_si_base, science_si_prefix, science_constants, science_unit_conversion` (총 23파일·495행).

먼저 1번 자동차 수집부터 실행하고 결과(행수/에러)를 보고한 뒤 다음 단계로 진행해라.
