# -*- coding: utf-8 -*-
"""
data/*.csv 의 brand_ko / brand_en -> brand_domain 을 모아
lib/brand_domains.dart (Dart const Map) 을 생성한다.

- 한글·영문 브랜드명 모두 키로 넣어 페이지 데이터 모델의 표기 차이를 흡수.
- 데이터 모델이 CSV와 다르게 쓰는 표기는 ALIASES 로 보강.
- 도메인을 지어내지 않는다: 빈 도메인 브랜드는 맵에 없음 → 위젯이 폴백 처리.

사용:  python3 scripts/gen_brand_domains_dart.py
"""
import csv
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _data_paths import rpath  # noqa: E402  (data/ 하위폴더 경로 해석)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "lib", "brand_domains.dart")

CSVS = [
    "shoes_sizing.csv", "beverages.csv", "apparel_official.csv",
    "apparel_perception.csv", "spiciness.csv", "food_portions.csv",
]

# 페이지 데이터 모델이 CSV와 다르게 쓰는 표기 → 도메인
ALIASES = {
    "식약처 기준": "mfds.go.kr",
    "윌슨(국가표준)": "wilson.com",
}


def main():
    m = {}
    for f in CSVS:
        with open(rpath(f), encoding="utf-8-sig") as fh:
            for r in csv.DictReader(fh):
                d = (r.get("brand_domain") or "").strip()
                if not d:
                    continue
                for key in ((r.get("brand_ko") or "").strip(),
                            (r.get("brand_en") or "").strip()):
                    if key and key not in m:
                        m[key] = d
    for k, v in ALIASES.items():
        m.setdefault(k, v)

    lines = [
        "// 자동 생성: scripts/gen_brand_domains_dart.py",
        "// data/*.csv 의 brand_ko/brand_en -> brand_domain (+ALIASES).",
        "// 로고 렌더링용. 빈 도메인 브랜드는 여기 없음(BrandLogo 가 폴백 처리).",
        "// 갱신: CSV 수정 후 이 스크립트 재실행.",
        "",
        "const Map<String, String> brandDomains = {",
    ]
    for k in sorted(m):
        kk = k.replace("\\", "\\\\").replace("'", "\\'")
        lines.append("  '%s': '%s'," % (kk, m[k]))
    lines.append("};")
    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")
    print("wrote %s (%d keys)" % (OUT, len(m)))


if __name__ == "__main__":
    main()
