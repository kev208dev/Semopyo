# -*- coding: utf-8 -*-
"""data/ 카테고리 하위폴더 경로 해석기.

data/ 는 카테고리 폴더로 정리되어 있다(food/, kr/, shoes/, pc_parts/ ...).
스크립트는 파일명만 알면 되고, 실제 경로는 여기서 카테고리를 붙여 해석한다.

- dpath(name): 쓰기용. 항상 카테고리 경로를 반환하고 상위 폴더를 생성한다.
- rpath(name): 읽기용. 카테고리 경로가 있으면 그걸, 없으면 평면 data/name 폴백.
- READ / WRITE: `DATA / "x.csv"` 형태를 그대로 쓰던 스크립트용 헬퍼 객체.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"

# 파일명 접두어 → 카테고리 폴더
_PREFIX_RULES = (
    ("food_", "food"),
    ("beverages", "beverage"),
    ("alcohol", "beverage"),
    ("apparel_", "apparel"),
    ("shoes_", "shoes"),
    ("spiciness", "spiciness"),
    ("pizza_", "pizza"),
    ("kr_", "kr"),
    ("baby_", "baby"),
    ("beauty_", "beauty"),
    ("pet_", "pet"),
    ("car_", "car"),
    ("science_", "science"),
    ("tech_", "tech"),
)

_PC_PARTS = {"cpu.csv", "gpu.csv", "ram.csv", "ssd.csv", "hdd.csv", "wifi.csv"}


def category_of(name: str) -> str:
    """파일명(경로 아님)으로 카테고리 폴더명을 반환."""
    base = Path(name).name
    for prefix, cat in _PREFIX_RULES:
        if base.startswith(prefix):
            return cat
    if base in _PC_PARTS:
        return "pc_parts"
    return "misc"


def dpath(name: str) -> Path:
    """쓰기용 경로. 카테고리 폴더를 생성하고 경로 반환."""
    base = Path(name).name
    p = DATA / category_of(base) / base
    p.parent.mkdir(parents=True, exist_ok=True)
    return p


def rpath(name: str) -> Path:
    """읽기용 경로. 카테고리 경로 우선, 없으면 평면 폴백."""
    base = Path(name).name
    p = DATA / category_of(base) / base
    if p.exists():
        return p
    flat = DATA / base
    return flat if flat.exists() else p


class _DataDir:
    """`DATA / "x.csv"` 관용구 유지용. mode에 따라 읽기/쓰기 경로 해석."""

    def __init__(self, mode: str = "read"):
        self._mode = mode

    def __truediv__(self, name: str) -> Path:
        return rpath(name) if self._mode == "read" else dpath(name)


READ = _DataDir("read")
WRITE = _DataDir("write")
