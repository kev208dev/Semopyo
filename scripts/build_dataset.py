# -*- coding: utf-8 -*-
"""
세모표 신발 사이즈 데이터셋 생성기.

research_shoes.md를 사람이 파싱해 아래 ROWS 스키마로 매핑한 결과를 담고 있다.
실행하면 data/shoes_sizing.csv (UTF-8 with BOM) 와
data/manual_todo.csv (manual_collection=TRUE 행) 를 생성한다.

원칙:
- 데이터를 지어내지 않는다. 근거 없는 수치는 '' 로 비우고 note 에 "데이터없음" 표기.
- 공식 스펙(official_spec)과 체감(perception)은 절대 한 행에 섞지 않는다.
- 모델 편차는 model_line 으로 행을 나눈다.
- source_url 이 비면 reliability 는 '하' (validate.py 가 강제).
"""
import csv
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from brand_domains import domain_for
from _data_paths import dpath  # data/ 하위폴더 경로 해석

COLLECTED = "2026-06-09"

COLUMNS = [
    "brand_ko", "brand_en", "origin", "model_line", "data_type",
    "label_size_mm", "designed_foot_length_mm", "insole_length_mm",
    "fit_verdict", "adjustment_reco", "toebox_width", "stiffness",
    "price_min_krw", "price_max_krw", "brand_domain", "collected_date", "source_url",
    "reliability", "manual_collection", "note",
]

