# 전자기기 성능 비교 — 설계 문서

날짜: 2026-07-08

## 배경

기존에 "PC 견적" 단일 타일(부품 6종 리스트 선택 → 점수 계산)로 시작했던 기능을, "전자기기 성능 비교"로 확장한다. 홈 화면에서 진입하면 기기 종류(폰/태블릿/워치/데스크탑/노트북)를 먼저 고르고, 각 기기별로 부품/스펙을 골라 예상 성능을 시뮬레이션하고 견적 A/B를 비교할 수 있다.

이 기능은 실제 부품 벤치마크 데이터 없이 **프레임(구조 + 자리표시자 데이터)만** 만든다. 실데이터 연결과 정교한 시뮬레이션 모델은 후속 작업.

참고: `data/pc_parts/`(cpu/gpu/ram/ssd/hdd/wifi CSV)에 실제 데이터가 이미 수집돼 있으나, 이번 프레임 작업에서는 사용하지 않는다. 스키마만 참고 가능.

## 목표 / 비목표

**목표**
- 5개 기기 종류(폰/태블릿/워치/데스크탑/노트북)를 고르는 진입 화면
- 기기별로 슬롯(부품/스펙)을 골라 담는 빌더 화면, 실제 기기 모양을 시각적으로 표현
- 슬롯을 모두 채우면 "작동하는 것처럼" 보이는 연출(팬 회전, 화면 발광, RGB 펄스 등)
- 견적 A/B 두 개를 만들어 성능·소비전력(또는 배터리)·가격을 비교
- 자리표시자 시뮬레이션 로직(가중합) + 샘플 부품 몇 개

**비목표**
- 실제 부품 데이터 연동 (다음 단계)
- 정확한 벤치마크 기반 성능 모델
- 실제 스톡 이미지/외부 에셋 사용 (저작권 문제로 자체 제작 플랫 아이콘만 사용)
- 자동화 테스트 (기존 도메인 페이지들도 테스트 없음, 컨벤션 일치)

## 아키텍처

파일 5개. 기존 `pc_builder_data.dart` / `pc_builder_page.dart`는 삭제하고 아래로 대체한다.

### `lib/device_sim_data.dart` — 공통 엔진 + 카테고리 정의

```dart
enum DeviceCategory { phone, tablet, watch, desktop, laptop }

class DeviceSlot {
  final String id;      // 'cpu', 'gpu', 'battery' 등
  final String label;   // 'CPU', '배터리' 등
  final String emoji;
}

class DevicePart {
  final String id;
  final String slotId;
  final String name;         // '(샘플)' 접미사 붙임
  final int perfScore;       // 0~100
  final Map<String, int> stats; // statId -> 값 (예: {'watt': 125} / {'battery_mah': 4500})
  final int price;           // 원
}

class ScoreAxis {
  final String id;
  final String label;              // '게임 성능' 등
  final Map<String, double> weights; // slotId -> 가중치
}

class StatDef {
  final String id;      // 'watt' / 'battery_mah'
  final String label;   // '예상 전력' / '배터리 용량'
  final String unit;    // 'W' / 'mAh'
}

class DeviceCategoryDef {
  final DeviceCategory category;
  final String label;
  final String emoji;
  final List<DeviceSlot> slots;
  final List<ScoreAxis> axes;   // 보통 2개
  final List<StatDef> stats;    // 보통 1개
  final String? Function(DeviceBuild build)? bottleneck; // 병목 문구, 없으면 null
  final List<DevicePart> sampleParts;
}

class DeviceBuild {
  final DeviceCategoryDef def;
  final Map<String, DevicePart?> slots; // slotId -> 선택된 부품
}

class SimResult {
  final Map<String, int> axisScores;   // axisId -> 0~100
  final Map<String, int> statTotals;   // statId -> 합산값
  final int totalPrice;
  final String? bottleneck;
  static SimResult empty(DeviceCategoryDef def);
}

SimResult simulate(DeviceBuild build);
List<DevicePart> partsOf(DeviceCategoryDef def, String slotId);
```

카테고리별 정의(초기 자리표시자 값, 슬롯당 샘플 부품 3~4개):

| 카테고리 | 슬롯 | 축(축1/축2) | 보조지표 | 병목 체크 |
|---|---|---|---|---|
| 데스크탑 | cpu/gpu/ram/storage/board/psu | 게임 성능 / 작업 성능 | 예상 전력(W) | CPU↔GPU perfScore 차 25 이상 |
| 노트북 | cpu/gpu/ram/storage | 게임 성능 / 작업 성능 | 배터리(Wh) | 없음 |
| 폰 | chipset/ram/storage/battery | 일상 성능 / 고사양 성능 | 배터리 용량(mAh) | 없음 |
| 태블릿 | chipset/ram/storage/battery | 일상 성능 / 고사양 성능 | 배터리 용량(mAh) | 없음 |
| 워치 | chipset/battery/display | 반응 속도 / 배터리 지속 | 배터리 용량(mAh) | 없음 |

