import 'package:flutter/material.dart';
import 'beverages_data.dart';
import 'brand_logo.dart';

const Color _bg = Color(0xFF111111);

class BeveragesPage extends StatefulWidget {
  final String? scannedName;
  const BeveragesPage({super.key, this.scannedName});
  @override
  State<BeveragesPage> createState() => _BeveragesPageState();
}

class _BeveragesPageState extends State<BeveragesPage> {
  late BevBrand _brand;
  late BevSize _size;

  @override
  void initState() {
    super.initState();
    _brand = matchBeverageBrandFromName(widget.scannedName) ??
        beverageBrands[0];
    _size = _brand.sizes.length > 1 ? _brand.sizes[1] : _brand.sizes[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Row(
          children: const [
            Text('음료 용량 환산',
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
                '익숙한 카페·사이즈를 고르면\n다른 카페에서 같은 양은 어떤 사이즈인지 알려드려요.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              _picker(),
              const SizedBox(height: 16),
              _myCup(),
              const SizedBox(height: 24),
              const Text('다른 카페 환산',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _otherBrandsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _picker() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_cafe, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text('카페',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              DropdownButton<BevBrand>(
                value: _brand,
                dropdownColor: const Color(0xFF222222),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
                underline: const SizedBox(),
                items: [
                  for (final b in beverageBrands)
                    DropdownMenuItem(
                        value: b, child: Text(b.name)),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _brand = v;
                    _size = v.sizes[v.sizes.length ~/ 2];
                  });
                },
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          Row(
            children: [
              const Icon(Icons.straighten, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text('사이즈',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              DropdownButton<BevSize>(
                value: _brand.sizes.contains(_size) ? _size : _brand.sizes[0],
                dropdownColor: const Color(0xFF222222),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
                underline: const SizedBox(),
                items: [
                  for (final s in _brand.sizes)
                    DropdownMenuItem(
                        value: s, child: Text('${s.label} · ${s.ml}mL')),
                ],
                onChanged: (v) => setState(() => _size = v ?? _size),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _myCup() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('내 음료',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ProductImage(
            imageAsset: kBeverageDefaultImage,
            brandName: _brand.name,
            size: 64,
            fallbackIcon: Icons.local_cafe,
          ),
          const SizedBox(height: 8),
          BrandWordmark(
              brandName: _brand.name, height: 30, textColor: Colors.black),
          const SizedBox(height: 12),
          _cup(_size.ml, big: true, color: Colors.brown.shade400),
          const SizedBox(height: 10),
          Text('${_size.label} · ${_size.ml}mL',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900)),
          _cupCaption(_size.ml),
          const SizedBox(height: 4),
          Text(_size.temp,
              style: TextStyle(
                  color: _size.temp == '핫'
                      ? Colors.red.shade400
                      : _size.temp == '아이스'
                          ? Colors.blue.shade400
                          : Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _otherBrandsGrid() {
    final others =
        beverageBrands.where((b) => b.name != _brand.name).toList();
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.85,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        for (final b in others)
          _otherCard(b, closestSize(b, _size.ml, _size.temp)),
      ],
    );
  }

  Widget _otherCard(BevBrand b, BevSize match) {
    final diff = match.ml - _size.ml;
    final diffStr = diff == 0
        ? '같음'
        : diff > 0
            ? '+${diff}mL'
            : '${diff}mL';
    final diffColor = diff.abs() <= 30
        ? Colors.green.shade600
        : diff.abs() <= 80
            ? Colors.orange.shade700
            : Colors.red.shade700;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          BrandWordmark(brandName: b.name, height: 24, theme: 'dark'),
          const SizedBox(height: 8),
          Expanded(child: _cup(match.ml, color: Colors.white)),
          const SizedBox(height: 6),
          Text(match.label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          Text('${match.ml}mL',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          _cupCaption(match.ml, color: Colors.white54),
          const SizedBox(height: 2),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: diffColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(diffStr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  /// 컵 도형. 컵 전체 용량 [cupMaxMl] (기본 1000mL = 1L) 안에 [ml] 만큼 액체.
  /// 즉 모든 음료를 동일한 1L 컵에 부어 사이즈 비교.
  Widget _cup(int ml, {bool big = false, required Color color}) {
    const cupMaxMl = 1000;
    final ratio = (ml / cupMaxMl).clamp(0.05, 1.0);
    final w = big ? 90.0 : 60.0;
    final h = big ? 140.0 : 90.0;
    return SizedBox(
      width: w,
      height: h,
      child: CustomPaint(
        painter: _CupPainter(
          fillRatio: ratio,
          fillColor: color,
          cupMaxMl: cupMaxMl,
          big: big,
        ),
      ),
    );
  }

  /// 컵 캡션: 컵 전체 대비 채움 비율 텍스트.
  Widget _cupCaption(int ml, {Color color = Colors.black54}) {
    const cupMaxMl = 1000;
    final pct = (ml / cupMaxMl * 100).round();
    return Text('1L 컵의 $pct%',
        style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700));
  }
}

class _CupPainter extends CustomPainter {
  final double fillRatio;
  final Color fillColor;
  final int cupMaxMl;
  final bool big;
  _CupPainter({
    required this.fillRatio,
    required this.fillColor,
    required this.cupMaxMl,
    required this.big,
  });

  @override
  void paint(Canvas canvas, Size s) {
    final outline = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    // 컵 위에 용량 라벨 자리 확보 (상단 패딩 16px).
    final topPad = big ? 18.0 : 14.0;
    final botPad = 2.0;
    final cupH = s.height - topPad - botPad;
    // 컵 사다리꼴: 위 100% 너비, 아래 70%.
    final topW = s.width;
    final botW = s.width * 0.7;
    final cupTopY = topPad;
    final cupBotY = s.height - botPad;
    final cupPath = Path()
      ..moveTo((s.width - topW) / 2, cupTopY)
      ..lineTo((s.width + topW) / 2, cupTopY)
      ..lineTo((s.width + botW) / 2, cupBotY)
      ..lineTo((s.width - botW) / 2, cupBotY)
      ..close();

    // 액체: 아래에서부터 fillRatio.
    final liquidTop = cupTopY + cupH * (1 - fillRatio);
    final t = (liquidTop - cupTopY) / cupH;
    final liquidTopW = topW + (botW - topW) * t;
    final liquidPath = Path()
      ..moveTo((s.width - liquidTopW) / 2, liquidTop)
      ..lineTo((s.width + liquidTopW) / 2, liquidTop)
      ..lineTo((s.width + botW) / 2, cupBotY)
      ..lineTo((s.width - botW) / 2, cupBotY)
      ..close();
    canvas.drawPath(liquidPath, Paint()..color = fillColor.withAlpha(180));
    canvas.drawPath(cupPath, outline);

    // 컵 입구 위 용량 라벨.
    final capLabel = cupMaxMl >= 1000
        ? '${(cupMaxMl / 1000).toStringAsFixed(cupMaxMl % 1000 == 0 ? 0 : 1)}L 컵'
        : '$cupMaxMl mL 컵';
    final tp = TextPainter(
      text: TextSpan(
        text: capLabel,
        style: TextStyle(
          color: Colors.black87,
          fontSize: big ? 11 : 9,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((s.width - tp.width) / 2, 0));

    // 중간 눈금 (1/2 위치) — 큰 컵에만.
    if (big) {
      final halfY = cupTopY + cupH * 0.5;
      final dash = Paint()
        ..color = Colors.black38
        ..strokeWidth = 1;
      final midW = topW + (botW - topW) * 0.5;
      final x1 = (s.width - midW) / 2;
      final x2 = (s.width + midW) / 2;
      // dashed line
      const dashLen = 4.0;
      const gapLen = 3.0;
      double x = x1;
      while (x < x2) {
        canvas.drawLine(Offset(x, halfY), Offset(x + dashLen, halfY), dash);
        x += dashLen + gapLen;
      }
      final halfTp = TextPainter(
        text: const TextSpan(
          text: '500',
          style: TextStyle(
              color: Colors.black54,
              fontSize: 9,
              fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      halfTp.paint(canvas, Offset(x2 + 2, halfY - halfTp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_CupPainter old) =>
      old.fillRatio != fillRatio ||
      old.fillColor != fillColor ||
      old.cupMaxMl != cupMaxMl ||
      old.big != big;
}
