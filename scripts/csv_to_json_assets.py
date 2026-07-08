#!/usr/bin/env python3
"""CSV → assets/data/*.json 변환.

도메인별:
- pizza_sizes_global.csv  → assets/data/pizza_global.json (대체)
- pizza_frozen.csv        → assets/data/pizza_frozen.json
- beverages_expanded.csv  → assets/data/beverages_global.json
- spiciness_expanded.csv + spiciness_wave2.csv → assets/data/spiciness_global.json
- food_portions_expanded.csv → assets/data/portions_global.json
- shoes_conversion.csv    → assets/data/shoes_conversion.json
- shoes_brand_fit.csv     → assets/data/shoes_fit.json
- apparel_expanded.csv    → assets/data/apparel_global.json
- kr_franchise_spicy.csv     → assets/data/kr_franchise_spicy.json
- kr_franchise_portions.csv  → assets/data/kr_franchise_portions.json
- kr_convenience_food.csv    → assets/data/kr_convenience_food.json
- kr_cafe_prices.csv         → assets/data/kr_cafe_prices.json
- kr_pizza_prices.csv        → assets/data/kr_pizza_prices.json
- kr_ramen_snack_prices.csv  → assets/data/kr_ramen_snack_prices.json
"""
from __future__ import annotations
import csv
import json
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _data_paths import READ as DATA  # noqa: E402  (data/ 하위폴더 경로 해석)

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "data"
OUT.mkdir(parents=True, exist_ok=True)

USD_KRW = 1330


def _f(v):
    if v in (None, "", "null"):
        return None
    try:
        return float(v)
    except ValueError:
        return None


def _i(v):
    f = _f(v)
    return int(f) if f is not None else None


def _read(path: Path):
    text = path.read_text(encoding="utf-8")
    if text.startswith("﻿"):
        text = text[1:]
    reader = csv.DictReader(text.splitlines())
    return [dict(row) for row in reader]


