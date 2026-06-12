import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pizza_data.dart';
import 'pizza_page_popup.dart';

// 선택 팝업과 공유하는 전역 상태.
Map<String, dynamic>? pizza1;
Map<String, dynamic>? pizza2;

const Color _bg = Color(0xFF111111);
const Color _slot1 = Color(0xFFFF7A45); // 좌측 피자 색
const Color _slot2 = Color(0xFF4F8CFF); // 우측 피자 색

class PizzaPage extends StatefulWidget {
  const PizzaPage({super.key});
  @override
  State<PizzaPage> createState() => _PizzaPageState();
}

class _PizzaPageState extends State<PizzaPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final s1 = prefs.getString('pizza1');
    final s2 = prefs.getString('pizza2');
    setState(() {
      if (s1 != null) pizza1 = Map<String, dynamic>.from(jsonDecode(s1));
      if (s2 != null) pizza2 = Map<String, dynamic>.from(jsonDecode(s2));
    });
  }

  double _area(Map<String, dynamic>? p) {
    if (p == null) return 0;
    final r = (p['diameter'] as double) / 2;
    return r * r * math.pi;
  }

  double _pricePerSlice(Map<String, dynamic>? p) {
    if (p == null) return 0;
    final price = (p['price'] as int?) ?? 0;
    if (price == 0) return 0;
    final slices = (p['slices'] as int?) ?? 8;
    return price / slices;
  }

  double _pricePerArea(Map<String, dynamic>? p) {
    final a = _area(p);
    if (p == null || a == 0) return 0;
    final price = (p['price'] as int?) ?? 0;
    if (price == 0) return 0;
    return price / a;
  }

  Future<void> _openSelect() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const PizzaPagePopup(),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final a1 = _area(pizza1);
    final a2 = _area(pizza2);
    final ready = pizza1 != null && pizza2 != null;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Row(
          children: const [
            Text('피자 면적 비교',
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
                '두 피자를 골라보세요.\n지름→면적→조각당 가격까지 한눈에 비교해드려요.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _pizzaCard(1, pizza1, _slot1)),
                  const SizedBox(width: 12),
                  Expanded(child: _pizzaCard(2, pizza2, _slot2)),
                ],
              ),
              const SizedBox(height: 20),
              _areaVisual(a1, a2),
              const SizedBox(height: 20),
              _resultPanel(ready, a1, a2),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openSelect,
                  icon: const Icon(Icons.search),
                  label: const Text('피자 선택하기',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pizzaCard(int slot, Map<String, dynamic>? p, Color color) {
    final caption = slot == 1 ? '첫번째 피자' : '두번째 피자';
    return GestureDetector(
      onTap: _openSelect,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withAlpha(180)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(90),
                blurRadius: 14,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          children: [
            Text(caption,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(80),
                            blurRadius: 6,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: p == null
                        ? const Center(
                            child: Icon(Icons.add,
                                color: Colors.black54, size: 36))
                        : _pizzaThumbWidget(
                            (p['thumbnail'] as String?) ?? ''),
                  ),
                  if (p != null)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: pizzaBrandLogo(p['name'] as String, 32, ring: true),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              p == null ? '미선택' : (p['name'] as String),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900),
            ),
            if (p != null)
              Text(
                '${p['pizzaName']} · ${p['size']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _miniStat('ø ${p == null ? '-' : '${p['diameter']}cm'}'),
                const SizedBox(width: 6),
                _miniStat(p == null
                    ? '-원'
                    : (((p['price'] as int?) ?? 0) == 0
                        ? '가격?'
                        : '${p['price']}원')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(60),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(txt,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800)),
    );
  }

  Widget _areaVisual(double a1, double a2) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(double.infinity, 220),
            painter: _CirclePainter(a1: a1, a2: a2),
          ),
          if (a1 == 0 && a2 == 0)
            const Text('피자 선택하면 면적 비교 그림이 나와요',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          Positioned(
            top: 10,
            left: 14,
            child: _legend(
                _slot1, pizza1 == null ? '피자 1' : (pizza1!['name'] as String)),
          ),
          Positioned(
            top: 10,
            right: 14,
            child: _legend(
                _slot2, pizza2 == null ? '피자 2' : (pizza2!['name'] as String)),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color c, String label) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 130),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                  color: c, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _resultPanel(bool ready, double a1, double a2) {
    String headline;
    String sub;
    if (!ready) {
      headline = '두 피자를 모두 선택해주세요';
      sub = '아래 버튼에서 피자를 골라 비교를 시작해요.';
    } else if (a1 == a2) {
      headline = '두 피자 면적이 같아요';
      sub = '${pizza1!['name']} = ${pizza2!['name']}';
    } else {
      final bigP = a1 > a2 ? pizza1! : pizza2!;
      final smP = a1 > a2 ? pizza2! : pizza1!;
      final bigA = a1 > a2 ? a1 : a2;
      final smA = a1 > a2 ? a2 : a1;
      final pct = ((bigA - smA) / smA * 100).toStringAsFixed(1);
      headline = '${bigP['name']} ${bigP['size']}가 더 커요';
      sub = '${smP['name']} ${smP['size']}보다 약 $pct% 더 넓어요.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(headline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20, height: 1.3, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(sub,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          _statRow('면적 (cm²)',
              a1.toStringAsFixed(1),
              a2.toStringAsFixed(1),
              winner: a1 == a2 ? 0 : (a1 > a2 ? 1 : 2)),
          const SizedBox(height: 6),
          _statRow('가격 (원)',
              pizza1 == null
                  ? '-'
                  : (((pizza1!['price'] as int?) ?? 0) == 0
                      ? '정보없음'
                      : '${pizza1!['price']}'),
              pizza2 == null
                  ? '-'
                  : (((pizza2!['price'] as int?) ?? 0) == 0
                      ? '정보없음'
                      : '${pizza2!['price']}')),
          const SizedBox(height: 6),
          _statRow('조각당 가격',
              '${_pricePerSlice(pizza1).toStringAsFixed(0)}원',
              '${_pricePerSlice(pizza2).toStringAsFixed(0)}원',
              winner: _winnerLower(_pricePerSlice(pizza1), _pricePerSlice(pizza2))),
          const SizedBox(height: 6),
          _statRow('cm²당 가격',
              pizza1 == null
                  ? '-'
                  : '${_pricePerArea(pizza1).toStringAsFixed(1)}원',
              pizza2 == null
                  ? '-'
                  : '${_pricePerArea(pizza2).toStringAsFixed(1)}원',
              winner: _winnerLower(_pricePerArea(pizza1), _pricePerArea(pizza2))),
        ],
      ),
    );
  }

  /// 낮은 값이 이김 (싼 게 좋음). 0 = 비교 불가.
  int _winnerLower(double a, double b) {
    if (a == 0 || b == 0 || a == b) return 0;
    return a < b ? 1 : 2;
  }

  Widget _statRow(String label, String a, String b, {int winner = 0}) {
    Color tint(int slot) {
      if (winner == 0) return const Color(0xFFF6F6F6);
      return winner == slot
          ? (slot == 1 ? _slot1.withAlpha(40) : _slot2.withAlpha(40))
          : const Color(0xFFF6F6F6);
    }

    TextStyle val(int slot) => TextStyle(
          fontSize: 15,
          fontWeight: winner == slot ? FontWeight.w900 : FontWeight.w700,
          color: winner == slot ? Colors.black : Colors.black87,
        );

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w800)),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: tint(1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(a, textAlign: TextAlign.center, style: val(1)),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: tint(2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(b, textAlign: TextAlign.center, style: val(2)),
          ),
        ),
      ],
    );
  }
}

