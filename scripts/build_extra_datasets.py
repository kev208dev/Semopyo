# -*- coding: utf-8 -*-
"""
세모표 추가 데이터셋 생성기 (음료/의류/맵기/음식양).

research/02_beverages_research.md, 03_apparel_research.md,
04_spiciness_research.md, 05_food_portions_research.md 를 사람이 파싱해
아래 스키마로 매핑한 결과. 실행하면 data/ 아래에 UTF-8 with BOM CSV를 생성한다.

원칙(신발 데이터셋과 동일):
- 데이터를 지어내지 않는다. 근거 없는 수치는 '' + note 에 사유.
- official_spec 과 perception 을 한 행에 섞지 않는다.
- 모델/사이즈/버전/용기 편차는 행으로 나눈다.
- source_url 이 비면 reliability='하' 로 강등.
"""
import csv
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from brand_domains import domain_for

COLLECTED = "2026-06-10"
DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data")


def write_csv(name, columns, rows):
    path = os.path.join(DATA_DIR, name)
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.writer(f)
        w.writerow(columns)
        for r in rows:
            assert len(r) == len(columns), "%s: %d != %d :: %r" % (name, len(r), len(columns), r)
            w.writerow(r)
    print("wrote %s (%d rows)" % (path, len(rows)))


# =====================================================================
# 1) 음료 (beverages.csv)
# =====================================================================
BEV_COLS = [
    "brand_ko", "brand_en", "category", "size_label",
    "volume_ml", "volume_oz", "cup_or_fill", "hot_or_iced",
    "data_type", "price_krw", "reputation_tag",
    "brand_domain", "collected_date", "source_url", "reliability", "manual_collection", "note",
]
# (brand_ko, brand_en, category, size_label, ml, oz, cup_or_fill, hot_or_iced,
#  data_type, price, reputation_tag, url, rel, manual, note)
_BEV = [
    ("스타벅스", "Starbucks", "대형체인", "숏(Short)", 237, 8, "컵", "공용", "official_spec", "", "히든사이즈", "https://www.starbucks.co.kr", "상", "FALSE", "단위변환 앵커"),
    ("스타벅스", "Starbucks", "대형체인", "톨(Tall)", 355, 12, "컵", "공용", "official_spec", 4500, "", "https://www.starbucks.co.kr", "상", "FALSE", "공식 앱 기준"),
    ("스타벅스", "Starbucks", "대형체인", "그란데(Grande)", 473, 16, "컵", "공용", "official_spec", "", "", "https://www.starbucks.co.kr", "상", "FALSE", ""),
    ("스타벅스", "Starbucks", "대형체인", "벤티(Venti)", 591, 20, "컵", "핫", "official_spec", "", "", "https://www.starbucks.co.kr", "상", "FALSE", "아이스는 24oz"),
    ("스타벅스", "Starbucks", "대형체인", "트렌타(Trenta)", 887, 30, "컵", "아이스", "official_spec", 6900, "초대용량", "https://www.starbucks.co.kr", "상", "FALSE", "2023.7.20 출시, 아이스 전용. 콜드브루 6900원"),
    ("투썸플레이스", "A Twosome Place", "대형체인", "레귤러", 355, 12, "충전", "핫", "perception", 4500, "", "", "하", "FALSE", "ICE는 414mL 별도행"),
    ("투썸플레이스", "A Twosome Place", "대형체인", "레귤러", 414, 14, "충전", "아이스", "perception", 4500, "", "", "하", "FALSE", "핫355/아이스414 분리"),
    ("투썸플레이스", "A Twosome Place", "대형체인", "라지", 474, 16, "충전", "공용", "perception", 5000, "", "", "하", "FALSE", ""),
    ("투썸플레이스", "A Twosome Place", "대형체인", "맥스", 591, 20, "충전", "공용", "perception", "", "", "", "하", "FALSE", ""),
    ("커피빈", "The Coffee Bean", "대형체인", "스몰", 355, 12, "컵", "공용", "perception", "", "", "", "하", "FALSE", "레귤러가 큰 사이즈라 혼란"),
    ("커피빈", "The Coffee Bean", "대형체인", "레귤러", 473, 16, "컵", "공용", "perception", "", "", "", "하", "FALSE", "473~476"),
    ("커피빈", "The Coffee Bean", "대형체인", "라지", 591, 20, "컵", "공용", "perception", "", "", "", "하", "FALSE", ""),
    ("폴바셋", "Paul Bassett", "대형체인", "스탠다드", 360, "", "충전", "공용", "perception", "", "", "", "하", "FALSE", "아메리카노 단일. 룽고300/그랜드룽고400 별도"),
    ("메가커피", "Mega Coffee", "저가대용량", "기본(20oz)", 500, 20, "충전", "핫", "perception", 1500, "가성비", "", "하", "FALSE", "아이스는 590mL"),
    ("메가커피", "Mega Coffee", "저가대용량", "기본(20oz)", 590, 20, "충전", "아이스", "perception", 2000, "가성비", "", "하", "FALSE", ""),
    ("메가커피", "Mega Coffee", "저가대용량", "24oz", 710, 24, "컵", "공용", "perception", "", "", "", "하", "FALSE", ""),
    ("메가커피", "Mega Coffee", "저가대용량", "메가리카노(32oz)", 960, 32, "컵", "아이스", "perception", 3000, "초대용량", "", "하", "FALSE", "최대 쓰리샷. 일부매장 1L 왕메가리카노"),
    ("컴포즈커피", "Compose Coffee", "저가대용량", "14oz", 414, 14, "컵", "공용", "official_spec", "", "", "https://composecoffee.com", "상", "FALSE", ""),
    ("컴포즈커피", "Compose Coffee", "저가대용량", "20oz(기본)", 591, 20, "컵", "공용", "official_spec", 1500, "가성비", "https://composecoffee.com", "상", "FALSE", "핫 기준. 아이스 1800원"),
    ("컴포즈커피", "Compose Coffee", "저가대용량", "빅포즈(32oz)", 946, 32, "컵", "아이스", "official_spec", 3000, "초대용량", "https://composecoffee.com", "상", "FALSE", "4샷, 아이스·테이크아웃 전용"),
    ("빽다방", "Paik's Coffee", "저가대용량", "기본", 400, "", "충전", "핫", "perception", 1500, "가성비", "", "하", "FALSE", "집계차 420"),
    ("빽다방", "Paik's Coffee", "저가대용량", "기본", 625, "", "충전", "아이스", "perception", 2000, "가성비", "", "하", "FALSE", ""),
    ("빽다방", "Paik's Coffee", "저가대용량", "빽사이즈", 946, "", "컵", "아이스", "perception", 3500, "초대용량", "", "하", "FALSE", "약 946~950, 4샷"),
    ("더벤티", "The Venti", "저가대용량", "라지(기본)", 570, "", "충전", "핫", "perception", 1500, "가성비", "", "하", "TRUE", "아이스 680. 공식사이트 봇차단→수동"),
    ("더벤티", "The Venti", "저가대용량", "라지(기본)", 680, "", "충전", "아이스", "perception", 1800, "가성비", "", "하", "TRUE", "공식사이트 봇차단→수동"),
    ("더벤티", "The Venti", "저가대용량", "더벤티사이즈", 955, "", "컵", "아이스", "perception", "", "초대용량", "", "하", "TRUE", "약 950~960. 수동확인"),
    ("더벤티", "The Venti", "저가대용량", "점보", "", "", "컵", "아이스", "perception", "", "초대용량", "", "하", "TRUE", "라지2배·쿼드샷, 정확mL 미확인 데이터없음"),
    ("더리터", "The Liter", "저가대용량", "스몰리터(14oz)", 414, 14, "컵", "아이스", "official_spec", "", "", "https://www.theliter.com", "상", "FALSE", ""),
    ("더리터", "The Liter", "저가대용량", "미니리터(24oz,기본)", 710, 24, "컵", "아이스", "official_spec", 2800, "", "https://www.theliter.com", "상", "FALSE", ""),
    ("더리터", "The Liter", "저가대용량", "리터(32oz)", 946, 32, "컵", "아이스", "official_spec", 3800, "초대용량", "https://www.theliter.com", "상", "FALSE", "'1L'마케팅이나 실제 약0.95L, 2샷"),
    ("매머드커피", "Mammoth Coffee", "저가대용량", "S", 355, "", "충전", "공용", "perception", 1200, "", "", "하", "FALSE", ""),
    ("매머드커피", "Mammoth Coffee", "저가대용량", "M(기본)", 473, "", "충전", "공용", "perception", 1600, "", "", "하", "FALSE", ""),
    ("매머드커피", "Mammoth Coffee", "저가대용량", "L", 600, "", "충전", "공용", "perception", 3000, "", "", "하", "FALSE", "600mL+. 32oz 대형 별도"),
    ("이디야", "EDIYA", "대형체인", "레귤러(과거)", 420, 14, "컵", "공용", "official_spec", "", "", "https://www.ediya.com", "상", "FALSE", "2022.12 기본을 라지로 확대"),
    ("이디야", "EDIYA", "대형체인", "라지", 532, 18, "컵", "공용", "official_spec", 3200, "", "https://www.ediya.com", "상", "FALSE", "2025.12 전음료 기본 18oz 통일"),
    ("이디야", "EDIYA", "대형체인", "엑스트라", 709, 24, "컵", "공용", "official_spec", 4400, "", "https://www.ediya.com", "상", "FALSE", "과거22oz 650→24oz 709"),
    ("할리스", "HOLLYS", "대형체인", "레귤러", 354, 12, "컵", "공용", "perception", 4500, "", "", "하", "FALSE", ""),
    ("할리스", "HOLLYS", "대형체인", "그란데", 472, 16, "컵", "공용", "perception", 5000, "", "", "하", "FALSE", ""),
    ("할리스", "HOLLYS", "대형체인", "벤티", 591, 20, "컵", "공용", "perception", 5500, "", "", "하", "FALSE", ""),
    ("엔제리너스", "Angel-in-us", "대형체인", "스몰", 355, 12, "컵", "공용", "perception", "", "", "", "하", "FALSE", "330~355"),
    ("엔제리너스", "Angel-in-us", "대형체인", "레귤러", 473, 16, "컵", "공용", "perception", "", "", "", "하", "FALSE", "440~473"),
    ("엔제리너스", "Angel-in-us", "대형체인", "라지", 591, 20, "컵", "공용", "perception", "", "", "", "하", "FALSE", "550~591"),
    ("탐앤탐스", "TOM N TOMS", "대형체인", "Tall", 355, 12, "컵", "공용", "perception", 4400, "", "", "하", "FALSE", "추정"),
    ("탐앤탐스", "TOM N TOMS", "대형체인", "Grande", 473, 16, "컵", "공용", "perception", 4900, "", "", "하", "FALSE", "추정"),
    ("탐앤탐스", "TOM N TOMS", "대형체인", "Venti", 591, 20, "컵", "공용", "perception", 5600, "", "", "하", "FALSE", "추정"),
    ("팀홀튼", "Tim Hortons", "대형체인", "M", 414, 14, "컵", "공용", "perception", 4000, "", "", "하", "TRUE", "한국공식 용량표 미확인, 글로벌추정. JS렌더→수동"),
    ("팀홀튼", "Tim Hortons", "대형체인", "L", 591, 20, "컵", "공용", "perception", "", "", "", "하", "TRUE", "글로벌추정. 수동확인"),
    ("공차", "Gong cha", "차/디저트", "레귤러", 355, 12, "컵", "공용", "perception", "", "", "", "하", "FALSE", "공식은 g표기"),
    ("공차", "Gong cha", "차/디저트", "라지", 473, 16, "컵", "아이스", "perception", "", "", "", "하", "FALSE", "공식 454g, 실측 약473"),
    ("공차", "Gong cha", "차/디저트", "점보", 700, 24, "컵", "아이스", "perception", "", "초대용량", "", "하", "FALSE", "공식 624g, 실측 약651"),
    ("스무디킹", "Smoothie King", "차/디저트", "S", 360, 12, "컵", "공용", "perception", "", "", "", "하", "FALSE", "2025.10 한국 영업종료 예정"),
    ("스무디킹", "Smoothie King", "차/디저트", "R", 480, 16, "컵", "공용", "perception", "", "", "", "하", "FALSE", ""),
    ("스무디킹", "Smoothie King", "차/디저트", "L", 600, 20, "컵", "공용", "perception", "", "", "", "하", "FALSE", ""),
    ("쥬씨", "JUICY", "차/디저트", "M", 500, "", "충전", "공용", "perception", 1500, "", "", "하", "FALSE", "약500"),
    ("쥬씨", "JUICY", "차/디저트", "XL", 780, "", "충전", "공용", "official_spec", 2800, "과대광고이력", "https://www.ftc.go.kr", "중", "FALSE", "광고1000mL이나 용기830·음료600~780. 공정위 2017.6.14 시정명령+과징금2600만원"),
    ("맥도날드", "McDonald's", "패스트푸드", "콜라 S", 320, "", "충전", "아이스", "perception", "", "", "", "하", "FALSE", ""),
    ("맥도날드", "McDonald's", "패스트푸드", "콜라 M", 425, "", "충전", "아이스", "official_spec", "", "", "https://www.mcdonalds.co.kr", "중", "FALSE", "공식 영양분석표"),
    ("맥도날드", "McDonald's", "패스트푸드", "콜라 L", 610, "", "충전", "아이스", "official_spec", "", "", "https://www.mcdonalds.co.kr", "중", "FALSE", "공식 영양분석표"),
    ("롯데리아", "Lotteria", "패스트푸드", "콜라 M(기본)", "", "", "충전", "아이스", "perception", "", "", "", "하", "TRUE", "정확mL 미확인 데이터없음"),
    ("버거킹", "Burger King", "패스트푸드", "콜라 M", "", "", "충전", "아이스", "perception", "", "", "", "하", "TRUE", "정확mL 미확인 데이터없음"),
]

