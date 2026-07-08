# -*- coding: utf-8 -*-
"""
shoes_sizing.csv 스키마/enum/제약 검증기.

사용:  python3 scripts/validate.py [data/shoes_sizing.csv]
위반이 있으면 라인번호(CSV 행번호, 헤더=1)와 사유를 출력하고 exit code 1.
위반 없으면 "OK: N rows valid" 출력하고 exit code 0.
"""
import csv
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _data_paths import rpath  # noqa: E402  (data/ 하위폴더 경로 해석)

EXPECTED_HEADER = [
    "brand_ko", "brand_en", "origin", "model_line", "data_type",
    "label_size_mm", "designed_foot_length_mm", "insole_length_mm",
    "fit_verdict", "adjustment_reco", "toebox_width", "stiffness",
    "price_min_krw", "price_max_krw", "brand_domain", "collected_date", "source_url",
    "reliability", "manual_collection", "note",
]

ENUMS = {
    "origin": {"국산", "글로벌"},
    "data_type": {"official_spec", "perception"},
    "fit_verdict": {"작게", "정사이즈", "크게", ""},
    "toebox_width": {"좁음", "표준", "넓음", ""},
    "stiffness": {"부드러움", "보통", "짱짱함", ""},
    "reliability": {"상", "중", "하"},
    "manual_collection": {"TRUE", "FALSE"},
}

INT_FIELDS = ["label_size_mm", "designed_foot_length_mm", "insole_length_mm",
              "price_min_krw", "price_max_krw"]

DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


def validate(path):
    violations = []  # (line_no, reason)

    with open(path, "r", encoding="utf-8-sig", newline="") as f:
        reader = csv.reader(f)
        rows = list(reader)

    if not rows:
        print("EMPTY FILE: %s" % path)
        return 1

    header = rows[0]
    if header != EXPECTED_HEADER:
        print("HEADER MISMATCH")
        print("  expected: %s" % EXPECTED_HEADER)
        print("  got:      %s" % header)
        return 1

    n_data = 0
    for i, row in enumerate(rows[1:], start=2):  # line 2 = first data row
        n_data += 1
        if len(row) != len(EXPECTED_HEADER):
            violations.append((i, "field count %d != %d" % (len(row), len(EXPECTED_HEADER))))
            continue
        rec = dict(zip(EXPECTED_HEADER, row))

        # 필수 비어있으면 안 되는 컬럼
        for col in ("brand_ko", "brand_en", "origin", "model_line", "data_type",
                    "collected_date", "reliability", "manual_collection"):
            if rec[col].strip() == "":
                violations.append((i, "%s is empty (required)" % col))

        # enum 검사
        for col, allowed in ENUMS.items():
            if rec[col] not in allowed:
                violations.append((i, "%s='%s' not in %s" % (col, rec[col], sorted(allowed))))

        # fit_verdict 은 perception 일 때만 채운다
        if rec["data_type"] == "official_spec" and rec["fit_verdict"] != "":
            violations.append((i, "fit_verdict='%s' set on official_spec row (perception 전용)" % rec["fit_verdict"]))

        # 정수 필드
        ints = {}
        for col in INT_FIELDS:
            v = rec[col].strip()
            if v == "":
                ints[col] = None
                continue
            if not re.match(r"^\d+$", v):
                violations.append((i, "%s='%s' is not a non-negative integer" % (col, v)))
                ints[col] = None
            else:
                ints[col] = int(v)

        # price_min <= price_max, 그리고 둘 다 있거나 둘 다 없거나
        pmin, pmax = ints.get("price_min_krw"), ints.get("price_max_krw")
        if (pmin is None) != (pmax is None):
            violations.append((i, "price_min/price_max 중 하나만 채워짐 (둘 다 또는 둘 다 비움)"))
        elif pmin is not None and pmax is not None and pmin > pmax:
            violations.append((i, "price_min(%d) > price_max(%d)" % (pmin, pmax)))

        # source_url 비어있으면 reliability 는 '하' 여야 함 (강등 규칙)
        if rec["source_url"].strip() == "" and rec["reliability"] != "하":
            violations.append((i, "source_url 비었는데 reliability='%s' (규칙상 '하'로 강등 필요)" % rec["reliability"]))

        # 날짜 형식
        if not DATE_RE.match(rec["collected_date"]):
            violations.append((i, "collected_date='%s' not YYYY-MM-DD" % rec["collected_date"]))

    if violations:
        print("FAIL: %d violation(s) in %d data rows" % (len(violations), n_data))
        for line_no, reason in violations:
            print("  line %d: %s" % (line_no, reason))
        return 1

    print("OK: %d rows valid" % n_data)
    return 0


if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else str(rpath("shoes_sizing.csv"))
    sys.exit(validate(target))