Widget _pizzaThumbWidget(String path) {
  if (path.isEmpty) {
    return const Center(child: Text('🍕', style: TextStyle(fontSize: 44)));
  }
  return ClipOval(child: Image.asset(path, fit: BoxFit.cover));
}

/// 두 피자 면적 비례 원을 같은 중심에 겹쳐 그림.
/// 가장 큰 원이 컨테이너 높이의 88% 가 되도록 스케일.
class _CirclePainter extends CustomPainter {
  final double a1; // 면적 cm²
  final double a2;
  _CirclePainter({required this.a1, required this.a2});

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final maxA = math.max(a1, a2);
    if (maxA <= 0) return;
    final maxR = s.height * 0.44;
    final r1 = math.sqrt(a1 / maxA) * maxR;
    final r2 = math.sqrt(a2 / maxA) * maxR;

    // 큰 원 먼저 (뒤), 작은 원 위에 (앞).
    final order = a1 >= a2
        ? [(r1, _slot1, '1', a1), (r2, _slot2, '2', a2)]
        : [(r2, _slot2, '2', a2), (r1, _slot1, '1', a1)];

    for (final (r, color, slot, area) in order) {
      final fill = Paint()..color = color.withAlpha(slot == '1' ? 130 : 130);
      final stroke = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(cx, cy), r, fill);
      canvas.drawCircle(Offset(cx, cy), r, stroke);

      // 라벨: 원 위쪽 가장자리.
      final tp = TextPainter(
        text: TextSpan(
          text: '${area.toStringAsFixed(0)}cm²',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              shadows: [Shadow(color: Colors.black87, blurRadius: 3)]),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy - r - tp.height - 2));
    }
  }

  @override
  bool shouldRepaint(_CirclePainter old) => old.a1 != a1 || old.a2 != a2;
}
