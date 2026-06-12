import 'package:flutter/material.dart';

/// 세모표 공통 디자인 시스템.
/// 색·타이포·간격·라운드 토큰을 한곳에서 관리한다.
class AppColors {
  AppColors._();

  // 배경 (위에서 아래로 살짝 밝아지는 그라데이션)
  static const bgTop = Color(0xFF101019);
  static const bgBottom = Color(0xFF070709);

  // 표면 (카드/배너)
  static const surface = Color(0xFF16161F);
  static const surfaceHi = Color(0xFF1E1E2A);
  static const border = Color(0x14FFFFFF); // white 8%
  static const borderHi = Color(0x26FFFFFF); // white 15%

  // 텍스트
  static const textPrimary = Color(0xFFF4F4F7);
  static const textSecondary = Color(0xFF9A9AA8);
  static const textTertiary = Color(0xFF63636F);

  // 브랜드 (스캔 CTA)
  static const brandA = Color(0xFF7C5CFF);
  static const brandB = Color(0xFF3B82F6);

  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );
}

class AppRadius {
  AppRadius._();
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 22.0;
  static const xl = 28.0;
}

class AppSpace {
  AppSpace._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;
}

class AppText {
  AppText._();

  static const display = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
    height: 1.0,
  );
  static const h1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
  );
  static const h2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
  static const body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );
  static const caption = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
}

/// 카테고리 색 세트 — 그라데이션 두 색으로 카드 채움 + 글로우.
class CategoryPalette {
  final List<Color> gradient;
  const CategoryPalette(this.gradient);

  /// 카드 하단에 깔리는 글로우 색 (첫 색의 은은한 번짐).
  Color glow([double opacity = 0.45]) =>
      gradient.first.withValues(alpha: opacity);
}
