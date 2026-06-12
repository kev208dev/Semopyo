#!/usr/bin/env python3
"""식품안전나라 OpenAPI 전건 수집기 (계정 인증키 1개로 모든 서비스 공용).
사용:  fsk_pull.py <SERVICE_ID> <OUT_CSV> [KEY]
예시:  fsk_pull.py I2570 barcode_i2570.csv  (유통바코드)
       fsk_pull.py I0750 prod_i0750.csv     (품목제조보고)
       fsk_pull.py I2790 nutri_i2790.csv    (식품영양성분)
KEY 인자를 생략하면 환경변수 FSK_KEY 사용.
"""
import sys, os, time, json, csv, urllib.request

ROWS = 1000  # 식품안전나라 1회 최대 1000행

def fetch(key, svc, start, end):
    url = f"http://openapi.foodsafetykorea.go.kr/api/{key}/{svc}/json/{start}/{end}"
    for a in range(5):
        try:
            with urllib.request.urlopen(url, timeout=40) as r:
                return json.loads(r.read().decode("utf-8"))
        except Exception:
            time.sleep(1.5)
    return None

def main():
    svc = sys.argv[1]
    out = sys.argv[2]
    key = sys.argv[3] if len(sys.argv) > 3 else os.environ.get("FSK_KEY", "")
    if not key:
        print("KEY 없음: 인자 또는 FSK_KEY 환경변수 필요"); sys.exit(1)

    first = fetch(key, svc, 1, 1)
    if first is None or svc not in first:
        print("응답 오류:", json.dumps(first, ensure_ascii=False)[:300]); sys.exit(1)
    block = first[svc]
    result = block.get("RESULT", {})
    if isinstance(result, dict) and result.get("CODE", "").startswith("ERROR"):
        print("API 에러:", result); sys.exit(1)
    total = int(block.get("total_count", 0))
    print(f"{svc}: 총 {total:,}건 수집 시작")

    rows = []
    start = 1
    while start <= total:
        end = min(start + ROWS - 1, total)
        d = fetch(key, svc, start, end)
        if d and svc in d and "row" in d[svc]:
            rows.extend(d[svc]["row"])
        else:
            print(f"  {start}-{end} 비정상, 건너뜀")
        if (start - 1) % 10000 == 0:
            print(f"  {start:,}/{total:,}")
        start += ROWS
        time.sleep(0.1)

    if not rows:
        print("수집된 행 없음"); sys.exit(1)
    keys = sorted({k for r in rows for k in r.keys()})
    with open(out, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=keys)
        w.writeheader(); w.writerows(rows)
    print(f"완료: {len(rows):,}건 → {out}")

if __name__ == "__main__":
    main()
