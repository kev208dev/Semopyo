# -*- coding: utf-8 -*-
"""
추가 데이터셋(음료/의류/맵기/음식양) 공통 검증기.

검사 항목:
- UTF-8 with BOM (utf-8-sig 로 읽힘)
- 헤더가 스키마와 일치
- 각 행 필드 수가 헤더와 동일
- collected_date 는 YYYY-MM-DD
- data_type 은 official_spec/perception (해당 컬럼 있을 때)
- reliability 는 상/중/하
- source_url 비면 reliability='하' (강등 규칙, 신발 데이터셋과 동일)
- 정수형으로 지정한 컬럼은 정수거나 빈값

사용:  python3 scripts/validate_extra.py
"""
import csv
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _data_paths import rpath  # noqa: E402  (data/ 하위폴더 경로 해석)

DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
REL_OK = {"상", "중", "하"}
DT_OK = {"official_spec", "perception"}

# 파일별: (헤더, 정수컬럼들)
SPECS = {
    "beverages.csv": (
        ["brand_ko", "brand_en", "category", "size_label", "volume_ml", "volume_oz",
         "cup_or_fill", "hot_or_iced", "data_type", "price_krw", "reputation_tag",
         "brand_domain", "collected_date", "source_url", "reliability", "manual_collection", "note"],
        ["volume_ml", "volume_oz", "price_krw"],
    ),
    "apparel_official.csv": (
        ["brand_ko", "brand_en", "domestic_global", "category", "size_label",
         "shoulder_cm", "chest_half_cm", "length_cm", "sleeve_cm", "waist_half_cm",
         "rise_cm", "thigh_cm", "hem_cm", "price_min_krw", "price_max_krw",
         "brand_domain", "collected_date", "source_url", "reliability", "manual_collection", "note"],
        ["price_min_krw", "price_max_krw"],
    ),
    "apparel_perception.csv": (
        ["brand_ko", "brand_en", "domestic_global", "category", "fit_tendency",
         "recommend_adjustment", "silhouette", "price_min_krw", "price_max_krw",
         "brand_domain", "collected_date", "source_url", "reliability", "manual_collection", "note"],
        ["price_min_krw", "price_max_krw"],
    ),
    "spiciness.csv": (
        ["product_ko", "product_en", "brand_ko", "brand_en", "category", "container",
         "data_type", "scoville_shu", "scoville_min", "scoville_max", "measured_on",
         "version_year", "spice_level_label", "perceived_level", "price_min_krw",
         "price_max_krw", "brand_domain", "collected_date", "source_url", "reliability",
         "manual_collection", "note"],
        ["scoville_shu", "scoville_min", "scoville_max", "version_year",
         "price_min_krw", "price_max_krw"],
    ),
    "food_portions.csv": (
        ["item_ko", "item_en", "brand_ko", "brand_en", "category", "portion_type",
         "data_type", "amount_value", "amount_unit", "amount_min", "amount_max",
         "calorie_kcal", "price_min_krw", "price_max_krw", "brand_domain", "collected_date",
         "source_url", "reliability", "manual_collection", "note"],
        ["amount_value", "amount_min", "amount_max", "calorie_kcal",
         "price_min_krw", "price_max_krw"],
    ),
}


def validate(fname, header, int_cols):
    path = str(rpath(fname))
    viol = []
    with open(path, "r", encoding="utf-8-sig", newline="") as f:
        rows = list(csv.reader(f))
    if rows[0] != header:
        return ["HEADER MISMATCH\n  expected %s\n  got      %s" % (header, rows[0])], 0
    idx = {c: i for i, c in enumerate(header)}
    n = 0
    for ln, row in enumerate(rows[1:], start=2):
        n += 1
        if len(row) != len(header):
            viol.append("line %d: field count %d != %d" % (ln, len(row), len(header)))
            continue
        rec = dict(zip(header, row))
        if not DATE_RE.match(rec["collected_date"]):
            viol.append("line %d: collected_date='%s'" % (ln, rec["collected_date"]))
        if rec.get("reliability") not in REL_OK:
            viol.append("line %d: reliability='%s'" % (ln, rec.get("reliability")))
        if "data_type" in idx and rec["data_type"] not in DT_OK:
            viol.append("line %d: data_type='%s'" % (ln, rec["data_type"]))
        if rec.get("source_url", "").strip() == "" and rec.get("reliability") != "하":
            viol.append("line %d: source_url 빈값인데 reliability='%s' (하로 강등 필요)" % (ln, rec.get("reliability")))
        for c in int_cols:
            v = rec.get(c, "").strip()
            if v and not re.match(r"^\d+$", v):
                viol.append("line %d: %s='%s' 정수 아님" % (ln, c, v))
    return viol, n


def main():
    total_v = 0
    for fname, (header, int_cols) in SPECS.items():
        viol, n = validate(fname, header, int_cols)
        if viol:
            total_v += len(viol)
            print("FAIL %s: %d violation(s) / %d rows" % (fname, len(viol), n))
            for v in viol:
                print("  " + v)
        else:
            print("OK %s: %d rows valid" % (fname, n))
    return 1 if total_v else 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
