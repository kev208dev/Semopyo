import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'spice_data.dart';
import 'brand_logo.dart';

const Color _bg = Color(0xFF111111);

const int _shuMin = 300;
const int _shuMax = 25000;

class SpicinessPage extends StatefulWidget {
  final String? scannedName;
  final String? scannedClassification;
  const SpicinessPage(
      {super.key, this.scannedName, this.scannedClassification});
  @override
  State<SpicinessPage> createState() => _SpicinessPageState();
}

class _SpicinessPageState extends State<SpicinessPage> {
  late SpiceItem _item;
  List<SpiceItem> _globalSpice = const [];
  String _query = '';

  List<SpiceItem> get _pool => [...spiceItems, ..._globalSpice];

  List<SpiceItem> _filteredPool() {
    final sorted = [..._pool]..sort((a, b) => a.shu.compareTo(b.shu));
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return sorted;
    return sorted
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.brand.toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _item = matchSpiceFromName(widget.scannedName) ??
        buildEstimatedSpice(
            widget.scannedName, widget.scannedClassification) ??
        spiceItems.firstWhere((s) => s.name == '신라면');
    _loadGlobal();
  }

  Future<void> _loadGlobal() async {
    try {
      final g = await loadGlobalSpice();
      if (!mounted) return;
      setState(() => _globalSpice = g);
    } catch (_) {/* 폴백: 기본 리스트 */}
  }

