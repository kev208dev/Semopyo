# 세모표 데이터셋

한국 시장 "현실 세계 치수 표준화" 데이터를 세모표 앱에 바로 먹일 수 있는 CSV로 정리한 것.
분야별 리서치(`../research/`)를 스키마로 매핑해 생성한다. 공식 스펙(official_spec)과
크라우드 체감(perception)을 항상 분리한다.

> 루트 `README.md` 는 Flutter 프로젝트 readme라 건드리지 않고, 데이터셋 문서는 여기 `data/README.md` 에 둠.

## 폴더 구조 (2026-07 재정리)

CSV는 카테고리 하위 폴더로 묶여 있다. 스크립트는 파일명만 알면 되고, 실제 경로는
`scripts/_data_paths.py` 의 해석기(`rpath`=읽기 / `dpath`=쓰기)가 카테고리를 붙여 찾는다.
즉 파일을 폴더 간 옮겨도 접두어 규칙만 맞으면 파이프라인이 자동 대응한다.

```
data/
├── food/        food_*                (영양·1인분)
├── beverage/    beverages*, alcohol   (음료·주류)
├── apparel/     apparel_*             (의류 사이즈)
├── shoes/       shoes_*               (신발 사이즈)
├── spiciness/   spiciness*            (맵기)
├── pizza/       pizza_*               (피자 크기)
├── kr/          kr_*                  (국내 프랜차이즈·가격)
├── baby/        baby_*                (유아용품)
├── beauty/      beauty_*              (뷰티)
├── pet/         pet_*                 (반려동물 급여)
├── car/         car_*                 (차량 크기·연비)
├── science/     science_*            (단위·상수)
├── tech/        tech_*                (해상도·저장·TV·충전기)
├── pc_parts/    cpu/gpu/ram/ssd/hdd/wifi (컴퓨터 부품 — 성능 시뮬)
└── misc/        airline_baggage, living_pyeong, manual_todo, barcode_i2570
```

접두어 → 폴더 매핑 규칙은 `scripts/_data_paths.py` 의 `_PREFIX_RULES` 참고. 새 파일은
같은 접두어를 쓰면 자동으로 해당 폴더로 읽기/쓰기된다.

## 분야별 산출물 (스냅샷 2026-06-10)

| 분야 | 파일 | 행 | 원천 리서치 |
|------|------|----|-------------|
| 신발 사이즈 | `shoes_sizing.csv` | 61 | `../research/01_shoes_research.md` |
| 카페·음료 용량 | `beverages.csv` | 60 (off 17 / per 43, manual 8) | `../research/02_beverages_research.md` |
| 의류 사이즈(공식) | `apparel_official.csv` | 19 (단면 실측 cm) | `../research/03_apparel_research.md` |
| 의류 핏(체감) | `apparel_perception.csv` | 17 (manual 6) | `../research/03_apparel_research.md` |
| 제품 맵기(SHU) | `spiciness.csv` | 43 (off 31 / per 12, manual 5) | `../research/04_spiciness_research.md` |
| 음식 1인분/제공량 | `food_portions.csv` | 18 (off 13 / per 5, manual 4) | `../research/05_food_portions_research.md` |
| 피자 사이즈(글로벌) | `pizza_sizes_global.csv` | 147 (42개 브랜드·15개국, 딥리서치) | 딥리서치(공식·영양정보) |
| 피자(냉동/마트) | `pizza_frozen.csv` | 17 (중량 g 기준) | 딥리서치(제품라벨) |
| 가공식품 영양 | `food_nutrition_master.csv` | 282,296 (식약처 영양DB, 1인분 환산) | API 수집(data.go.kr 15127578) |
| 유통바코드 | `barcode_i2570.csv` | 51,158 (식약처 I2570, 바코드→제품) | API 수집(식품안전나라) |

### 확장 데이터셋 (대규모 수집, reliability 컬럼 포함)