# ---------- pizza ----------
def pizza_global():
    rows = _read(DATA / "pizza_sizes_global.csv")
    out = []
    for r in rows:
        dia = _f(r.get("diameter_cm"))
        if dia is None:
            inch = _f(r.get("diameter_inch"))
            dia = round(inch * 2.54, 1) if inch else None
        if dia is None:
            continue
        price = _i(r.get("price"))
        curr = (r.get("currency") or "").upper()
        if price and curr == "USD":
            price = int(price * USD_KRW)
        slices = _i(r.get("slices")) or 8
        kcal = _i(r.get("calories_per_slice"))
        if kcal is None:
            kcal = int(round(dia * dia * 0.18))
        if price is None:
            price = int(round(dia * dia * 30))
        out.append({
            "brand": (r.get("brand") or "").strip(),
            "brand_en": (r.get("brand_en") or "").strip(),
            "country": (r.get("country") or "").strip(),
            "size_label": (r.get("size_label") or "").strip(),
            "diameter_cm": dia,
            "slices": slices,
            "price": price,
            "calories_per_slice": kcal,
            "source": (r.get("source") or "").strip(),
        })
    (OUT / "pizza_global.json").write_text(
        json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    return len(out)


def pizza_frozen():
    rows = _read(DATA / "pizza_frozen.csv")
    out = []
    for r in rows:
        dia = _f(r.get("diameter_cm"))
        weight = _f(r.get("weight_g"))
        out.append({
            "brand": (r.get("brand") or "").strip(),
            "country": (r.get("country") or "").strip(),
            "product": (r.get("product") or "").strip(),
            "diameter_cm": dia,
            "weight_g": weight,
            "source": (r.get("source") or "").strip(),
        })
    (OUT / "pizza_frozen.json").write_text(
        json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    return len(out)


# ---------- beverages ----------
def beverages():
    rows = _read(DATA / "beverages_expanded.csv")
    out = []
    for r in rows:
        ml = _i(r.get("volume_ml"))
        if ml is None:
            continue
        temp_raw = (r.get("hot_or_iced") or "both").lower()
        temp = {"hot": "핫", "iced": "아이스", "ice": "아이스",
                "both": "공용", "공용": "공용"}.get(temp_raw, "공용")
        out.append({
            "brand": (r.get("brand") or "").strip(),
            "country": (r.get("country") or "").strip(),
            "size_label": (r.get("size_label") or "").strip(),
            "volume_ml": ml,
            "temp": temp,
            "source": (r.get("source") or "").strip(),
        })
    (OUT / "beverages_global.json").write_text(
        json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    return len(out)


# ---------- spiciness ----------
def spiciness():
    rows = _read(DATA / "spiciness_expanded.csv") + _read(DATA / "spiciness_wave2.csv")
    out = []
    for r in rows:
        smin = _i(r.get("scoville_min"))
        smax = _i(r.get("scoville_max"))
        if smin is None and smax is None:
            continue
        shu = smax if smax is not None else smin
        if shu is None or shu <= 0:
            continue
        out.append({
            "item": (r.get("item") or "").strip(),
            "category": (r.get("category") or "").strip(),
            "brand": (r.get("brand") or "").strip(),
            "shu_min": smin or shu,
            "shu_max": smax or shu,
            "shu": shu,
            "source": (r.get("source") or "").strip(),
        })
    (OUT / "spiciness_global.json").write_text(
        json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    return len(out)


# ---------- portions ----------
def portions():
    rows = _read(DATA / "food_portions_expanded.csv")
    out = []
    for r in rows:
        kcal = _i(r.get("kcal"))
        amt = _f(r.get("amount_value"))
        if kcal is None or amt is None:
            continue
        out.append({
            "food": (r.get("food") or "").strip(),
            "category": (r.get("category") or "").strip(),
            "portion_type": (r.get("portion_type") or "").strip(),
            "amount": amt,
            "amount_unit": (r.get("amount_unit") or "g").strip(),
            "amount_min": _f(r.get("amount_min")),
            "amount_max": _f(r.get("amount_max")),
            "kcal": kcal,
            "source": (r.get("source") or "").strip(),
        })
    (OUT / "portions_global.json").write_text(
        json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    return len(out)


# ---------- shoes ----------
def shoes_conv():
    rows = _read(DATA / "shoes_conversion.csv")
    out = []
    for r in rows:
        foot = _i(r.get("foot_mm"))
        kr = _i(r.get("kr_mm"))
        if foot is None or kr is None:
            continue
        out.append({
            "gender": (r.get("gender") or "").strip(),
            "foot_mm": foot,
            "kr_mm": kr,
            "us": _f(r.get("us")),
            "uk": _f(r.get("uk")),
            "eu": _f(r.get("eu")),
            "source": (r.get("source") or "").strip(),
        })
    (OUT / "shoes_conversion.json").write_text(
        json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    return len(out)


def shoes_fit():
    rows = _read(DATA / "shoes_brand_fit.csv")
    out = []
    for r in rows:
        adj = (r.get("recommend_adjust_mm") or "").strip().replace("+", "")
        try:
            adj_mm = int(adj) if adj else 0
        except ValueError:
            adj_mm = 0
        out.append({
            "brand": (r.get("brand") or "").strip(),
            "fit_tendency": (r.get("fit_tendency") or "").strip(),
            "adjust_mm": adj_mm,
            "note": (r.get("note") or "").strip(),
            "source": (r.get("source") or "").strip(),
        })
    (OUT / "shoes_fit.json").write_text(
        json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    return len(out)


# ---------- apparel ----------
def apparel():
    rows = _read(DATA / "apparel_expanded.csv")
    out = []
    for r in rows:
        out.append({
            "brand": (r.get("brand") or "").strip(),
            "garment": (r.get("garment") or "").strip(),
            "size_label": (r.get("size_label") or "").strip(),
            "shoulder_cm": _f(r.get("shoulder_cm")),
            "chest_half_cm": _f(r.get("chest_half_cm")),
            "length_cm": _f(r.get("length_cm")),
            "sleeve_cm": _f(r.get("sleeve_cm")),
            "source": (r.get("source") or "").strip(),
        })
    (OUT / "apparel_global.json").write_text(
        json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    return len(out)


# ---------- 한국 프랜차이즈 / 가격 (컬럼 그대로 패스스루 + 숫자 coercion) ----------
_NUM_FIELDS = {"price_krw", "portion_g", "weight_g", "amount_value", "kcal",
               "scoville_shu", "spice_level_rank", "volume_ml", "abv_percent",
               "waist_inch", "waist_circumference_cm", "inseam_cm", "foot_mm",
               "eu_kids"}


def _passthrough(csv_name: str, json_name: str) -> int:
    """단순 CSV → JSON. 숫자 컬럼만 형변환하고 나머지는 문자열 유지."""
    rows = _read(DATA / csv_name)
    out = []
    for r in rows:
        item = {}
        for k, v in r.items():
            key = (k or "").strip()
            val = (v or "").strip()
            if key in _NUM_FIELDS:
                item[key] = _i(val)
            else:
                item[key] = val
        out.append(item)
    (OUT / json_name).write_text(
        json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    return len(out)


if __name__ == "__main__":
    stats = {
        "pizza_global": pizza_global(),
        "pizza_frozen": pizza_frozen(),
        "beverages": beverages(),
        "spiciness": spiciness(),
        "portions": portions(),
        "shoes_conv": shoes_conv(),
        "shoes_fit": shoes_fit(),
        "apparel": apparel(),
        "kr_franchise_spicy": _passthrough(
            "kr_franchise_spicy.csv", "kr_franchise_spicy.json"),
        "kr_franchise_portions": _passthrough(
            "kr_franchise_portions.csv", "kr_franchise_portions.json"),
        "kr_convenience_food": _passthrough(
            "kr_convenience_food.csv", "kr_convenience_food.json"),
        "kr_cafe_prices": _passthrough(
            "kr_cafe_prices.csv", "kr_cafe_prices.json"),
        "kr_pizza_prices": _passthrough(
            "kr_pizza_prices.csv", "kr_pizza_prices.json"),
        "kr_ramen_snack_prices": _passthrough(
            "kr_ramen_snack_prices.csv", "kr_ramen_snack_prices.json"),
        "kr_alcohol": _passthrough("kr_alcohol.csv", "kr_alcohol.json"),
        "kr_drinks": _passthrough("kr_drinks.csv", "kr_drinks.json"),
        "kr_snacks": _passthrough("kr_snacks.csv", "kr_snacks.json"),
        "apparel_bottoms": _passthrough(
            "apparel_bottoms.csv", "apparel_bottoms.json"),
        "shoes_brand_fit2": _passthrough(
            "shoes_brand_fit2.csv", "shoes_brand_fit2.json"),
        "shoes_kids": _passthrough("shoes_kids.csv", "shoes_kids.json"),
    }
    for k, v in stats.items():
        print(f"{k}: {v}")