# =====================================================================
# 2) 의류 official_spec (apparel_official.csv) — 단면 실측 cm
# =====================================================================
AP_OFF_COLS = [
    "brand_ko", "brand_en", "domestic_global", "category", "size_label",
    "shoulder_cm", "chest_half_cm", "length_cm", "sleeve_cm",
    "waist_half_cm", "rise_cm", "thigh_cm", "hem_cm",
    "price_min_krw", "price_max_krw",
    "brand_domain", "collected_date", "source_url", "reliability", "manual_collection", "note",
]
_AP_OFF = [
    # 커버낫 — 공식 실측 HIGH
    ("커버낫", "Covernat", "국내", "맨투맨(헤비웨이트 오버핏)", "S", 86, 61.5, 66, 29, "", "", "", "", "", "", "https://covernat.net", "상", "FALSE", "화장86/소매통29. 오버핏 정사이즈"),
    ("커버낫", "Covernat", "국내", "맨투맨(헤비웨이트 오버핏)", "M", 89, 65, 69, 31, "", "", "", "", "", "", "https://covernat.net", "상", "FALSE", "화장89/소매통31"),
    ("커버낫", "Covernat", "국내", "맨투맨(헤비웨이트 오버핏)", "L", 91, 67.5, 71, 32, "", "", "", "", "", "", "https://covernat.net", "상", "FALSE", "화장91/소매통32"),
    ("커버낫", "Covernat", "국내", "맨투맨(헤비웨이트 오버핏)", "XL", 93, 70, 73, 33, "", "", "", "", "", "", "https://covernat.net", "상", "FALSE", "화장93/소매통33"),
    ("커버낫", "Covernat", "국내", "맨투맨(C로고)", "S", 52, 55, 65, 58, "", "", "", "", 46900, 46900, "https://covernat.net", "상", "FALSE", "레귤러~세미오버"),
    ("커버낫", "Covernat", "국내", "맨투맨(C로고)", "M", 54.5, 58.5, 68, 60, "", "", "", "", 46900, 46900, "https://covernat.net", "상", "FALSE", ""),
    ("커버낫", "Covernat", "국내", "맨투맨(C로고)", "L", 56, 61, 70, 61, "", "", "", "", 46900, 46900, "https://covernat.net", "상", "FALSE", ""),
    ("커버낫", "Covernat", "국내", "맨투맨(C로고)", "XL", 57.5, 63.5, 72, 62, "", "", "", "", 46900, 46900, "https://covernat.net", "상", "FALSE", ""),
    ("커버낫", "Covernat", "국내", "맨투맨(피그먼트 어센틱 오버핏)", "S", 59, 65, 65, 57, "", "", "", "", "", "", "https://covernat.net", "상", "FALSE", "오버핏"),
    ("커버낫", "Covernat", "국내", "맨투맨(피그먼트 어센틱 오버핏)", "M", 60.5, 67.5, 68, 58, "", "", "", "", "", "", "https://covernat.net", "상", "FALSE", ""),
    ("커버낫", "Covernat", "국내", "맨투맨(피그먼트 어센틱 오버핏)", "L", 62, 70, 71, 59, "", "", "", "", "", "", "https://covernat.net", "상", "FALSE", ""),
    # 유니클로
    ("유니클로", "UNIQLO", "글로벌", "AIRism 코튼 오버사이즈 크루넥T", "_range", "", "", "", "", "", "", "", "", "", "", "https://www.uniqlo.com/kr", "상", "FALSE", "XS~4XL 드롭숄더. 공식 사이즈조견표(완성품) 일관적. 세부cm 수동"),
    # 임블리 — 공식 실측 HIGH (여성 원피스)
    ("임블리", "IMVELY", "국내", "플로럴 롱원피스", "FREE(44~66)", 35, 43, 120, 56.5, 37, "", "", "", "", "", "https://imvely.com", "상", "FALSE", "암홀22. 정사이즈"),
    # 윌슨 — 라벨→단면 골든레퍼런스(남성 상의)
    ("윌슨", "Wilson Korea", "글로벌", "남성상의(표준매핑)", "S(90)", 46, 48.5, 64.5, "", "", "", "", "", "", "", "https://www.wilson.co.kr", "상", "FALSE", "가슴단면 47-50/어깨45-47/총장63-66 범위 중앙값"),
    ("윌슨", "Wilson Korea", "글로벌", "남성상의(표준매핑)", "M(95)", 47.5, 51, 66.5, "", "", "", "", "", "", "", "https://www.wilson.co.kr", "상", "FALSE", "가슴49.5-52.5/어깨46.5-48.5/총장65-68"),
    ("윌슨", "Wilson Korea", "글로벌", "남성상의(표준매핑)", "L(100)", 49, 53.5, 68.5, "", "", "", "", "", "", "", "https://www.wilson.co.kr", "상", "FALSE", "가슴52-55/어깨48-50/총장67-70"),
    ("윌슨", "Wilson Korea", "글로벌", "남성상의(표준매핑)", "XL(105)", 50.5, 56, 70.5, "", "", "", "", "", "", "", "https://www.wilson.co.kr", "상", "FALSE", "가슴54.5-57.5/어깨49.5-51.5/총장69-72"),
    ("윌슨", "Wilson Korea", "글로벌", "여성하의(표준매핑)", "S(85)", "", "", "", "", 32.5, "", 28.5, "", "", "", "https://www.wilson.co.kr", "상", "FALSE", "허리단면31-34/엉덩이46-49/허벅지27-30 중앙값"),
    ("윌슨", "Wilson Korea", "글로벌", "여성하의(표준매핑)", "M(90)", "", "", "", "", 35, "", 30, "", "", "", "https://www.wilson.co.kr", "상", "FALSE", "허리33.5-36.5/엉덩이48.5-51.5/허벅지28.5-31.5"),
]

