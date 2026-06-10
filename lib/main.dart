import 'package:flutter/material.dart';
import 'pizza_page.dart';
import 'shoes_page.dart';
import 'beverages_page.dart';
import 'apparel_page.dart';
import 'spiciness_page.dart';
import 'portions_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semopyo',
      theme: ThemeData(primarySwatch: Colors.blue),
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
}

const Color _bg = Color(0xFF0B0B0F);

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = <_Tile>[
      _Tile(
        label: '피자',
        subtitle: '한 조각이 얼마나 클까',
        emoji: '🍕',
        gradient: const [Color(0xFFFF7A45), Color(0xFFD9381E)],
        build: () => const PizzaPage(),
      ),
      _Tile(
        label: '신발',
        subtitle: '내 발에 맞는 핏 찾기',
        emoji: '👟',
        gradient: const [Color(0xFF4F8CFF), Color(0xFF2649C4)],
        build: () => const ShoesPage(),
      ),
      _Tile(
        label: '음료',
        subtitle: '카페별 사이즈 환산',
        emoji: '🥤',
        gradient: const [Color(0xFFB07A4B), Color(0xFF7A4A21)],
        build: () => const BeveragesPage(),
      ),
      _Tile(
        label: '옷',
        subtitle: '브랜드별 사이즈 환산',
        emoji: '👗',
        gradient: const [Color(0xFFFF6FA5), Color(0xFF9A2F77)],
        build: () => const ApparelPage(),
      ),
      _Tile(
        label: '맵기',
        subtitle: '스코빌로 매움 탐험',
        emoji: '🌶️',
        gradient: const [Color(0xFFE53935), Color(0xFF7B1FA2)],
        build: () => const SpicinessPage(),
      ),
      _Tile(
        label: '1인분',
        subtitle: '밥 한공기 대비 양',
        emoji: '🍚',
        gradient: const [Color(0xFF5BB95E), Color(0xFF2E7D32)],
        build: () => const PortionsPage(),
      ),
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _CategoryCard(tile: tiles[i]),
                  childCount: tiles.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(child: _footerStats()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '세모표',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 2, top: 4),
                    child: Icon(Icons.change_history,
                        color: Colors.white, size: 44),
                  ),
                ],
              ),
              _IconChip(icon: Icons.settings),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '세상 모든 크기의 표준',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white60,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A22), Color(0xFF15151B)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: const [
                Text('👋', style: TextStyle(fontSize: 22)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '오늘은 뭘 비교해볼까요?\n카테고리를 골라 시작해보세요.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: const [
            Icon(Icons.dataset, color: Colors.white54, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '6개 도메인 · 200+ 데이터 · 2026-06-10 스냅샷',
                style: TextStyle(
                  color: Colors.white54,
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

class _IconChip extends StatelessWidget {
  final IconData icon;
  const _IconChip({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _Tile tile;
  const _CategoryCard({required this.tile});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: tile.gradient.last.withAlpha(100),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -18,
                bottom: -24,
                child: Opacity(
                  opacity: 0.28,
                  child: Transform.rotate(
                    angle: -0.25,
                    child: Text(
                      tile.emoji,
                      style: const TextStyle(fontSize: 130),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tile.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    tile.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tile.subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
