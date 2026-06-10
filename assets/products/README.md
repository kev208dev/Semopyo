# 상품 이미지 (assets/products)

상세/단일 화면의 `ProductImage` 위젯이 여기 이미지를 우선 표시한다.
없으면 자동으로 브랜드 로고 → 머리글자로 폴백한다.

## 사용법
1. 상품 사진(PNG/투명배경 권장)을 여기에 둔다. 예: `assets/products/ansungtangmyun.png`
2. 데이터 모델의 `image` 필드에 경로를 적는다.
   - 맵기:  SpiceItem(..., image: 'assets/products/ansungtangmyun.png')
   - 음식양: PortionItem(..., image: 'assets/products/bigmac.png')
   - URL도 가능: image: 'https://.../xxx.png' (자동 감지)
3. `flutter pub get` 후 재빌드.

## 주의 (상표/저작권)
- 제조사/유통사 상품 사진은 저작권이 있다. 자체 촬영 이미지나
  사용 허가된 소스를 권장. 핫링크(외부 URL 직접 참조)는 깨질 수 있고
  약관 위반 소지가 있으니 가급적 번들 또는 정식 라이선스 이미지 사용.
