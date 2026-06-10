# -*- coding: utf-8 -*-
"""
브랜드 → 공식 도메인 매핑 (로고/파비콘 렌더링용).

앱은 이 도메인으로 무료 파비콘 서비스에서 로고를 런타임에 불러온다.
  예) https://www.google.com/s2/favicons?domain={brand_domain}&sz=128
      https://icons.duckduckgo.com/ip3/{brand_domain}.ico

원칙:
- 도메인을 지어내지 않는다. 확신 없는 브랜드는 빈 문자열('')로 두고 나중에 보강.
  (빈값이면 앱이 폴백 아이콘/머리글자를 보여주면 됨)
- 글로벌 브랜드는 .com 본사 도메인을 우선(파비콘이 거의 항상 해석됨).
- brand_en 우선, 없으면 brand_ko 로 조회.
"""

# brand_en(영문) 기준
_BY_EN = {
    # --- 신발: 글로벌 ---
    "Nike": "nike.com", "Adidas": "adidas.com", "adidas": "adidas.com",
    "New Balance": "newbalance.com",
    "ASICS": "asics.com", "Converse": "converse.com", "Vans": "vans.com",
    "HOKA": "hoka.com", "Salomon": "salomon.com", "Dr. Martens": "drmartens.com",
    "Birkenstock": "birkenstock.com", "Crocs": "crocs.com", "PUMA": "puma.com",
    # --- 신발: 국산 ---
    "PRO-SPECS": "prospecs.com", "Kumkang": "kumkang.com",
    "MUSINSA STANDARD": "musinsa.com", "DESCENTE": "descente.com",
    "thisisneverthat": "thisisneverthat.com", "KOLON SPORT": "kolonsport.com",
    "K2": "k2.co.kr", "BLACKYAK": "blackyak.com",
    # --- 음료 ---
    "Starbucks": "starbucks.com", "A Twosome Place": "twosome.co.kr",
    "Paul Bassett": "paulbassett.co.kr", "Compose Coffee": "composecoffee.com",
    "The Venti": "theventi.co.kr", "The Liter": "theliter.com",
    "EDIYA": "ediya.com", "TOM N TOMS": "tomntoms.com",
    "Tim Hortons": "timhortons.com", "Gong cha": "gong-cha.com",
    "Smoothie King": "smoothieking.com", "McDonald's": "mcdonalds.com",
    "Lotteria": "lotteria.com", "Burger King": "burgerking.com",
    "The Coffee Bean": "coffeebeankorea.com", "Paik's Coffee": "paikdabang.com",
    # --- 의류 ---
    "UNIQLO": "uniqlo.com", "ZARA": "zara.com", "Covernat": "covernat.net",
    "The North Face": "thenorthface.com", "IMVELY": "imvely.com",
    "Wilson Korea": "wilson.com", "8SECONDS": "ssfshop.com",
    "Discovery": "discovery-expedition.com",
    # --- 맵기(라면/식품 제조사) ---
    "Samyang": "samyangfoods.com", "Nongshim": "nongshim.com",
    "Ottogi": "ottogi.co.kr", "Harim": "harim.com", "Emart": "emart.com",
    "Paqui": "paqui.com",
    # --- 음식양 ---
    "MFDS": "mfds.go.kr", "Kyochon": "kyochon.com",
}

# brand_ko(한글) 보조 키 (영문 키로 못 잡는 국산 브랜드 일부)
_BY_KO = {
    "롯데리아": "lotteria.com", "버거킹": "burgerking.com",
    "농심": "nongshim.com", "오뚜기": "ottogi.co.kr", "삼양식품": "samyangfoods.com",
    "팔도": "paldofood.co.kr", "교촌": "kyochon.com", "식약처": "mfds.go.kr",
    "할리스": "hollys.com", "엔제리너스": "angelinus.com",
    "스파오": "spao.com", "탑텐": "topten.shinsung.co.kr",
    "네파": "nepa.co.kr", "엽기떡볶이": "yupdduk.com",
}


def domain_for(brand_en="", brand_ko=""):
    """brand_en 우선, 없으면 brand_ko 로 도메인 조회. 없으면 ''."""
    if brand_en and brand_en in _BY_EN:
        return _BY_EN[brand_en]
    if brand_ko and brand_ko in _BY_KO:
        return _BY_KO[brand_ko]
    return ""
