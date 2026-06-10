import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'spice_data.dart';
import 'brand_logo.dart';

const Color _bg = Color(0xFF111111);

const double _chartW = 2400;
const double _chartH = 700;
const int _shuMin = 300;
const int _shuMax = 25000;

class SpicinessPage extends StatefulWidget {
  const SpicinessPage({super.key});
  @override
  State<SpicinessPage> createState() => _SpicinessPageState();
}

class _SpicinessPageState extends State<SpicinessPage> {
  SpiceItem _item = spiceItems.firstWhere((s) => s.name == '불닭볶음면');
  final TransformationController _xform = TransformationController();

  @override
  void dispose() {
    _xform.dispose();
    super.dispose();
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
                '음식을 고르면 스코빌(SHU) 위치를 보여드려요.\n차트는 두 손가락으로 확대·축소·이동 가능해요.',
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
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text('스코빌 척도 탐험',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        _xform.value = Matrix4.identity(),
                    icon: const Icon(Icons.refresh,
                        color: Colors.white70, size: 16),
                    label: const Text('초기화',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const Text('↔ 두 손가락 확대·축소  /  드래그 이동',
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _chart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      clipBehavior: Clip.antiAlias,
      height: 360,
      child: InteractiveViewer(
        transformationController: _xform,
        boundaryMargin: const EdgeInsets.all(200),
        minScale: 0.4,
        maxScale: 6.0,
        constrained: false,
        child: SizedBox(
          width: _chartW,
          height: _chartH,
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(_chartW, _chartH),
                painter: _AxisPainter(selectedShu: _item.shu),
              ),
              for (int i = 0; i < spiceItems.length; i++)
                _itemMarker(spiceItems[i], i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemMarker(SpiceItem s, int idx) {
    final x = _xLog(s.shu);
    // Y staggering: 8행 순환, 위/아래 번갈아 0.. row 형태로.
    final rows = 10;
    final row = idx % rows;
    final y = _chartH / 2 + ((row - rows / 2) * 55);
    final color = spiceColor(spiceLevel(s.shu));
    final selected = s.name == _item.name;
    final pinAt = _chartH / 2; // 점은 가운데 축에
    return Positioned(
      left: x - 100,
      top: 0,
      width: 200,
      height: _chartH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 라벨 박스 → 축까지 연결선.
          Positioned(
            left: 99,
            top: math.min(y, pinAt),
            child: Container(
              width: 2,
              height: (y - pinAt).abs(),
              color: Colors.white24,
            ),
          ),
          // 축 위 점.
          Positioned(
            left: 92,
            top: pinAt - 8,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? Colors.white : Colors.black87,
                    width: selected ? 3 : 2),
                boxShadow: selected
                    ? [BoxShadow(color: color, blurRadius: 16)]
                    : null,
              ),
            ),
          ),
          // 라벨.
          Positioned(
            left: 0,
            top: y - 18,
            width: 200,
            child: GestureDetector(
              onTap: () => setState(() => _item = s),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: selected ? color : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: s.reference ? color : Colors.black87,
                        width: selected ? 2 : 1),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BrandLogo(brandName: s.brand, size: 16),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 130),
                            child: Text(
                              s.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      Text('${s.shu} SHU',
                          style: TextStyle(
                              color: selected
                                  ? Colors.white70
                                  : Colors.black54,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
        final sorted = [...spiceItems]..sort((a, b) => a.shu.compareTo(b.shu));
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

double _xLog(int shu) {
  final clamped = shu.clamp(_shuMin, _shuMax);
  final t = (math.log(clamped) - math.log(_shuMin)) /
      (math.log(_shuMax) - math.log(_shuMin));
  // 좌우 50px 패딩.
  return 50 + t * (_chartW - 100);
}

class _AxisPainter extends CustomPainter {
  final int selectedShu;
  _AxisPainter({required this.selectedShu});

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;

    // 배경 어둡게.
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF0F0F0F));

    // 그리드: 주요 SHU 눈금에 세로선 + 라벨.
    final ticks = [500, 1000, 2000, 3000, 5000, 7000, 10000, 15000, 20000];
    final grid = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;
    final tickStyle = const TextStyle(
        color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w700);
    for (final t in ticks) {
      final x = _xLog(t);
      canvas.drawLine(Offset(x, 30), Offset(x, h - 30), grid);
      final tp = TextPainter(
        text: TextSpan(text: '$t', style: tickStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, h - 24));
    }

    // 중앙 축선 (그라데이션).
    final axisY = h / 2;
    final axisRect =
        Rect.fromCenter(center: Offset(w / 2, axisY), width: w - 100, height: 18);
    final axisPaint = Paint()
      ..shader = const LinearGradient(colors: [
        Color(0xFFFFE082),
        Color(0xFFFFB74D),
        Color(0xFFFF7043),
        Color(0xFFE53935),
        Color(0xFF7B1FA2),
      ]).createShader(axisRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(axisRect, const Radius.circular(9)),
      axisPaint,
    );

    // 선택 강조선.
    final selX = _xLog(selectedShu);
    final selPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(Offset(selX, 10), Offset(selX, h - 10), selPaint);

    // 단계 라벨 (가운데 위쪽).
    final levels = [
      (3500, '매움'),
      (5500, '많이매움'),
      (10000, '극강'),
    ];
    final lvlStyle = const TextStyle(
        color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w900);
    for (final (shu, label) in levels) {
      final x = _xLog(shu);
      final tp = TextPainter(
        text: TextSpan(text: label, style: lvlStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, 6));
    }
  }

  @override
  bool shouldRepaint(_AxisPainter old) => old.selectedShu != selectedShu;
}