  @override
  Widget build(BuildContext context) {
    final level = spiceLevel(_item.shu);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Row(
          children: const [
            Text('체감 맵기',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            Icon(Icons.change_history, color: Colors.white, size: 26),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '음식을 고르면 스코빌(SHU) 위치를\n좌(순함)→우(매움) 막대로 보여드려요.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),
              _picker(),
              const SizedBox(height: 16),
              _resultCard(level),
              const SizedBox(height: 18),
              _peppers(level),
              const SizedBox(height: 22),
              const Text('스코빌 척도 위치',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _spectrumBar(),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text('맵기 순 항목 (탭하여 선택)',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900)),
                  const Spacer(),
                  Text('${_pool.length}건',
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              _searchBar(),
              const SizedBox(height: 10),
              _itemStrip(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _spectrumBar() {
    return LayoutBuilder(builder: (ctx, c) {
      final w = c.maxWidth;
      const barH = 24.0;
      final selT = _normShu(_item.shu);
      const refs = <(int, String)>[
        (570, '안성탕면'),
        (3400, '신라면'),
        (4404, '불닭'),
        (10000, '청양/핵불닭'),
        (20000, '극강'),
      ];
      return Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 70,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 선택 항목 라벨 + 화살표
                  Positioned(
                    left: (selT * (w - 16)).clamp(0, w - 16) - 50,
                    top: 0,
                    width: 100,
                    child: Column(
                      children: [
                        Text(
                          _item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900),
                        ),
                        Text('${_item.shu}',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                        const Icon(Icons.arrow_drop_down,
                            color: Colors.white, size: 26),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 그라데이션 바
            Container(
              height: barH,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFFFFE082),
                  Color(0xFFFFB74D),
                  Color(0xFFFF7043),
                  Color(0xFFE53935),
                  Color(0xFF7B1FA2),
                ]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
            ),
            const SizedBox(height: 6),
            // 기준선 라벨 (포지셔닝)
            SizedBox(
              height: 38,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final r in refs)
                    Positioned(
                      left: (_normShu(r.$1) * (w - 16)).clamp(0, w - 16) - 36,
                      top: 0,
                      width: 72,
                      child: Column(
                        children: [
                          Container(
                              width: 1, height: 6, color: Colors.white38),
                          Text(r.$2,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                          Text('${r.$1}',
                              style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _searchBar() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: '음식·브랜드 검색 (예: 불닭, 농심, Takis)',
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => setState(() => _query = ''),
              ),
        filled: true,
        fillColor: Colors.white12,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (v) => setState(() => _query = v),
    );
  }

  Widget _itemStrip() {
    final sorted = _filteredPool();
    if (sorted.isEmpty) {
      return Container(
        height: 110,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: const Text('검색 결과 없음',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      );
    }
    final selIdx = sorted.indexWhere((s) => s.name == _item.name);
    final ctrl = ScrollController(
        initialScrollOffset: (selIdx.clamp(0, sorted.length - 1) * 110.0)
            .clamp(0, math.max(0, sorted.length * 110.0 - 320)));
    return SizedBox(
      height: 110,
      child: ListView.separated(
        controller: ctrl,
        scrollDirection: Axis.horizontal,
        itemCount: sorted.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = sorted[i];
          final color = spiceColor(spiceLevel(s.shu));
          final selected = s.name == _item.name;
          return GestureDetector(
            onTap: () => setState(() => _item = s),
            child: Container(
              width: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? color : Colors.white.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: selected ? Colors.white : Colors.white24,
                    width: selected ? 2 : 1),
                boxShadow: selected
                    ? [BoxShadow(color: color, blurRadius: 12)]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BrandLogo(brandName: s.brand, size: 18),
                      const Spacer(),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(s.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: selected ? Colors.white : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900)),
                  Text('${s.shu} SHU',
                      style: TextStyle(
                          color: selected ? Colors.white70 : Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _picker() {
    return GestureDetector(
      onTap: _openPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            ProductImage(
              imageAsset: spiceImageFor(_item),
              imageUrl: _item.image.startsWith('http') ? _item.image : null,
              brandName: _item.brand,
              size: 44,
              fallbackIcon: Icons.local_fire_department,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_item.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900)),
                  Text(_item.brand,
                      style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.swap_horiz, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker() async {
    final picked = await showModalBottomSheet<SpiceItem>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final sorted = [..._pool]..sort((a, b) => a.shu.compareTo(b.shu));
        String query = '';
        return SafeArea(
          child: StatefulBuilder(builder: (ctx, setSheet) {
            final filtered = query.isEmpty
                ? sorted
                : sorted
                    .where((s) =>
                        s.name.toLowerCase().contains(query.toLowerCase()) ||
                        s.brand.toLowerCase().contains(query.toLowerCase()))
                    .toList();
            return SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.8,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('음식 선택',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: TextField(
                      autofocus: false,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: '음식·브랜드 검색 (예: 불닭, 농심)',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white12,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) => setSheet(() => query = v),
                    ),
                  ),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('검색 결과 없음',
                          style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.w700)),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final s = filtered[i];
                        return ListTile(
                          leading: ProductImage(
                            imageAsset: spiceImageFor(s),
                            brandName: s.brand,
                            size: 30,
                            fallbackIcon: Icons.local_fire_department,
                          ),
                          title: Text(s.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800)),
                          subtitle: Text('${s.brand} · ${s.shu} SHU',
                              style: const TextStyle(color: Colors.white60)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: spiceColor(spiceLevel(s.shu)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(spiceLabel(spiceLevel(s.shu)),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800)),
                          ),
                          onTap: () => Navigator.pop(ctx, s),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
    if (picked != null) setState(() => _item = picked);
  }

  Widget _resultCard(int level) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(spiceLabel(level),
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: spiceColor(level))),
          const SizedBox(height: 6),
          Text('${_item.shu} SHU',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          _comparison(),
        ],
      ),
    );
  }

  Widget _comparison() {
    const shin = 3400;
    const buldak = 4404;
    const nuclear = 10000;
    String txt;
    if (_item.shu < shin) {
      final r = (shin / _item.shu).toStringAsFixed(1);
      txt = '신라면보다 $r배 덜 매워요';
    } else if (_item.shu < buldak) {
      final r = (_item.shu / shin).toStringAsFixed(1);
      txt = '신라면의 $r배 (불닭은 아직 안 됨)';
    } else if (_item.shu < nuclear) {
      final r = (_item.shu / buldak).toStringAsFixed(1);
      txt = '불닭의 $r배 정도예요';
    } else {
      final r = (_item.shu / nuclear).toStringAsFixed(1);
      txt = '핵불닭의 $r배 — 주의 ☢️';
    }
    return Text(txt,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            height: 1.5,
            fontWeight: FontWeight.w600));
  }

  Widget _peppers(int level) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 1; i <= 5; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: i <= level ? 1.0 : 0.18,
                child: const Text('🌶️', style: TextStyle(fontSize: 32)),
              ),
            ),
        ],
      ),
    );
  }
}

/// SHU → 0..1 정규화 (로그 스케일).
double _normShu(int shu) {
  final clamped = shu.clamp(_shuMin, _shuMax);
  return (math.log(clamped) - math.log(_shuMin)) /
      (math.log(_shuMax) - math.log(_shuMin));
}