# =====================================================================
# 3) 의류 perception (apparel_perception.csv)
# =====================================================================
AP_PER_COLS = [
    "brand_ko", "brand_en", "domestic_global", "category",
    "fit_tendency", "recommend_adjustment", "silhouette",
    "price_min_krw", "price_max_krw",
    "brand_domain", "collected_date", "source_url", "reliability", "manual_collection", "note",
]
_AP_PER = [
    ("무신사 스탠다드", "MUSINSA STANDARD", "국내", "맨투맨/후드", "크게", "정사이즈", "오버핏", 24990, 75590, "", "하", "TRUE", "엑스트라오버 등. 같은사이즈 길이편차 후기. cm 수동수집"),
    ("무신사 스탠다드", "MUSINSA STANDARD", "국내", "반팔티(릴렉스핏)", "정사이즈", "정사이즈", "릴렉스/루즈", 13890, 15900, "", "하", "TRUE", "L=100~105급. 중고실측. 만족도통계 로그인게이트"),
    ("스파오", "SPAO", "국내", "맨투맨", "정사이즈", "정사이즈", "레귤러", 39900, 39900, "", "하", "FALSE", "105 어깨60/가슴63/총장70. 중고실측+리뷰"),
    ("탑텐", "TOPTEN10", "국내", "반팔티(베이직)", "정사이즈", "정사이즈", "베이식 레귤러", 12900, 12900, "", "하", "TRUE", "3PACK. cm 수동수집"),
    ("에잇세컨즈", "8SECONDS", "국내", "셔츠/팬츠", "정사이즈", "정사이즈", "슬림핏", 19900, 23900, "", "하", "FALSE", "같은사이즈 편차 평"),
    ("자라", "ZARA", "글로벌", "티/팬츠", "크게", "한치수작게", "오버핏", 18000, 32000, "", "하", "FALSE", "EU사이즈, 소매 길게, 편차 큼. 바지 EU-10≈한국"),
    ("커버낫", "Covernat", "국내", "맨투맨(오버핏)", "정사이즈", "정사이즈", "오버핏", "", "", "", "하", "FALSE", "공식 실측표는 apparel_official 참조"),
    ("디스이즈네버댓", "thisisneverthat", "국내", "반팔티", "크게", "정사이즈", "스트릿 오버핏", "", "", "", "하", "FALSE", "S 어깨47/가슴53/총장71. 중고"),
    ("마하그리드", "mahagrid", "국내", "맨투맨", "크게", "정사이즈", "오버핏", 29000, 54000, "", "하", "FALSE", "L 총장68/가슴62. 중고실측"),
    ("예일", "YALE", "국내", "맨투맨", "크게", "정사이즈", "세미오버~오버", 34500, 59000, "", "하", "FALSE", "편차 있음. 중고"),
    ("인사일런스", "insilence", "국내", "맨투맨", "크게", "정사이즈", "오버핏(드롭숄더)", 33000, 132000, "", "하", "FALSE", "M 가슴62/총장68/어깨63. 중고+자사몰"),
    ("라이풀", "LIFUL", "국내", "맨투맨", "크게", "정사이즈", "미니멀 오버핏", 59000, 79000, "", "하", "TRUE", "cm 수동수집"),
    ("노스페이스", "The North Face", "글로벌", "눕시 자켓", "크게", "한치수작게", "오버핏", 280000, 399000, "", "하", "FALSE", "다운볼륨 큼·팔통 길다. 이너 적으면 다운"),
    ("코오롱스포츠/디스커버리", "Discovery", "국내", "플리스", "정사이즈", "정사이즈", "레귤러~세미오버", "", "", "", "하", "FALSE", "후리스95 총기장69/어깨46/가슴55"),
    ("아더에러", "ADER error", "국내", "상의", "크게", "정사이즈", "세미오버", "", "", "", "하", "TRUE", "1/2/3 사이즈. cm 수동수집"),
    ("츄", "CHUU", "국내", "원피스", "작게", "정사이즈", "슬림/크롭", "", "", "", "하", "FALSE", "ONE 어깨29/가슴37+(밴딩). 리셀러"),
    ("육육걸즈", "66girls", "국내", "블라우스/원피스", "작게", "정사이즈", "슬림", "", "", "", "하", "TRUE", "FREE 편차큼(가슴77 vs 90). snapfit CDN 봇차단→수동"),
]