| 분야 | 파일 | 행 | 비고 |
|------|------|----|------|
| 음료 용량(확장) | `beverages_expanded.csv` | 107 | 국내+글로벌 30+개 브랜드(버블티 포함), hot/iced 분리, mL |
| 맵기(확장) | `spiciness_expanded.csv` + `spiciness_wave2.csv` | 32+31 | 라면·핫소스·스낵·고추 SHU(범위 min/max), 슈퍼핫 품종 포함 |
| 신발 변환표 | `shoes_conversion.csv` | 35 | ISO19407 mondopoint, 남녀 foot_mm↔KR/US/UK/EU |
| 신발 브랜드 핏 | `shoes_brand_fit.csv` | 12 | 브랜드별 정/크게/작게 + 보정 mm |
| 1인분(확장) | `food_portions_expanded.csv` | 72 | 식약처+글로벌 패스트푸드/베이커리 중량, min/max·kcal |
| 의류 단면(확장) | `apparel_expanded.csv` | 50 | 커버낫·디네댓 + Gildan/Champion/AA/Bella/NextLevel/Carhartt 공식 스펙시트(단면 실측) |
| 매운 프랜차이즈 | `kr_franchise_spicy.csv` | 24 | 디진다돈까스·엽기떡볶이·신전·청년다방·탕화쿵푸 맵기 단계(rank)+가격 |
| 한국 프랜차이즈 1인분 | `kr_franchise_portions.csv` | 58 | 한식·분식·버거·치킨(소비자원 실측)·디저트빙수(배스킨라빈스 등) 중량 |
| 편의점 간편식 | `kr_convenience_food.csv` | 24 | 도시락·삼각김밥·김밥·컵라면·핫바 표시중량(g) |
| 카페 가격 | `kr_cafe_prices.csv` | 24 | 아메리카노 사이즈별 가격(원) |
| 피자 가격 | `kr_pizza_prices.csv` | 26 | 브랜드·사이즈·대표메뉴 배달가(원) |
| 라면·핫소스 가격 | `kr_ramen_snack_prices.csv` | 20 | 편의점/마트 낱개 소매가(원)+용량 |
| 주류 | `kr_alcohol.csv` | 26 | 소주·맥주·막걸리·와인·위스키 용량·도수(abv)·가격 |
| 비주류 음료 | `kr_drinks.csv` | 32 | 탄산·생수·우유·주스·에너지·이온 용량·가격 |
| 과자·스낵 | `kr_snacks.csv` | 23 | 한국 과자 표시중량·가격·kcal |
| 하의(청바지) 사이즈 | `apparel_bottoms.csv` | 12 | waist 라벨 inch↔둘레cm, 인심(Dickies 공식/Levi's) |
| 신발 모델별 핏 | `shoes_brand_fit2.csv` | 18 | 푸마·리복·조던·이지·삼바 등 모델 단위 핏+보정 |
| 키즈 신발 변환 | `shoes_kids.csv` | 19 | 발길이mm↔US키즈↔EU (Nike 공식) |

> 확장 CSV는 전부 `reliability`(high/med/low)와 `source` 컬럼을 가진다. 공개 API가 없는 분야(음료·맵기·신발·옷·피자)는 공식 사이트/영양정보 기반이라 신뢰도 등급 필참.

---

## 📁 폴더 구조 & 빌드 파이프라인 (유지보수용)

```
Semopyo/
├── data/          ← 캐노니컬 소스 (CSV) + 리서치 + 이 README. 앱에 직접 안 들어감.
│   ├── *.csv              비교 데이터 (사람이 읽고 검증하는 원본)
│   └── food_nutrition*.csv, barcode_i2570.csv   대용량 API 덤프(앱 번들 제외)
├── assets/
│   ├── data/      ← 앱이 런타임에 로드하는 JSON. **전부 자동 생성물** (직접 수정 금지)
│   │   └── *.json         data/의 CSV에서 변환됨 (lib/*_data.dart 가 rootBundle 로 로드)
│   ├── barcode_db.json    바코드 51k 오프라인 DB (fsk_pull.py 산출, lib/barcode_local_db.dart 가 로드)
│   └── images/  products/ 브랜드/제품 이미지
├── lib/           ← 도메인별 (페이지 + 데이터로더) 쌍: <도메인>_page.dart / <도메인>_data.dart
│   └── barcode_*.dart  바코드 스캔 기능 (api / 로컬DB / 스캔화면)
└── scripts/
    ├── csv_to_json_assets.py   ★ data/*.csv → assets/data/*.json  (데이터 바꾸면 이거 실행)
    ├── fsk_pull.py             식품안전나라 API 수집기
    ├── build_dataset.py / build_extra_datasets.py  초기 CSV 생성기
    └── validate.py / validate_extra.py             스키마 검증기
```

**데이터 수정 워크플로 (중요):**
1. `data/<파일>.csv` 를 직접 편집/추가 (소스는 항상 CSV).
2. `python3 scripts/csv_to_json_assets.py` 실행 → `assets/data/*.json` 재생성.
3. 앱은 `assets/data/*.json` 만 읽는다. **assets/data 의 JSON 을 손으로 고치지 말 것** (다음 빌드 때 덮어써짐).

> ⚠️ `assets/data/` 에 CSV 를 두지 않는다 — 한때 CSV가 섞여 혼란스러웠고, 2026-06 정리하며 JSON 만 남겼다.

생성·검증:
```bash
python3 scripts/build_dataset.py          # shoes_sizing.csv, manual_todo.csv
python3 scripts/build_extra_datasets.py   # beverages/apparel/spiciness/food_portions
python3 scripts/validate.py data/shoes_sizing.csv   # 신발 검증
python3 scripts/validate_extra.py                   # 나머지 4분야 검증
```

분야별 스키마 요지(전 분야 공통 규칙은 신발 데이터셋 규칙 §데이터 품질 규칙 계승):
- **beverages**: `size_label, volume_ml/oz, cup_or_fill, hot_or_iced, data_type, price_krw, reputation_tag, …` — 핫/아이스 분리 행, 공식(스타벅스·컴포즈·이디야·더리터) vs 집계(나무위키·커뮤니티) 구분.
- **apparel**: official(단면 실측 cm: shoulder/chest_half/length/sleeve/waist_half/rise/thigh/hem)과 perception(fit_tendency/recommend_adjustment/silhouette) 두 파일로 분리. Wilson Korea 라벨→단면 매핑을 골든 레퍼런스로 시드.
- **spiciness**: `scoville_shu` 또는 `scoville_min/max`(범위), `measured_on`(스프/소스/완성품/원물), `version_year`, `spice_level_label`, `perceived_level`(perception 전용). SHU는 스프·소스 측정값이라 볶음/국물 체감차를 note에 분리.
- **food_portions**: `portion_type`(섭취참고량/제공량/완제품/1인분)로 식약처 국가표준·브랜드 완제품·식당 1인분을 절대 혼동 금지. `amount_value`+`amount_unit`(g/mL), 매장 편차는 `amount_min/max`.
- **pizza_sizes_global**: `brand`/`country`/`size_label` 단위 행. `diameter_inch`·`diameter_cm`(둘 중 하나는 환산), `area_cm2`·`slice_area_cm2`(파생, "한 조각이 얼마나 큰가" 비교축), `slices`, `price`+`currency`, `calories_per_slice`, **`reliability`(high/med/low)**, `source`. 공개 API 없어 공식 사이트/영양정보 기반 → 신뢰도 컬럼 필수 참고(한국 도미노·피자헛 cm는 비공식). 앱 에셋: `assets/pizza_global.json`.

## 브랜드 로고 (`brand_domain` 컬럼)

모든 데이터셋에 `brand_domain`(브랜드 공식 도메인) 컬럼이 있다. **이미지 파일을 저장소에 넣지 않고**,
앱이 이 도메인으로 런타임에 로고를 불러온다. 매핑은 `scripts/brand_domains.py` 에서 관리하며,
**도메인을 지어내지 않는다 — 확신 없는 브랜드는 빈값**(앱은 머리글자/폴백 아이콘 표시).
현재 커버리지: 59개 브랜드 채움 / 22개 미보강(국산 소형 브랜드 위주).

렌더링 소스는 도메인만 있으면 교체 가능하다 (URL의 `{d}` = `brand_domain`):

| 용도 | URL 템플릿 | 키 | 결과 |
|------|-----------|----|------|
| **아이콘(파비콘)** | `https://www.google.com/s2/favicons?domain={d}&sz=128` | 불필요 | 작은 심볼(예: 스타벅스 사이렌). 가볍지만 워드마크는 아님 |
| 아이콘(대체) | `https://icons.duckduckgo.com/ip3/{d}.ico` | 불필요 | 위와 유사 |
| **로고 워드마크** | `https://img.logo.dev/{d}?token={KEY}&format=png` | 무료키 | 브랜드 고유 글씨체 로고(예: 스타벅스 wordmark). `logo.dev` 무료 월 50만 |
| 로고(SVG) | `https://cdn.brandfetch.io/{d}/w/400?c={CLIENT_ID}` | 무료키 | Brandfetch, SVG 고품질 |

> **"브랜드 상표를 그 회사 고유 문체로" 표시하려면** 파비콘이 아니라 로고 서비스(logo.dev/Brandfetch)가 필요하다.
> 둘 다 `brand_domain` 하나로 동작하므로 데이터는 그대로 두고 앱의 URL 조립만 바꾸면 된다.

**앱 구현 상태 (logo.dev 기본):**
- 키·URL 빌더: `lib/brand_logo.dart` (`LogoConfig`), publishable 키 적용 완료.
- 브랜드명→도메인 맵: `lib/brand_domains.dart` (한글+영문 119키). 생성기 `scripts/gen_brand_domains_dart.py`.
- 위젯: `BrandLogo(brandName: ..., fallback: 이모지)` — 도메인 없거나 로딩 실패 시 폴백.
- **적용 페이지: 음료·맵기·의류·신발(선택/결과)·음식양** 전부 워드마크 표시.
  - 피자 페이지는 기존 로컬 asset 로고(`assets/images/*.png`) 유지.
- macOS 네트워크 권한: `com.apple.security.network.client` 추가(Debug/Release 엔타이틀먼트). 없으면 로고 안 뜸.
- 맵 재생성: CSV 수정 후 `python3 scripts/gen_brand_domains_dart.py`.
- 폴백(도메인 미확인 → 이모지): 메가커피·매머드·김밥천국·금비유통·아름·라이풀·마하그리드·육육걸즈·인사일런스·츄 등. 확인되면 `brand_domains.py`/`ALIASES`에 보강.

### 상표권 메모 (법률 자문 아님)
- 실제 그 브랜드의 제품을 **식별**하기 위한 로고 표시(지명적 사용, nominative use)는 비교적 방어 가능하나,
  로고 이미지를 앱에 **번들로 박아 배포**하는 것은 리스크가 더 크다 → 런타임 fetch 권장.
- 브랜드와의 제휴/보증을 암시하지 않도록 주의(로고 옆 "비공식" 또는 출처 표기 고려).
- 상용 배포 전 각 로고 서비스 약관 및 상표 사용 가이드 확인 권장.

---

# 신발 사이즈 데이터셋 (상세)

## 산출물

| 파일 | 내용 |
|------|------|
| `data/shoes_sizing.csv` | 본 데이터셋 (UTF-8 with BOM, 엑셀 한글 안 깨짐) |
| `data/manual_todo.csv` | `manual_collection=TRUE` 인 행만 (수동수집 대상) |
| `scripts/build_dataset.py` | 리서치를 스키마로 매핑한 생성기 (CSV 두 개 출력) |
| `scripts/validate.py` | 스키마/enum/제약 검증기 |

### 재생성 & 검증

```bash
python3 scripts/build_dataset.py                     # CSV 두 개 생성
python3 scripts/validate.py data/shoes_sizing.csv    # OK: 61 rows valid
```

## 데이터 모델 (컬럼 순서 고정)

| 컬럼 | 의미 | 허용값 |
|------|------|--------|
| `brand_ko` | 한글 브랜드명 | (필수) |
| `brand_en` | 영문 브랜드명 | (필수) |
| `origin` | 원산/계열 | `국산` \| `글로벌` |
| `model_line` | 모델/라인. 브랜드 일반값이면 `_general` | (필수) |
| `data_type` | 공식 스펙과 체감을 절대 한 행에 섞지 않음 | `official_spec` \| `perception` |
| `label_size_mm` | 라벨 사이즈(mm). 예시행이면 270 | 정수 / 빈값 |
| `designed_foot_length_mm` | 그 라벨이 의도한 실제 발길이(mm) | 정수 / 빈값 |
| `insole_length_mm` | 깔창/내부 길이(mm) | 정수 / 빈값 (대부분 미공개) |
| `fit_verdict` | **`perception` 행에서만** 채움 | `작게` \| `정사이즈` \| `크게` \| 빈값 |
| `adjustment_reco` | 권장 보정 | `+5mm` `-5mm` `정사이즈` `1업` 등 |
| `toebox_width` | 발볼/토박스 폭 | `좁음` \| `표준` \| `넓음` \| 빈값 |
| `stiffness` | 강성 | `부드러움` \| `보통` \| `짱짱함` \| 빈값 |
| `price_min_krw` | 최저가(정수) | 정수 / 빈값 |
| `price_max_krw` | 최고가(정수) | 정수 / 빈값 |
| `collected_date` | 수집일 | `YYYY-MM-DD` |
| `source_url` | 출처 URL | URL / 빈값 |
| `reliability` | 신뢰도 | `상` \| `중` \| `하` |
| `manual_collection` | 로그인/JS렌더 등 수동수집 필요 | `TRUE` \| `FALSE` |
| `note` | 자유 메모 (출처충돌·추정·데이터없음 등) | |

## 데이터 품질 규칙 (validate.py 가 강제)

1. `origin` `data_type` `fit_verdict` `toebox_width` `stiffness` `reliability`
   `manual_collection` 은 위 enum 값만 허용.
2. `fit_verdict` 는 `data_type=perception` 일 때만 채운다 (official 행에 있으면 위반).
3. `price_min_krw <= price_max_krw`, 그리고 둘 다 채우거나 둘 다 비운다.
4. **`source_url` 이 비면 `reliability` 는 `하` 로 강등** (URL 없는 행은 검증 불가로 간주).
5. 정수 필드는 정수거나 빈값. `collected_date` 는 `YYYY-MM-DD`.
6. 출처충돌 항목(닥터마틴 업/다운, 크록스 270mm 등)은 **양쪽을 각각 행으로 남기고**
   `note` 에 `출처충돌` 표기, **공식을 우선**으로 둔다.

## 수집 원칙

- **데이터를 지어내지 않는다.** 근거 없는 수치는 빈값 + `note` 에 `데이터없음`.
- **브랜드 단위로 일반화해 모델 편차를 뭉개지 않는다.** 모델별로 다르면 행을 나눈다
  (예: 나이키 AF1=크게 / 덩크·조던1=작게, 뉴발 SL-2 라스트=넓음 / SL-1·2002R=좁음).
- **공식(official_spec)과 체감(perception)을 분리**해 충돌을 방지.
- `1업 추천` 이 패션 오버사이징인지 착화 필요인지 구분되면 `note` 에 분리 표기
  (예: 컨버스 "다운=착화/1업=스타일", 이지350 "1업=착화 필요").
- 추정값에는 `note` 에 `추정` 표기.

## 출처

- **공식 스펙(official_spec)**: 브랜드 공식 도메인 인용
  나이키 `nike.com/kr`, 뉴발란스 `nbkorea.com`, 아식스 `asics.co.kr`,
  닥터마틴 `drmartens.com`, 버켄스탁 `birkenstock.com`, 크록스 `crocs.co.kr`.
- **체감(perception)**: KREAM/무신사/나무위키/디시/커뮤니티 후기 종합.
  대부분 인용 가능한 단일 URL이 없어 `source_url` 을 비웠고, 규칙 4에 따라
  `reliability=하` 로 강등됨 (출처 설명은 `note` 에 보존). 나무위키처럼
  인용 가능한 페이지가 명시된 건은 URL을 넣고 `중` 유지 (아식스).

## 한계 (Caveats)

- **국산 구두·스포츠 브랜드(프로스펙스·르까프·소다·미소페·데코 등)는 공식 mm 발길이/깔창 표 미공개**.
  `라벨 mm = 발길이` 국산 관례에 의존하므로 official_spec 의 발길이는 `추정` 표기.
- **체감 데이터는 모델 단위로 흩어져 있음.** 표본 적은 모델은 `reliability=하` 유지.
  모델별 후기 20건 이상 확보 시 `fit_verdict` 를 다수결로 확정 권장.
- **출처충돌 미해소 항목**: 닥터마틴(공식=업+깔창 vs 리테일러=다운), 크록스 270mm(남성9 vs 남성8).
  양쪽 행 보존 + 공식 우선. 크록스는 `fit-guide.html` 직접확인 필요.
- **로그인/JS렌더 게이트**: 아래 수동수집 목록 참고.
- `research_shoes.md` 자체가 인코딩 깨진 첨부로 제공되어, 숫자·영문·URL·발볼코드(D/2E/4E)는
  원문에서 직접 읽고 한글 서술은 문맥으로 복원함. 의심 구간은 `note` 에 표기.

## 수동수집 목록 (`data/manual_todo.csv`, 3건)

| 브랜드 | 이유 |
|--------|------|
| 아식스 | 정확 mm↔CM 환산표가 JS 렌더링 → 브라우저로 차트 확인 필요 |
| 크록스 | 270mm 추천 출처충돌, `crocs.co.kr/.../fit-guide.html` 직접확인(JS) 필요 |
| 무신사 스탠다드 | 회원후기 로그인 게이트 → 직접 접근 금지, 수동수집 |

## 요약 (현재 스냅샷)

- 총 **61행 / 29 브랜드**
- `official_spec` **16** vs `perception` **45**
- `origin`: 글로벌 **43**, 국산 **18**
- `reliability`: 상 **12**, 중 **4**, 하 **45** (체감 다수가 URL 없어 규칙4로 강등)
- `manual_collection=TRUE`: **3** (아식스 JS차트 / 크록스 fit-guide / 무신사 로그인)
