import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'pizza_page.dart';
import 'shoes_page.dart';
import 'beverages_page.dart';
import 'apparel_page.dart';
import 'spiciness_page.dart';
import 'portions_page.dart';
import 'pc_builder_page.dart';
import 'barcode_scan_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semopyo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgBottom,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.brandA,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class _Tile {
  final String label;
  final String subtitle;
  final String emoji;
  final List<Color> gradient;
  final Widget Function() build;
  const _Tile({
    required this.label,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.build,
  });

  CategoryPalette get palette => CategoryPalette(gradient);
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = <_Tile>[
      _Tile(
        label: '피자',
        subtitle: '한 조각이 얼마나 클까',
        emoji: '🍕',
        gradient: const [Color(0xFFFF8A4C), Color(0xFFE0381F)],
        build: () => const PizzaPage(),
      ),
      _Tile(
        label: '신발',
        subtitle: '내 발에 맞는 핏 찾기',
        emoji: '👟',
        gradient: const [Color(0xFF5C95FF), Color(0xFF2C46D6)],
        build: () => const ShoesPage(),
      ),
      _Tile(
        label: '음료',
        subtitle: '카페별 사이즈 환산',
        emoji: '🥤',
        gradient: const [Color(0xFFC98A53), Color(0xFF7A4A21)],
        build: () => const BeveragesPage(),
      ),
      _Tile(
        label: '옷',
        subtitle: '브랜드별 사이즈 환산',
        emoji: '👗',
        gradient: const [Color(0xFFFF7FB0), Color(0xFF9A2F77)],
        build: () => const ApparelPage(),
      ),
      _Tile(
        label: '맵기',
        subtitle: '스코빌로 매움 탐험',
        emoji: '🌶️',
        gradient: const [Color(0xFFF24A4A), Color(0xFF8E24AA)],
        build: () => const SpicinessPage(),
      ),
      _Tile(
        label: '1인분',
        subtitle: '밥 한공기 대비 양',
        emoji: '🍚',
        gradient: const [Color(0xFF63C766), Color(0xFF2E7D32)],
        build: () => const PortionsPage(),
      ),
      _Tile(
        label: 'PC 견적',
        subtitle: '부품 조합 성능 예측',
        emoji: '🖥️',
        gradient: const [Color(0xFF34D399), Color(0xFF0F766E)],
        build: () => const PcBuilderPage(),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _Header()),
              const SliverToBoxAdapter(child: _ScanCta()),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpace.lg),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpace.md,
                    crossAxisSpacing: AppSpace.md,
                    childAspectRatio: 0.92,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _CategoryCard(tile: tiles[i]),
                    childCount: tiles.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpace.lg)),
              const SliverToBoxAdapter(child: _FooterStats()),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpace.xl)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.xl - 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('세모표', style: AppText.display),
                  Padding(
                    padding: EdgeInsets.only(left: 3, top: 4),
                    child: Icon(Icons.change_history,
                        color: AppColors.brandA, size: 40),
                  ),
                ],
              ),
              _IconChip(),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          const Text(
            '세상 모든 크기의 표준',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.md, vertical: AppSpace.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: const [
                Text('👋', style: TextStyle(fontSize: 22)),
                SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    '오늘은 뭘 비교해볼까요?\n카테고리를 골라 시작해보세요.',
                    style: AppText.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderHi),
      ),
      child: const Icon(Icons.settings_outlined,
          color: AppColors.textSecondary, size: 22),
    );
  }
}

/// 눌렀을 때 살짝 줄어드는 반응 래퍼.
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _ScanCta extends StatelessWidget {
  const _ScanCta();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.lg, 0, AppSpace.lg, AppSpace.lg),
      child: _Pressable(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BarcodeScanPage()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.md, vertical: AppSpace.md + 2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.brandA, AppColors.brandB],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandA.withValues(alpha: 0.40),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.30)),
                ),
                child: const Icon(Icons.qr_code_scanner,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: AppSpace.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '바코드로 바로 비교',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '제품 찍으면 바로 비교 페이지로',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _Tile tile;
  const _CategoryCard({required this.tile});

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => tile.build()),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: tile.gradient,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: tile.palette.glow(0.38),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            children: [
              // 상단 광택
              Positioned(
                top: -40,
                left: -20,
                right: -20,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // 이모지 워터마크
              Positioned(
                right: -16,
                bottom: -22,
                child: Opacity(
                  opacity: 0.30,
                  child: Transform.rotate(
                    angle: -0.22,
                    child: Text(tile.emoji,
                        style: const TextStyle(fontSize: 124)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                                color: Colors.white
                                    .withValues(alpha: 0.28)),
                          ),
                          child: Text(tile.emoji,
                              style: const TextStyle(fontSize: 22)),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_outward_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 20,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      tile.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tile.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterStats extends StatelessWidget {
  const _FooterStats();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.md, vertical: AppSpace.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: const [
            Icon(Icons.dataset_outlined,
                color: AppColors.textTertiary, size: 18),
            SizedBox(width: AppSpace.sm),
            Expanded(
              child: Text(
                '7개 도메인 · 51,500+ 데이터 · 2026-06-10 스냅샷',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