가중치는 기존 PC 로직 그대로 이식(게임=GPU 0.6+CPU 0.3+RAM 0.1, 작업=CPU 0.5+RAM 0.25+저장 0.15+GPU 0.1), 나머지 카테고리는 슬롯 구성에 맞춰 비례 배분한 자리표시자 값.

### `lib/device_shapes.dart` — 카테고리별 시각 위젯

카테고리마다 위젯 하나. 공통 인터페이스:

```dart
typedef SlotTapCallback = void Function(String slotId);

class DesktopShape extends StatelessWidget {
  final DeviceBuild build;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
}
// LaptopShape, PhoneShape, TabletShape, WatchShape 동일 시그니처
```

구현은 대부분 `Container`/`Stack`/`BoxDecoration` + `AnimationController`(팬 회전·RGB 색상 순환·화면 발광 opacity·워치 링 글로우)만으로 충분한 사각형/원 조합. 유일한 예외는 데스크탑의 굽은 전원선 — 이것만 `CustomPainter` 하나(`_PowerCablePainter`)로 그린다.

- **데스크탑**: 모니터(화면+스탠드+베이스) + 타워(통풍구 슬릿 3줄 + 전원 LED, 슬롯 배지 6개 오버레이) + 키보드 + 마우스 + 전원선(`_PowerCablePainter`로 곡선 하나, `isComplete`일 때 점선 애니메이션). `isComplete`면 타워 테두리 RGB 순환 + 팬 회전.
- **노트북**: 클램쉘(화면+베이스), 슬롯 배지는 베이스 위에 오버레이. `isComplete`면 화면 발광.
- **폰/태블릿**: 세로/가로 바디 + 화면, 슬롯 배지 오버레이. `isComplete`면 화면 발광.
- **워치**: 스트랩 + 원형 페이스, 슬롯 배지 오버레이. `isComplete`면 페이스 링 글로우.

모든 배지는 탭하면 `onSlotTap(slotId)` 호출 → 상위에서 바텀시트 오픈.

### `lib/device_category_page.dart` — 진입 화면

5개 카드(각 `DeviceShape` 위젯을 아주 작게 미리보기로 재사용, `build`는 빈 상태 더미). 탭하면 `DeviceBuilderPage(def: ...)`로 push.

### `lib/device_builder_page.dart` — 빌더 화면 (기존 `pc_builder_page.dart` 일반화)

- 상단: 견적 A/B 탭 (기존 `_buildTabs` 그대로 재사용, 개수만 `def` 기준 아님 — 항상 2개 고정)
- 중단: 해당 카테고리 `*Shape` 위젯. 배지 탭 → 기존 바텀시트 패턴 재사용(부품 목록은 `partsOf(def, slotId)`), 선택/해제 동일.
- 하단: 예상 성능 카드 — `def.axes`를 순회하며 점수바(기존 `_scoreBar` 일반화), `def.stats` 순회하며 스탯 칩(기존 `_statChip` 일반화), 가격, `result.bottleneck` 있으면 경고 배지.
- 최하단: 견적 A vs B 비교 카드 — `def.axes` + `def.stats` + 가격을 순회하며 기존 `_compareRow` 패턴 재사용.
- 빈 상태 문구는 기존 `_emptyCard` 그대로.

### `lib/main.dart`

'PC 견적' 타일 → '전자기기 성능 비교'(💻, 초록 그라데이션 유지) 타일로 교체, `DeviceCategoryPage`로 연결. 삭제되는 `pc_builder_page.dart` import 제거.

## 데이터 흐름

1. 홈 → '전자기기 성능 비교' 탭 → `DeviceCategoryPage`
2. 카드 탭 → 해당 `def`로 빈 `DeviceBuild` A/B 생성 → `DeviceBuilderPage` push
3. 시각 위젯의 슬롯 배지 탭 → 바텀시트에서 부품 선택/해제 → `setState`
4. 매 리빌드마다 `simulate(build)` 재계산 → 시각 위젯(`isComplete` 여부로 연출 전환) + 결과 카드 + 비교 카드 갱신

## 에러 처리

실데이터 소스가 없어 네트워크/파싱 에러 경로 자체가 없음. 슬롯 미선택 시 `perfScore=0`으로 처리(기존 PC 로직과 동일), 화면엔 "N개 슬롯 비어있음" 안내만 표시.

## 테스트

기존 도메인 페이지들(피자/신발/음료 등)도 자동화 테스트가 없어 컨벤션을 따른다. 검증은 `flutter analyze` 통과 + 수동 실행(가능하면 `flutter run`으로 5개 카테고리 진입, 슬롯 선택, 완성 연출, A/B 비교까지 확인) 텍스트 보고로 대체한다.
