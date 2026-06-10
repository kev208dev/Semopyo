import 'package:flutter/material.dart';
import 'package:semopyo/shoe_select_page.dart';
import 'shoe_card_widgets.dart';
import 'shoes_data.dart';
import 'fit_data.dart';
import 'brand_logo.dart';

// 선택 화면과 공유하는 전역 상태. 단일 신발 모드: target 제거.
ShoeModel? currentShoe = defaultCurrentShoe();
int currentSize = 270;

const Color _bg = Color(0xFF111111);

class ShoesPage extends StatefulWidget {
  const ShoesPage({super.key});
  @override
  State<ShoesPage> createState() => _ShoesPageState();
}

class _ShoesPageState extends State<ShoesPage> {
  Future<void> _openSelect() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const ShoeSelectPage(),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cur = currentShoe;
    final fit = cur == null ? null : fitFor(cur.brand, cur.name);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Row(
          children: const [
            Text(
              '신발 체감사이즈',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
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
                '궁금한 신발을 골라보세요.\n그 신발의 핏 경향·발볼·추천 사이즈를 알려드려요.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: cur == null
                    ? _placeholder()
                    : MainShoeCard(
                        brand: cur.brand,
                        name: cur.name,
                        price: cur.price,
                        imageUrl: cur.image,
                        color: cur.color,
                        labelSize: currentSize,
                        caption: '선택한 신발',
                        onSizeChanged: (v) =>
                            setState(() => currentSize = v),
                      ),
              ),

              const SizedBox(height: 16),
              if (cur != null && fit != null) _resultPanel(cur, fit),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openSelect,
                  icon: const Icon(Icons.search),
                  label: const Text(
                    '다른 신발 보기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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

  Widget _placeholder() {
    return GestureDetector(
      onTap: _openSelect,
      child: Container(
        width: 300,
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline,
                color: Colors.white70, size: 40),
            SizedBox(height: 8),
            Text('신발 선택',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 2),
            Text('탭해서 고르기',
                style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _resultPanel(ShoeModel cur, FitInfo fit) {
    final estFoot = estimatedFootLength(currentSize, fit);
    final headline = '${cur.brand}은(는) ${verdictPhrase(fit)}예요';
    final tip = _sizeTip(fit);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: BrandLogo(
                brandName: cur.brand, fallback: '👟', size: 48, bg: Colors.transparent),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              headline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20, height: 1.3, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              tip,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          _stat('🦶 발볼', fit.toebox, _toeboxNote(fit.toebox)),
          const SizedBox(height: 10),
          _stat('📏 라벨 사이즈', 'KR $currentSize',
              '내부 길이 약 ${estFoot}mm 들어가요'),
          const SizedBox(height: 10),
          _stat('👟 핏 경향', fit.verdict, _verdictNote(fit)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  String _sizeTip(FitInfo f) {
    if (f.verdict == '크게') return '평소보다 한 치수 작게 신어보세요';
    if (f.verdict == '작게') return '평소보다 한 치수 크게 신어보세요';
    return '평소 사이즈 그대로 신으세요';
  }

  String _verdictNote(FitInfo f) {
    if (f.verdict == '크게') return '라벨보다 큰 편';
    if (f.verdict == '작게') return '라벨보다 작은 편';
    return '라벨대로';
  }

  String _toeboxNote(String toebox) {
    switch (toebox) {
      case '좁음':
        return '발볼 넓으면 답답할 수 있음';
      case '넓음':
        return '발볼 넓어도 편함';
      default:
        return '평범한 발볼';
    }
  }
}
