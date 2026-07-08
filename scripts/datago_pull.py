#!/usr/bin/env python3
"""data.go.kr 표준 OpenAPI 페이지네이션 수집기 → CSV.

식약처(fsk_pull.py)와 달리 data.go.kr 공통 규격(serviceKey + pageNo/numOfRows,
response/body/items/item, totalCount)을 쓰는 서비스용.

사용:
    python3 scripts/datago_pull.py <DATASET> <OUT_CSV> <SERVICE_KEY>
    python3 scripts/datago_pull.py car_fuel_label data/car_fuel_label.csv "<KEY>"

DATASET 목록은 아래 DATASETS dict 참고. SERVICE_KEY 는 data.go.kr "일반 인증키".
보통 Encoding 키(%2B 등이 포함된 URL인코딩 문자열)를 그대로 넣으면 된다.
키가 안 먹으면 Decoding 키 / Encoding 키를 번갈아 시도해볼 것.
"""
import sys, os, time, json, csv, ssl, urllib.request, urllib.parse
import xml.etree.ElementTree as ET

# data.go.kr SSL 체인이 OS에 따라 self-signed 로 보이는 경우 존재. 개발용 폴백.
_SSL_CTX = ssl.create_default_context()
_SSL_CTX.check_hostname = False
_SSL_CTX.verify_mode = ssl.CERT_NONE

# 데이터셋별 엔드포인트. (base_url, 추가 고정 파라미터)
DATASETS = {
    # 한국에너지공단 자동차 에너지효율등급/표시연비 (모델·제조사·연료·복합/도심/고속연비·등급)
    # End Point 확인됨: https://apis.data.go.kr/B553530/CAR  (operation: CAR_01_LIST)
    "car_fuel_label": (
        "https://apis.data.go.kr/B553530/CAR/CAR_01_LIST",
        {"type": "json"},
    ),
    # 식약처 화장품 원료성분정보 (성분 표준명/영문명/CAS/유래/정의)
    "cosmetic_ingredient": (
        "https://apis.data.go.kr/1471000/CsmtcsIngdInfoService01/getCsmtcsIngdInfoList01",
        {"type": "json"},
    ),
    # 식약처 화장품 제조업체/품목 정보
    "cosmetic_product": (
        "https://apis.data.go.kr/1471000/CsmtcsMfcrtrInfoService01/getCsmtcsMfcrtrInfoList01",
        {"type": "json"},
    ),
    # 한국에너지공단 고효율 에너지기자재(가전) 제품 정보
    "appliance_efficiency": (
        "https://apis.data.go.kr/B553530/CRTIF",
        {"type": "json"},
    ),
}

NUM = 100  # 1회 요청 행수


def fetch(base, params):
    qs = urllib.parse.urlencode(params, safe="%+=")
    url = f"{base}?{qs}"
    for _ in range(5):
        try:
            with urllib.request.urlopen(url, timeout=40, context=_SSL_CTX) as r:
                raw = r.read().decode("utf-8")
            # JSON 우선, 실패하면 data.go.kr XML 응답 파싱.
            try:
                return json.loads(raw)
            except json.JSONDecodeError:
                xml = _parse_xml(raw)
                if xml is not None:
                    return xml
                return {"_raw": raw}
        except Exception as e:
            last = str(e)
            time.sleep(1.5)
    print("요청 실패:", last)
    return None


def _xml_to_dict(node):
    """ET 노드 → 중첩 dict. 같은 태그 다회 출현 시 list."""
    children = list(node)
    if not children:
        return (node.text or "").strip()
    out = {}
    for ch in children:
        v = _xml_to_dict(ch)
        if ch.tag in out:
            cur = out[ch.tag]
            if isinstance(cur, list):
                cur.append(v)
            else:
                out[ch.tag] = [cur, v]
        else:
            out[ch.tag] = v
    return out


def _parse_xml(raw):
    """data.go.kr 표준 XML → dict 변환. response/body 구조 그대로 유지."""
    try:
        root = ET.fromstring(raw)
    except ET.ParseError:
        return None
    return {root.tag: _xml_to_dict(root)}


def extract(body):
    """response/body/items/item 또는 평탄화된 변형을 모두 처리."""
    if not isinstance(body, dict):
        return [], 0
    resp = body.get("response", body)
    b = resp.get("body", resp) if isinstance(resp, dict) else {}
    total = int(b.get("totalCount", b.get("total_count", 0)) or 0)
    items = b.get("items", b.get("item", []))
    if isinstance(items, dict):
        items = items.get("item", [])
    if isinstance(items, dict):
        items = [items]
    return (items or []), total


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        sys.exit(1)
    ds, out, key = sys.argv[1], sys.argv[2], sys.argv[3]
    if ds not in DATASETS:
        print("알 수 없는 DATASET. 가능:", ", ".join(DATASETS)); sys.exit(1)
    base, fixed = DATASETS[ds]

    def call(page):
        p = {"serviceKey": key, "pageNo": page, "numOfRows": NUM}
        p.update(fixed)
        return fetch(base, p)

    first = call(1)
    if first is None:
        sys.exit(1)
    if "_raw" in first:
        print("JSON 아님(키/등록 오류 가능). 응답 앞부분:\n", first["_raw"][:400]); sys.exit(1)
    rows, total = extract(first)
    if total == 0 and not rows:
        print("데이터 0건. 응답:", json.dumps(first, ensure_ascii=False)[:400]); sys.exit(1)
    print(f"{ds}: 총 {total:,}건 수집 시작")

    all_rows = list(rows)
    pages = (total + NUM - 1) // NUM
    for page in range(2, pages + 1):
        d = call(page)
        r, _ = extract(d) if d else ([], 0)
        all_rows.extend(r)
        if page % 20 == 0:
            print(f"  {len(all_rows):,}/{total:,}")
        time.sleep(0.1)

    if not all_rows:
        print("수집 행 없음"); sys.exit(1)
    keys = sorted({k for r in all_rows for k in r.keys()})
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    with open(out, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=keys)
        w.writeheader(); w.writerows(all_rows)
    print(f"완료: {len(all_rows):,}건 → {out}")


if __name__ == "__main__":
    main()