# 각 튜플은 COLUMNS 와 동일한 순서. collected_date 는 생성시 주입.
# (brand_ko, brand_en, origin, model_line, data_type, label, designed, insole,
#  fit, adj, toebox, stiff, pmin, pmax, url, rel, manual, note)
_R = [
    # ===== A. 글로벌 브랜드 =====
    # --- 나이키 ---
    ("나이키", "Nike", "글로벌", "_general", "official_spec", 260, 254, "", "", "", "표준", "", "", "", "https://www.nike.com/kr", "상", "FALSE",
     "라벨CM≠발길이; 260=US8/UK7/EU41, 측정 발길이 약 254mm. 발볼 단일 표준폭"),
    ("나이키", "Nike", "글로벌", "_general", "official_spec", 270, 262, "", "", "", "표준", "", "", "", "https://www.nike.com/kr", "상", "FALSE",
     "270=US9/UK8/EU42.5, 측정 발길이 약 262mm"),
    ("나이키", "Nike", "글로벌", "_general", "official_spec", 280, 271, "", "", "", "표준", "", "", "", "https://www.nike.com/kr", "상", "FALSE",
     "280=US10/UK9/EU44, 측정 발길이 약 271mm. 치수 중간이면 한 사이즈 크게 권장"),
    ("나이키", "Nike", "글로벌", "Air Force 1", "perception", 270, "", "", "크게", "-5mm", "좁음", "", 120000, 190000, "", "하", "FALSE",
     "에어포스1 크게 나옴: 발볼 보통/좁으면 반다운, 넓으면 정사이즈. 커뮤니티 체감(URL없어 하 강등)"),
    ("나이키", "Nike", "글로벌", "Dunk·Jordan 1", "perception", 270, "", "", "작게", "+5mm", "좁음", "", 120000, 190000, "", "하", "FALSE",
     "덩크/조던1 타이트(작게 나옴) → 반업. 발볼 좁음"),
    ("나이키", "Nike", "글로벌", "SB Dunk·Run", "perception", 270, "", "", "작게", "+5mm", "좁음", "", 120000, 190000, "", "하", "FALSE",
     "SB덩크/런 패딩·볼 두툼 → 반업. 발볼 좁음"),
    ("나이키", "Nike", "글로벌", "농구화 EP", "perception", 270, "", "", "정사이즈", "정사이즈", "넓음", "", 120000, 190000, "", "하", "FALSE",
     "농구화 EP 버전 살짝 와이드(발볼 넓음)"),

    # --- 아디다스 ---
    ("아디다스", "adidas", "글로벌", "_general", "official_spec", "", "", "", "", "", "", "", "", "", "", "하", "FALSE",
     "공식 라벨↔발길이 표 미공개; FR 기준 US9 약 272.5mm 측정, US/UK 매칭이 나이키와 다름. 라벨mm 데이터없음"),
    ("아디다스", "adidas", "글로벌", "삼바·가젤", "perception", 270, "", "", "작게", "+5mm", "좁음", "", 80000, 200000, "", "하", "FALSE",
     "삼바/가젤 좁고 낮음(발볼러 지장) → 반업~1업. 1업은 발볼러 착화 필요"),
    ("아디다스", "adidas", "글로벌", "슈퍼스타", "perception", 270, "", "", "크게", "-5mm", "표준", "", 80000, 200000, "", "하", "FALSE",
     "슈퍼스타 크게 나옴 → 반다운"),
    ("아디다스", "adidas", "글로벌", "울트라부스트", "perception", 270, "", "", "정사이즈", "정사이즈", "표준", "", 80000, 200000, "", "하", "FALSE",
     "울트라부스트 구버전 발등 압박, 21이후 개선. 현행 정사이즈"),
    ("아디다스", "adidas", "글로벌", "이지부스트 350", "perception", 270, "", "", "작게", "1업", "좁음", "", 80000, 200000, "", "하", "FALSE",
     "이지부스트350 극단적 좁음 → 1업 국룰. 1업은 착화 필요(좁음)"),

    # --- 뉴발란스 ---
    ("뉴발란스", "New Balance", "글로벌", "_general", "official_spec", 270, "", "", "", "", "표준", "", "", "", "https://www.nbkorea.com", "상", "FALSE",
     "mm 표기(220~310,5mm단위); 발볼 공식 남D(표준)/2E/4E, 여B(표준)/D/4E; 270mm→US9 환산 비공식"),
    ("뉴발란스", "New Balance", "글로벌", "990v3~v5·993(SL-2)", "perception", 270, "", "", "크게", "-5mm", "넓음", "", 200000, 300000, "", "하", "FALSE",
     "SL-2 라스트 넓음 → 발볼 보통이면 반다운 가능"),
    ("뉴발란스", "New Balance", "글로벌", "990v1·991·997(SL-1)", "perception", 270, "", "", "작게", "+5mm", "좁음", "", 200000, 300000, "", "하", "FALSE",
     "SL-1 라스트 표준~좁음; 991/1500 앞코 뾰족 → 발볼러 반업"),
    ("뉴발란스", "New Balance", "글로벌", "2002R·1906R", "perception", 270, "", "", "작게", "+5mm", "좁음", "", 200000, 300000, "", "하", "FALSE",
     "2002R/1906R(베트남/중국 생산) 작게 나옴 → 반업"),
    ("뉴발란스", "New Balance", "글로벌", "990v6", "perception", 270, "", "", "작게", "+5mm", "좁음", "", 200000, 300000, "", "하", "FALSE",
     "990v6 길이·발볼 좁음"),
    ("뉴발란스", "New Balance", "글로벌", "327", "perception", 270, "", "", "크게", "-5mm", "표준", "", 100000, 160000, "", "하", "FALSE",
     "327 약간 크게(발볼 보통이면 반다운). 라이프스타일"),
    ("뉴발란스", "New Balance", "글로벌", "574", "perception", 270, "", "", "크게", "-5mm", "넓음", "", 100000, 160000, "", "하", "FALSE",
     "574 라스트 넓음 → 반다운 가능. 라이프스타일"),

    # --- 아식스 ---
    ("아식스", "ASICS", "글로벌", "_general", "official_spec", 270, 265, "", "", "", "표준", "", "", "", "https://www.asics.co.kr", "중", "TRUE",
     "라벨mm; CM(발길이) 약 라벨−5mm; 발볼 D/2E/4E, 2E=일본 표준. 정확 mm↔CM은 JS렌더 차트 브라우저 확인 필요"),
    ("아식스", "ASICS", "글로벌", "젤카야노14(레트로)", "perception", 270, "", "", "작게", "+5mm", "좁음", "", 110000, 160000, "https://namu.wiki/w/ASICS", "중", "FALSE",
     "레트로 복각 갑피 얇음·토박스 좁음 → 반업"),
    ("아식스", "ASICS", "글로벌", "젤카야노30·31·32", "perception", 270, "", "", "정사이즈", "정사이즈", "넓음", "", 150000, 250000, "https://namu.wiki/w/ASICS", "중", "FALSE",
     "최신 젤카야노 정사이즈 OK; 발볼 넓은 발 편함, 칼발은 힐슬립 가능"),

    # --- 컨버스 ---
    ("컨버스", "Converse", "글로벌", "척테일러", "perception", 270, "", "", "크게", "-5mm", "표준", "짱짱함", "", "", "", "하", "FALSE",
     "척테일러 크게(정사 안 들 정도) → 반다운; 발볼 넓으면 정사. 1업+꽉맞춤 스타일 오버사이징 문화. 다운=착화/1업=스타일. 가격 데이터없음"),

    # --- 반스 ---
    ("반스", "Vans", "글로벌", "_general", "perception", 270, "", "", "작게", "+5mm", "좁음", "", "", "", "", "하", "FALSE",
     "슬립온/Sk8/올드스쿨 정사 약간 작음·내부 좁음; 슬립온 발등 매우 낮음. 얇은 양말 1업/두꺼운 양말·맨발 반업. 가격 데이터없음"),

    # --- 호카 ---
    ("호카", "HOKA", "글로벌", "_general", "perception", 270, "", "", "작게", "+5mm", "좁음", "", 160000, 250000, "", "하", "FALSE",
     "힐슬립; 대부분 모델 반업 추천; 본래 좁고 타이트; 발볼 넓으면 WIDE 필요"),
    ("호카", "HOKA", "글로벌", "클리프턴", "perception", 270, "", "", "정사이즈", "정사이즈", "좁음", "", 160000, 250000, "", "하", "FALSE",
     "클리프턴은 정사이즈 가까움"),

    # --- 살로몬 ---
    ("살로몬", "Salomon", "글로벌", "XT-6", "perception", 270, "", "", "작게", "+5mm", "좁음", "", 210000, 260000, "", "하", "FALSE",
     "XT-6 발등·발폭 타이트 → 평균발 정사~반업, 발볼러 1~1.5업. 모델·개인차(280 정사 사례 존재)"),

    # --- 닥터마틴 ---
    ("닥터마틴", "Dr. Martens", "글로벌", "_general", "official_spec", 260, 260, "", "", "", "", "짱짱함", "", "", "https://www.drmartens.com", "상", "FALSE",
     "UK7=US8=EU41=JP26.0cm(발길이260mm). 하프사이즈 없음"),
    ("닥터마틴", "Dr. Martens", "글로벌", "_general", "official_spec", 270, 270, "", "", "", "", "짱짱함", "", "", "https://www.drmartens.com", "상", "FALSE",
     "UK8=EU42=JP27.0cm(발길이270mm)"),
    ("닥터마틴", "Dr. Martens", "글로벌", "_general", "official_spec", 280, 280, "", "", "", "", "짱짱함", "", "", "https://www.drmartens.com", "상", "FALSE",
     "UK9=EU43=JP28.0cm(발길이280mm)"),
    ("닥터마틴", "Dr. Martens", "글로벌", "1460", "perception", 270, "", "", "작게", "1업", "표준", "짱짱함", 135000, 270000, "https://www.drmartens.com", "중", "FALSE",
     "출처충돌(공식 우선): 공식은 반사이즈를 업+깔창으로 보정 권장. 기본 깔창 딱딱·발 통증 흔함"),
    ("닥터마틴", "Dr. Martens", "글로벌", "1460", "perception", 270, "", "", "크게", "-5mm", "표준", "짱짱함", 135000, 270000, "", "하", "FALSE",
     "출처충돌(리테일러): 일부 리테일러(scheels 등) 사이즈 다운 권장. 공식 우선"),

    # --- 버켄스탁 ---
    ("버켄스탁", "Birkenstock", "글로벌", "Regular(폭)", "official_spec", 270, "", "", "", "", "표준", "", "", "", "https://www.birkenstock.com", "상", "FALSE",
     "EU 사이즈만; 남성US9~9½=EU42 약 270mm 발(추정); Regular(Outlined)=표준폭. mm 발길이 공식 미게시(추정)"),
    ("버켄스탁", "Birkenstock", "글로벌", "Narrow(폭)", "official_spec", 270, "", "", "", "", "좁음", "", "", "", "https://www.birkenstock.com", "상", "FALSE",
     "Narrow(Filled)=좁은폭, 여성/좁은발 추천. EU42 약 270mm 발(추정)"),
    ("버켄스탁", "Birkenstock", "글로벌", "보스턴·마드리드", "perception", 270, "", "", "정사이즈", "정사이즈", "", "", "", "", "", "하", "FALSE",
     "모델별 선호; 발볼 좁으면 Narrow, 넓으면 Regular. 정사이즈. 가격 데이터없음"),

    # --- 크록스 ---
    ("크록스", "Crocs", "글로벌", "_general", "official_spec", 250, 250, "", "", "", "넓음", "", "", "", "https://www.crocs.co.kr", "상", "FALSE",
     "mm→US: 250mm=US남6/여8. 소재·디자인따라 10~20mm 오차"),
    ("크록스", "Crocs", "글로벌", "_general", "official_spec", 260, 260, "", "", "", "넓음", "", "", "", "https://www.crocs.co.kr", "상", "FALSE",
     "260mm=US남7/여9"),
    ("크록스", "Crocs", "글로벌", "_general", "official_spec", 270, 270, "", "", "", "넓음", "", "", "", "https://www.crocs.co.kr/size-charts/fit-guide.html", "상", "TRUE",
     "출처충돌(공식 우선): 공식 일부=남성9 vs 다양=남성8/여10. fit-guide.html 직접확인 필요(JS렌더)"),
    ("크록스", "Crocs", "글로벌", "_general", "perception", 270, "", "", "정사이즈", "정사이즈", "넓음", "", "", "", "", "하", "FALSE",
     "대체로 정사이즈, 약간 여유(사이즈다운도 가능). 두툼/편안/표준 착화감. 가격 데이터없음"),

    # --- 푸마 ---
    ("푸마", "PUMA", "글로벌", "팔레르모", "perception", 270, "", "", "정사이즈", "정사이즈", "넓음", "", 90000, 130000, "", "하", "FALSE",
     "팔레르모 발등·발볼 넓어 여유 → 평균발 정사, 발볼러 반업"),
    ("푸마", "PUMA", "글로벌", "스웨이드", "perception", 270, "", "", "작게", "+5mm", "좁음", "", 90000, 130000, "", "하", "FALSE",
     "스웨이드 발볼 좁은 편"),
    ("푸마", "PUMA", "글로벌", "C25K", "perception", 270, "", "", "작게", "+5mm", "좁음", "", 90000, 130000, "", "하", "FALSE",
     "C25K 발볼 좁음, 칼발 아니면 반업"),

    # ===== B. 한국 국산 브랜드 =====
    ("프로스펙스", "PRO-SPECS", "국산", "_general", "official_spec", 270, 270, "", "", "", "", "", "", "", "", "하", "FALSE",
     "라벨mm=발길이 국산 관례(추정); 공식 발길이/깔창 미게시"),
    ("프로스펙스", "PRO-SPECS", "국산", "_general", "perception", 270, "", "", "정사이즈", "정사이즈", "넓음", "", 50000, 70000, "", "하", "FALSE",
     "대체로 정사이즈; 워킹화 일부 약간 커 반다운; 발볼 넓은 편 의견(오스틴101 약 54,500원)"),
    ("르까프", "Le coq sportif Korea", "국산", "_general", "official_spec", 270, 270, "", "", "", "", "", "", "", "", "하", "FALSE",
     "라벨mm=발길이 국산 관례(추정); 발길이/깔창 미게시"),
    ("르까프", "Le coq sportif Korea", "국산", "_general", "perception", 270, "", "", "정사이즈", "정사이즈", "", "", 20000, 70000, "", "하", "FALSE",
     "워킹화 위주 정사이즈 일반적; 가성비(비보 약 19,900원~로키 약 54,900원)"),
    ("금강제화", "Kumkang", "국산", "헤리티지·리갈", "perception", 270, "", "", "정사이즈", "정사이즈", "표준", "보통", 200000, 300000, "", "하", "FALSE",
     "발 편함, AS·포인트 우수, 백화점 보급. 정사이즈는 추정"),
    ("랜드로바", "Landrover", "국산", "볼륨워킹·컴포트", "perception", 270, "", "", "정사이즈", "정사이즈", "넓음", "부드러움", 60000, 240000, "", "하", "FALSE",
     "발볼 넓은 라인 다수, 쿠션 강조, 정장도 편함"),
    ("수에꼼마보니", "SUECOMMA BONNIE", "국산", "_general", "perception", "", "", "", "정사이즈", "정사이즈", "", "", 200000, 400000, "", "하", "FALSE",
     "여성화 정사이즈(EU37 정사 사례); 스트랩탱은 발볼/발등 넓으면 작음→반업. 부츠/뮬 30~40만·샌들 20만대. 라벨mm 데이터없음"),
    ("탠디", "TANDY", "국산", "정장구두", "perception", 270, "", "", "정사이즈", "정사이즈", "좁음", "짱짱함", 140000, 150000, "", "하", "FALSE",
     "발볼 좁은 편 의견; 강성 짱짱함 vs 발편함 의견 공존(개인차). 강성 추정"),
    ("소다", "SODA", "국산", "_general", "perception", "", "", "", "정사이즈", "정사이즈", "좁음", "", "", "", "", "하", "FALSE",
     "여성 구두 정사이즈·발 편함; 칼발용(발볼 좁음); 과거 대비 품질 하락 의견. 라벨mm/가격 데이터없음"),
    ("미소페", "MISOPE", "국산", "컴포트", "perception", "", "", "", "정사이즈", "정사이즈", "표준", "부드러움", "", "", "", "하", "FALSE",
     "컴포트라인 발등·발볼 조절 가능, 매우 편함. 라벨mm/가격 데이터없음"),
    ("에스콰이아", "Esquire", "국산", "_general", "perception", 270, "", "", "크게", "-5mm", "넓음", "", 100000, 200000, "", "하", "FALSE",
     "토 치수 크게 나옴(운동화 75~80인 사람 65~70). 반다운 권장"),
    ("무신사 스탠다드", "MUSINSA STANDARD", "국산", "더비", "perception", 270, "", "", "", "", "", "", 79890, 79890, "", "하", "TRUE",
     "자체 PB 더비 등; 후기 무신사 로그인 게이트 → 수동수집. fit 데이터없음(로그인 필요)"),
    ("데상트", "DESCENTE", "글로벌", "퍼스트", "perception", 270, "", "", "", "", "", "", 120000, 130000, "", "하", "FALSE",
     "데상트코리아 전개(일본계). 스포츠화. fit 데이터없음(퍼스트 V2 129,000원)"),
    ("디스이즈네버댓", "thisisneverthat", "국산", "_general", "perception", 270, "", "", "", "", "", "", "", "", "", "하", "FALSE",
     "스트릿 의류 위주, 신발 사이즈 데이터 희소. fit 데이터없음"),
    ("K2", "K2", "국산", "등산화(고어텍스)", "perception", 270, "", "", "작게", "+5mm", "", "", 129000, 144000, "", "하", "FALSE",
     "등산화 두꺼운 양말·하산 고려 반업 권장. 발볼 모델별 데이터없음. 아웃도어 그룹 일반화"),
    ("코오롱스포츠", "KOLON SPORT", "국산", "등산화", "perception", 270, "", "", "작게", "+5mm", "", "", 130000, 170000, "", "하", "FALSE",
     "등산화 반업 권장(두꺼운 양말). 발볼 모델별 데이터없음. 아웃도어 그룹 일반화"),
    ("블랙야크", "BLACKYAK", "국산", "등산화", "perception", 270, "", "", "작게", "+5mm", "", "", "", "", "", "하", "FALSE",
     "등산화 반업 권장 일반화. 발볼·가격 데이터없음(아웃도어 유사대 언급)"),
    ("네파", "NEPA", "국산", "등산화", "perception", 270, "", "", "작게", "+5mm", "", "", "", "", "", "하", "FALSE",
     "등산화 반업 권장 일반화. 발볼·가격 데이터없음(아웃도어 유사대 언급)"),
    ("데코", "DECCO", "국산", "_general", "perception", 270, "", "", "", "", "", "", "", "", "", "하", "FALSE",
     "구두 브랜드, 공식·체감 데이터 희소(자사몰·중고거래 중심). fit 데이터없음"),
]


def write_csv(path, records):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    # utf-8-sig → 엑셀 한글 깨짐 방지 (BOM)
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.writer(f)
        w.writerow(COLUMNS)
        for r in records:
            r = list(r)
            r.insert(14, domain_for(r[1], r[0]))  # brand_domain 주입(collected 앞)
            r.insert(15, COLLECTED)  # collected_date 주입
            w.writerow(r)


def main():
    all_path = str(dpath("shoes_sizing.csv"))
    todo_path = str(dpath("manual_todo.csv"))

    write_csv(all_path, _R)

    manual = [r for r in _R if r[16] == "TRUE"]  # manual_collection 컬럼(주입 전 인덱스16)
    write_csv(todo_path, manual)

    print("wrote %d rows -> %s" % (len(_R), all_path))
    print("wrote %d manual rows -> %s" % (len(manual), todo_path))


if __name__ == "__main__":
    main()
