# -*- coding: utf-8 -*-
"""
이미지의 단색(흰/밝은) 배경을 검은 배경으로 바꾼다.

방식: 네 모서리에서 배경색을 추정 → 모서리에서 flood-fill 로 '배경에 연결된'
밝은 영역만 검정으로 채움. (피사체 내부의 흰 도형/하이라이트는 보존)
배경이 균일하지 않은 사진(야외 장면, 책상 위 종이 등)은 잘 안 바뀜 → 건너뜀 권장.

사용:
  python3 scripts/blacken_bg.py 이미지1.png 이미지2.jpg ...
  python3 scripts/blacken_bg.py --dir 폴더            # 폴더 내 모든 이미지
  옵션:
    --out DIR     결과 저장 폴더 (기본: assets/products)
    --inplace     원본 위치에 덮어쓰기
    --suffix S    파일명 접미사 (기본: 없음, --inplace 아니면 동일명으로 --out 에 저장)
    --tol N       배경 판정 허용오차 0~255 (기본 45)
    --bg R G B    배경으로 칠할 색 (기본 0 0 0 = 검정)
"""
import os
import sys
from PIL import Image, ImageDraw

DEFAULT_OUT = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "products")
EXTS = (".png", ".jpg", ".jpeg", ".webp")


def is_lightish(c):
    return (c[0] + c[1] + c[2]) / 3 > 110  # 평균 밝기 기준


def blacken(path, out_dir, inplace, suffix, tol, bg):
    img = Image.open(path).convert("RGBA")
    w, h = img.size
    corners = [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]
    px = img.load()
    corner_cols = [px[x, y][:3] for (x, y) in corners]
    light_corners = [c for c in corner_cols if is_lightish(c)]
    if not light_corners:
        # 이미 어두운 배경 → 변경 없음
        status = "skip(어두운 배경)"
        result = img
    else:
        result = img.copy()
        d = ImageDraw.Draw(result)
        bg_rgba = (bg[0], bg[1], bg[2], 255)
        for (x, y) in corners:
            seed = result.load()[x, y]
            if is_lightish(seed[:3]):
                ImageDraw.floodfill(result, (x, y), bg_rgba, thresh=tol)
        status = "ok"

    # JPG 등 알파 없는 포맷이면 검정 위에 합성
    name = os.path.basename(path)
    stem, ext = os.path.splitext(name)
    if suffix:
        name = stem + suffix + ".png"
    else:
        name = stem + ".png"
    if inplace:
        dst = os.path.join(os.path.dirname(path), name)
    else:
        os.makedirs(out_dir, exist_ok=True)
        dst = os.path.join(out_dir, name)
    result.save(dst)
    print("%-10s %s -> %s" % (status, path, dst))


def main(argv):
    args = argv[1:]
    out_dir, inplace, suffix, tol, bg, files, use_dir = DEFAULT_OUT, False, "", 45, (0, 0, 0), [], None
    i = 0
    while i < len(args):
        a = args[i]
        if a == "--out": out_dir = args[i + 1]; i += 2
        elif a == "--inplace": inplace = True; i += 1
        elif a == "--suffix": suffix = args[i + 1]; i += 2
        elif a == "--tol": tol = int(args[i + 1]); i += 2
        elif a == "--bg": bg = (int(args[i+1]), int(args[i+2]), int(args[i+3])); i += 4
        elif a == "--dir": use_dir = args[i + 1]; i += 2
        else: files.append(a); i += 1

    if use_dir:
        for f in sorted(os.listdir(use_dir)):
            if f.lower().endswith(EXTS):
                files.append(os.path.join(use_dir, f))
    if not files:
        print(__doc__); return 1
    for f in files:
        try:
            blacken(f, out_dir, inplace, suffix, tol, bg)
        except Exception as e:
            print("FAIL      %s : %s" % (f, e))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