# =====================================================================
# 4) 맵기 (spiciness.csv)
# =====================================================================
SP_COLS = [
    "product_ko", "product_en", "brand_ko", "brand_en", "category", "container",
    "data_type", "scoville_shu", "scoville_min", "scoville_max",
    "measured_on", "version_year", "spice_level_label", "perceived_level",
    "price_min_krw", "price_max_krw",
    "brand_domain", "collected_date", "source_url", "reliability", "manual_collection", "note",
]
_SP = [
    # 삼양 불닭 시리즈 official
    ("불닭볶음면", "Buldak", "삼양식품", "Samyang", "라면-볶음", "봉지", "official_spec", 4404, "", "", "스프", "", "", "", "", "", "https://namu.wiki/w/불닭볶음면/자매품/라면류", "중", "FALSE", "시리즈 기준 앵커"),
    ("불닭볶음탕면", "Buldak Soup", "삼양식품", "Samyang", "라면-국물", "봉지", "official_spec", 4705, "", "", "스프", "", "", "", "", "", "https://namu.wiki/w/불닭볶음면/자매품/라면류", "중", "FALSE", "국물형"),
    ("불닭볶음면(큰컵)", "Buldak Big Cup", "삼양식품", "Samyang", "라면-볶음", "큰컵", "official_spec", 3210, "", "", "소스", "", "", "", "", "", "https://namu.wiki/w/불닭볶음면/자매품/라면류", "중", "FALSE", "컵은 봉지보다 낮음"),
    ("까르보불닭볶음면", "Carbo Buldak", "삼양식품", "Samyang", "라면-볶음", "봉지", "official_spec", "", 2300, 2400, "소스", "", "", "", "", "", "https://namu.wiki/w/불닭볶음면/자매품/라면류", "중", "FALSE", "출처충돌 2300 vs 2400"),
    ("짜장불닭볶음면", "Jjajang Buldak", "삼양식품", "Samyang", "라면-볶음", "봉지", "official_spec", 2000, "", "", "소스", "", "", "", "", "", "https://namu.wiki/w/불닭볶음면/자매품/라면류", "중", "FALSE", ""),
    ("마라불닭볶음면", "Mala Buldak", "삼양식품", "Samyang", "라면-볶음", "봉지", "official_spec", 4400, "", "", "소스", "", "", "", "", "", "https://namu.wiki/w/불닭볶음면/자매품/라면류", "중", "FALSE", "'핵불닭2배'는 낭설, 오리지널과 거의 동급"),
    ("치즈불닭볶음면(큰컵)", "Cheese Buldak Big Cup", "삼양식품", "Samyang", "라면-볶음", "큰컵", "official_spec", 2755, "", "", "소스", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", ""),
    ("핵불닭볶음면", "Nuclear Buldak", "삼양식품", "Samyang", "라면-볶음", "봉지", "official_spec", 8706, "", "", "소스", 2017, "", "", "", "", "https://namu.wiki/w/핵불닭볶음면", "중", "FALSE", "최초 버전"),
    ("핵불닭볶음면", "Nuclear Buldak", "삼양식품", "Samyang", "라면-볶음", "봉지", "official_spec", 10000, "", "", "소스", 2018, "", "", "", "", "https://namu.wiki/w/핵불닭볶음면", "중", "FALSE", "2018 리뉴얼 상향"),
    ("핵불닭볶음면 미니", "Nuclear Buldak Mini", "삼양식품", "Samyang", "라면-볶음", "봉지", "official_spec", 12000, "", "", "소스", 2019, "", "", "", "", "https://namu.wiki/w/핵불닭볶음면", "중", "FALSE", "국내 라인업 내 최고. 7-ELEVEN 공식SNS 표기"),
    ("핵불닭볶음면(큰컵)", "Nuclear Buldak Big Cup", "삼양식품", "Samyang", "라면-볶음", "큰컵", "official_spec", 6504, "", "", "소스", "", "", "", "", "", "https://namu.wiki/w/핵불닭볶음면", "중", "FALSE", ""),
    ("핵불닭볶음면 3x", "Nuclear Buldak 3x", "삼양식품", "Samyang", "라면-볶음", "봉지", "official_spec", 13000, "", "", "소스", "", "", "", "", "", "https://namu.wiki/w/핵불닭볶음면", "중", "FALSE", "해외 수출 전용"),
    # 기타 라면 official/집계
    ("틈새라면 빨계떡", "Teumsae", "팔도", "Paldo", "라면-국물", "봉지", "official_spec", 9413, "", "", "스프", 2017, "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", "2017 리뉴얼. 봉지 최상위권"),
    ("열라면", "Yeul Ramen", "오뚜기", "Ottogi", "라면-국물", "봉지", "official_spec", 5013, "", "", "스프", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", ""),
    ("괄도네넴띤", "Gwaldo", "팔도", "Paldo", "라면-비빔", "봉지", "official_spec", 5894, "", "", "소스", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", "팔도비빔면 한정판"),
    ("도전 하바네로라면", "Habanero", "이마트", "Emart", "라면-국물", "봉지", "official_spec", 5930, "", "", "스프", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", "PB. 본문엔 5903 충돌"),
    ("신라면 더 레드", "Shin Red", "농심", "Nongshim", "라면-국물", "봉지", "official_spec", 7500, "", "", "스프", "", "", "", "", "", "https://www.newsspace.kr/news/article.html?no=7953", "중", "FALSE", "신라면 매운버전"),
    ("앵그리 너구리", "Angry Neoguri", "농심", "Nongshim", "라면-국물", "봉지", "official_spec", 6080, "", "", "스프", "", "", "", "", "", "https://www.newsspace.kr/news/article.html?no=7953", "중", "FALSE", ""),
    ("맵탱", "Maeptang", "삼양식품", "Samyang", "라면-국물", "봉지", "official_spec", 6000, "", "", "스프", "", "", "", "", "", "https://www.newsspace.kr/news/article.html?no=7953", "중", "FALSE", "3종"),
    ("장인라면 맵싸한맛", "Jangin Spicy", "하림", "Harim", "라면-국물", "봉지", "official_spec", 8000, "", "", "스프", "", "", "", "", "", "https://www.newsspace.kr/news/article.html?no=7953", "중", "FALSE", ""),
    ("팔도비빔면", "Paldo Bibimmyeon", "팔도", "Paldo", "라면-비빔", "봉지", "official_spec", 2652, "", "", "소스", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", ""),
    ("팔도 쫄비빔면", "Jjol Bibim", "팔도", "Paldo", "라면-비빔", "봉지", "official_spec", 2769, "", "", "소스", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", ""),
    ("너구리", "Neoguri", "농심", "Nongshim", "라면-국물", "봉지", "official_spec", 2300, "", "", "스프", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", "오징어짬뽕 동급"),
    ("진라면 매운맛", "Jin Spicy", "오뚜기", "Ottogi", "라면-국물", "봉지", "perception", "", 2000, 3000, "스프", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", "소비자맞춰 2000→3000 상향 보도"),
    ("진라면 순한맛", "Jin Mild", "오뚜기", "Ottogi", "라면-국물", "봉지", "perception", 640, "", "", "스프", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", ""),
    ("삼양라면 매운맛", "Samyang Spicy", "삼양식품", "Samyang", "라면-국물", "봉지", "perception", 3000, "", "", "스프", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", ""),
    ("삼양라면", "Samyang Ramen", "삼양식품", "Samyang", "라면-국물", "봉지", "perception", 950, "", "", "스프", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", ""),
    ("신라면", "Shin Ramyun", "농심", "Nongshim", "라면-국물", "봉지", "perception", 1300, "", "", "스프", 2012, "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", "과거 집계값. 연도차 주의"),
    ("신라면", "Shin Ramyun", "농심", "Nongshim", "라면-국물", "봉지", "perception", 3400, "", "", "스프", 2022, "", "", "", "", "https://www.newstopkorea.com/news/articleView.html?idxno=29816", "중", "FALSE", "2022 상향. 연도차로 행분리"),
    ("안성탕면", "Ansungtangmyun", "농심", "Nongshim", "라면-국물", "봉지", "perception", 570, "", "", "스프", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", "순한 축"),
    # 제3자 고SHU
    ("염라대왕라면", "Yeomra", "아름", "Areum", "라면-국물", "봉지", "perception", 21000, "", "", "스프", "", "", "극강", "", "", "https://www.newsspace.kr/news/article.html?no=7953", "하", "TRUE", "랭킹집계·추정. 제조사 공식확인 어려움"),
    ("불마왕라면", "Bulmawang", "금비유통", "Geumbi", "라면-국물", "봉지", "perception", 14444, "", "", "스프", "", "", "극강", "", "", "https://www.newsspace.kr/news/article.html?no=7953", "하", "TRUE", "랭킹집계·추정"),
    ("킹뚜껑", "King Cup", "팔도", "Paldo", "라면-국물", "컵", "perception", 12000, "", "", "소스", "", "", "매우매움", "", "", "https://www.newsspace.kr/news/article.html?no=7953", "하", "TRUE", "랭킹집계·추정"),
    # 소스·떡볶이·스낵
    ("타바스코 소스", "Tabasco", "맥일레니", "McIlhenny", "소스", "병", "official_spec", "", 2500, 5000, "원물", "", "", "", "", "", "https://ko.wikipedia.org/wiki/스코빌_척도", "중", "FALSE", "기준선"),
    ("엽기떡볶이 오리지널", "Yupdduk Original", "엽기떡볶이", "Yupdduk", "떡볶이", "_general", "perception", "", "", "", "완성품", "", "고추3개", "매움", "", "", "", "하", "TRUE", "SHU 미표기, 고추 단계만(착한0.5/덜1/오리지널3/매운5)"),
    ("엽기떡볶이 매운맛", "Yupdduk Hot", "엽기떡볶이", "Yupdduk", "떡볶이", "_general", "perception", "", "", "", "완성품", "", "고추5개", "극강", "", "", "", "하", "TRUE", "쿨피스없이 먹으면 인정 평. SHU 미표기"),
    ("파퀴칩(죽음의 과자)", "Paqui Chip", "파퀴", "Paqui", "스낵", "_general", "official_spec", "", 2000000, 2200000, "완성품", "", "", "극강", "", "", "https://ko.wikipedia.org/wiki/스코빌_척도", "중", "FALSE", "캐롤라이나 리퍼 사용. 해외 비교 기준선"),
    # 고추·기준선 reference
    ("풋고추", "Green Pepper", "_기준선", "Reference", "고추기준", "원물", "official_spec", "", 1000, 2000, "원물", "", "", "", "", "", "https://catalk.kr/food/hottest-ramen.html", "중", "FALSE", "신라면보다 약간 매움"),
    ("청양고추", "Cheongyang", "_기준선", "Reference", "고추기준", "원물", "official_spec", "", 4000, 12000, "원물", "", "", "", "", "", "https://namu.wiki/w/청양고추", "중", "FALSE", "한국 매운맛 대명사. 평균 약10000"),
    ("할라피뇨", "Jalapeno", "_기준선", "Reference", "고추기준", "원물", "official_spec", "", 2500, 10000, "원물", "", "", "", "", "", "https://ko.wikipedia.org/wiki/스코빌_척도", "중", "FALSE", "기준선"),
    ("부트졸로키아(귀신고추)", "Bhut Jolokia", "_기준선", "Reference", "고추기준", "원물", "official_spec", "", 80000, 1000000, "원물", "", "", "", "", "", "https://ko.wikipedia.org/wiki/스코빌_척도", "중", "FALSE", "기준선"),
    ("캐롤라이나 리퍼", "Carolina Reaper", "_기준선", "Reference", "고추기준", "원물", "official_spec", "", 1570000, 2200000, "원물", "", "", "극강", "", "", "https://ko.wikipedia.org/wiki/스코빌_척도", "중", "FALSE", "기네스 최고기록급"),
    ("순수 캡사이신", "Pure Capsaicin", "_기준선", "Reference", "고추기준", "원물", "official_spec", "", 15000000, 16000000, "원물", "", "", "극강", "", "", "https://ko.wikipedia.org/wiki/스코빌_척도", "중", "FALSE", "이론 최대. ppm×16=SHU"),
]

# =====================================================================
# 5) 음식양 (food_portions.csv)
# =====================================================================
FP_COLS = [
    "item_ko", "item_en", "brand_ko", "brand_en", "category",
    "portion_type", "data_type",
    "amount_value", "amount_unit", "amount_min", "amount_max", "calorie_kcal",
    "price_min_krw", "price_max_krw",
    "brand_domain", "collected_date", "source_url", "reliability", "manual_collection", "note",
]
_FP = [
    # 식약처 1회 섭취참고량 official
    ("밥", "Rice", "식약처", "MFDS", "밥류", "섭취참고량", "official_spec", 210, "g", "", "", "", "", "", "", "https://www.law.go.kr", "상", "FALSE", "곡류·전분 식품군 별표3"),
    ("유탕면(봉지라면)", "Instant Noodle", "식약처", "MFDS", "면류", "섭취참고량", "official_spec", 120, "g", "", "", "", "", "", "", "https://www.law.go.kr", "상", "FALSE", "면 기준 별표3"),
    ("과자(강냉이·팝콘)", "Snack", "식약처", "MFDS", "과자", "섭취참고량", "official_spec", 20, "g", "", "", "", "", "", "", "https://www.law.go.kr", "상", "FALSE", "과자류 세부유형별 상이"),
    ("시리얼", "Cereal", "식약처", "MFDS", "기타", "섭취참고량", "official_spec", 30, "g", "", "", "", "", "", "", "https://www.law.go.kr", "상", "FALSE", "별표3"),
    ("아이스크림", "Ice Cream", "식약처", "MFDS", "기타", "섭취참고량", "official_spec", 100, "g", "", "", "", "", "", "", "https://www.law.go.kr", "상", "FALSE", "1/2컵 별표3"),
    ("음료베이스(농축액·분말)", "Beverage Base", "식약처", "MFDS", "음료", "섭취참고량", "official_spec", 150, "mL", "", "", "", "", "", "", "https://www.law.go.kr", "상", "FALSE", "* 범위로만 사용 표기 대상"),
    ("빵류", "Bread", "식약처", "MFDS", "기타", "섭취참고량", "official_spec", 70, "g", "", "", "", "", "", "", "", "하", "TRUE", "추정. 별표3 원문 대조 필요"),
    ("우유", "Milk", "식약처", "MFDS", "음료", "섭취참고량", "official_spec", 200, "mL", "", "", "", "", "", "", "", "하", "TRUE", "추정. 별표3 원문 대조 필요"),
    # 버거 완제품 official
    ("빅맥", "Big Mac", "맥도날드", "McDonald's", "버거", "완제품", "official_spec", 223, "g", "", "", 582, "", "", "", "https://www.mcdonalds.co.kr", "상", "FALSE", "공식 영양정보"),
    ("한우불고기버거", "Hanwoo Bulgogi", "롯데리아", "Lotteria", "버거", "완제품", "official_spec", 263, "g", "", "", 572, "", "", "", "https://www.lotteeatz.com", "상", "FALSE", "2021.7 리뉴얼 패티+28%"),
    ("불고기버거", "Bulgogi Burger", "롯데리아", "Lotteria", "버거", "완제품", "official_spec", 188, "g", "", "", 476, "", "", "", "https://www.lotteeatz.com", "상", "FALSE", ""),
    ("더블한우불고기버거", "Double Hanwoo", "롯데리아", "Lotteria", "버거", "완제품", "official_spec", 352, "g", "", "", 802, "", "", "", "https://www.lotteeatz.com", "상", "FALSE", ""),
    ("와퍼", "Whopper", "버거킹", "Burger King", "버거", "완제품", "official_spec", "", "g", "", "", "", "", "", "", "", "하", "TRUE", "공식 g 미확보 데이터없음. 수동"),
    # 분식·즉석조리 perception
    ("김밥 1줄", "Gimbap", "김밥천국", "Gimbap Cheonguk", "분식", "1인분", "perception", "", "g", 200, 300, 485, "", "", "", "https://www.pillyze.com", "하", "FALSE", "300g≈485kcal 집계. 200g기준 350~450 집계도"),
    ("야채김밥 1줄", "Veggie Gimbap", "김밥천국", "Gimbap Cheonguk", "분식", "1인분", "perception", "", "g", 200, 250, 360, "", "", "", "https://www.inout.team", "하", "FALSE", "매장·집계차"),
    ("떡볶이 1인분", "Tteokbokki", "김밥천국", "Gimbap Cheonguk", "분식", "1인분", "perception", 250, "g", "", "", 366, "", "", "", "https://www.pillyze.com", "하", "FALSE", "일반 200g≈300kcal"),
    ("치즈떡볶이 1인분", "Cheese Tteokbokki", "김밥천국", "Gimbap Cheonguk", "분식", "1인분", "perception", 300, "g", "", "", 486, "", "", "", "https://www.pillyze.com", "하", "FALSE", ""),
    ("후라이드치킨", "Fried Chicken", "교촌", "Kyochon", "치킨", "1인분", "perception", "", "g", "", "", "", "", "", "", "https://www.consumernews.co.kr/news/articleView.html?idxno=735384", "하", "TRUE", "즉석조리=중량공개의무없음. 100g당 약370kcal, 조리전 약900g 단일출처. 정부 g표기 추진"),
]


def main():
    write_csv("beverages.csv", BEV_COLS, [list(r[:11]) + [domain_for(r[1], r[0]), COLLECTED] + list(r[11:]) for r in _BEV])
    write_csv("apparel_official.csv", AP_OFF_COLS, [list(r[:15]) + [domain_for(r[1], r[0]), COLLECTED] + list(r[15:]) for r in _AP_OFF])
    write_csv("apparel_perception.csv", AP_PER_COLS, [list(r[:9]) + [domain_for(r[1], r[0]), COLLECTED] + list(r[9:]) for r in _AP_PER])
    write_csv("spiciness.csv", SP_COLS, [list(r[:16]) + [domain_for(r[3], r[2]), COLLECTED] + list(r[16:]) for r in _SP])
    write_csv("food_portions.csv", FP_COLS, [list(r[:14]) + [domain_for(r[3], r[2]), COLLECTED] + list(r[15:]) for r in _FP])


if __name__ == "__main__":
    main()
