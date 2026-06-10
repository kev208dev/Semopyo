import 'package:flutter/material.dart';
import 'brand_domains.dart';

/// 로고 서비스 설정.
///
/// - logo.dev publishable key(`pk_...`)는 클라이언트(앱)에 노출돼도 안전하도록 설계됨.
/// - Brandfetch 키는 가급적 노출을 줄이는 게 좋음(서버 프록시 권장). 지금은 앱에 둠.
/// 키 교체 시 이 파일만 수정하면 됨.
///
/// ⚠️ 상표권: 로고는 "해당 브랜드의 실제 제품을 식별"하는 용도로만 사용.
///    제휴/보증을 암시하지 말 것. 상용 배포 전 각 서비스 약관 확인.
class LogoConfig {
  static const String logoDevKey =
      'pk_bX8koglFS9CUcz78XJC3kw';
  static const String brandfetchKey =
      '9EJOex9MVJJYunb4vbMBXxQhZXOQ-o43hH6CwAJgzaMcz-gCA6SOEfMPQo0szKyNUSrU2YzPBTDpVldlJvq5OA';

  /// 워드마크/로고 (브랜드 고유 글씨체). 기본 렌더러.
  /// [theme] 'dark'면 어두운 배경용(밝은) 로고 변형을 시도.
  static String logoUrl(String domain,
      {int size = 128, String format = 'png', String? theme}) {
    final t = (theme != null) ? '&theme=$theme' : '';
    return 'https://img.logo.dev/$domain'
        '?token=$logoDevKey&size=$size&format=$format&retina=true$t';
  }

  /// Brandfetch CDN (SVG/고품질). ⚠️ CDN 은 client_id 를 받음.
  /// 제공된 값이 API 키라면 동작하지 않을 수 있어 logo.dev 를 기본으로 둠.
  static String brandfetchUrl(String domain, {int size = 200}) =>
      'https://cdn.brandfetch.io/$domain/w/$size/h/$size?c=$brandfetchKey';
}

/// 브랜드 로고 위젯.
/// - [brandName] 또는 [domain] 중 하나로 로고를 찾음(brandName → brandDomains 조회).
/// - 도메인이 없거나 로딩 실패 시 [fallback](이모지/머리글자)로 폴백.
class BrandLogo extends StatelessWidget {
  final String? brandName;
  final String? domain;
  final String fallback;
  final double size;
  final Color bg;
  final IconData? fallbackIcon;

  const BrandLogo({
    super.key,
    this.brandName,
    this.domain,
    this.fallback = '',
    this.size = 40,
    this.bg = Colors.white,
    this.fallbackIcon,
  });

  String? get _domain {
    if (domain != null && domain!.isNotEmpty) return domain;
    if (brandName != null) return brandDomains[brandName!];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final d = _domain;
    if (d == null || d.isEmpty) return _fallbackBox();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        color: bg, // 투명 로고가 어두운 배경에서 안 보이는 것 방지
        padding: EdgeInsets.all(size * 0.12),
        child: Image.network(
          LogoConfig.logoUrl(d, size: (size * 2).round()),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallbackInner(),
          loadingBuilder: (ctx, child, progress) => progress == null
              ? child
              : const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _fallbackBox() => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: _fallbackInner(),
      );

  Widget _fallbackInner() {
    // 1순위: 지정 아이콘 → 2순위: 명시 fallback 텍스트 → 3순위: 중립 이미지 아이콘.
    if (fallbackIcon != null) {
      return Center(
          child: Icon(fallbackIcon, size: size * 0.55, color: Colors.white54));
    }
    if (fallback.isNotEmpty) {
      return Center(
          child: Text(fallback, style: TextStyle(fontSize: size * 0.45)));
    }
    return Center(
        child: Icon(Icons.image_outlined,
            size: size * 0.5, color: Colors.white38));
  }
}

/// 브랜드 워드마크 (브랜드명을 그 회사 고유 로고 글씨체로 표시).
/// 리스트/비교 카드의 "이모지+텍스트 이름"을 대체하는 용도.
/// 도메인 없거나 로딩 실패 시 깔끔한 텍스트 이름으로 폴백(이모지 없음).
class BrandWordmark extends StatelessWidget {
  final String brandName;
  final double height;
  final Color textColor;
  final String? theme; // 'dark' 이면 어두운 배경용 로고 변형 시도

  const BrandWordmark({
    super.key,
    required this.brandName,
    this.height = 26,
    this.textColor = Colors.white,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final d = brandDomains[brandName];
    final fallbackText = Text(
      brandName,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: textColor,
          fontSize: height * 0.6,
          fontWeight: FontWeight.w900),
    );
    // 도메인 없으면 한글 이름 단일 텍스트로 폴백(중복 방지).
    if (d == null || d.isEmpty) return fallbackText;
    final nameLabel = Text(
      brandName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: textColor.withAlpha(220),
        fontSize: (height * 0.42).clamp(10, 14),
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    );
    final logo = Image.network(
      LogoConfig.logoUrl(d, size: (height * 4).round(), theme: theme),
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => fallbackText,
      loadingBuilder: (ctx, c, p) =>
          p == null ? c : SizedBox(height: height, child: fallbackText),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logo,
        const SizedBox(height: 3),
        nameLabel,
      ],
    );
  }
}

/// 상품 이미지 위젯 (상세/단일 화면용).
/// 우선순위: [imageAsset] → [imageUrl] → 브랜드 로고([brandName]) → 머리글자.
/// 이모지는 쓰지 않음.
class ProductImage extends StatelessWidget {
  final String? imageAsset; // 번들 에셋 경로 (assets/products/xxx.png)
  final String? imageUrl;   // 원격 상품 이미지 URL
  final String? brandName;  // 폴백 로고용
  final double size;
  final double radius;
  final IconData? fallbackIcon; // 이미지·로고 모두 실패 시 표시할 카테고리 아이콘

  const ProductImage({
    super.key,
    this.imageAsset,
    this.imageUrl,
    this.brandName,
    this.size = 72,
    this.radius = 12,
    this.fallbackIcon,
  });

  bool get _hasAsset => imageAsset != null && imageAsset!.isNotEmpty;
  bool get _hasUrl => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    Widget logoFallback() => BrandLogo(
        brandName: brandName,
        size: size,
        bg: Colors.transparent,
        fallbackIcon: fallbackIcon);

    Widget child;
    if (_hasAsset) {
      child = Image.asset(imageAsset!,
          fit: BoxFit.contain, errorBuilder: (_, __, ___) => logoFallback());
    } else if (_hasUrl) {
      child = Image.network(imageUrl!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => logoFallback(),
          loadingBuilder: (ctx, c, p) => p == null
              ? c
              : const Center(
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))));
    } else {
      return logoFallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: size, height: size, child: child),
    );
  }
}
