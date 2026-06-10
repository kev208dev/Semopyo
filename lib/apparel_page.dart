import 'package:flutter/material.dart';
import 'apparel_data.dart';
import 'brand_logo.dart';

const Color _bg = Color(0xFF111111);

class ApparelPage extends StatefulWidget {
  const ApparelPage({super.key});
  @override
  State<ApparelPage> createState() => _ApparelPageState();
}

class _ApparelPageState extends State<ApparelPage> {
  ApparelBrand _from = apparelBrands[0]; // 윌슨 표준
  ApparelBrand _to = apparelBrands[4];   // 무신사
  String _size = 'M';

  @override
  Widget build(BuildContext context) {
    final rec = recommendedSize(_size, _to);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Row(
          children: const [
            Text('체감 옷 사이즈 비교',
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
                '내가 즐겨 입는 옷을 기준으로\n새 브랜드에서 어떤 사이즈를 사야할지 알려드려요.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),
              _sizePicker(),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _brandCard('현재', _from, _size, isFrom: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _brandCard('새 옷', _to, rec, isFrom: false)),
                ],
              ),
              const SizedBox(height: 18),
              _resultPanel(rec),
              const SizedBox(height: 18),
              _comparisonTable(rec),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sizePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.straighten, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          const Text('내 사이즈',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          for (final s in sizeLabels)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: ChoiceChip(
                label: Text(s),
                selected: _size == s,
                onSelected: (_) => setState(() => _size = s),
                selectedColor: Colors.white,
                backgroundColor: Colors.white12,
                labelStyle: TextStyle(
                  color: _size == s ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _brandCard(String caption, ApparelBrand b, String label,
      {required bool isFrom}) {
    return GestureDetector(
      onTap: () => _openBrandPicker(isFrom),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Column(
          children: [
            Text(caption,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            BrandWordmark(
                brandName: b.name, height: 28, theme: 'dark'),
            const SizedBox(height: 8),
            ProductImage(
              imageAsset: apparelImageFor(b),
              brandName: b.name,
              size: 72,
              fallbackIcon: Icons.checkroom,
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 4),
            Text(b.category,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Icon(Icons.touch_app, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }

  Future<void> _openBrandPicker(bool isFrom) async {
    final picked = await showModalBottomSheet<ApparelBrand>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text('브랜드 선택',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
              ),
              for (final b in apparelBrands)
                ListTile(
                  leading:
                      const Icon(Icons.checkroom, color: Colors.white70),
                  title: Text(b.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800)),
                  subtitle: Text(
                      '${b.category} · ${fitPhrase(b.fit)}',
                      style: const TextStyle(color: Colors.white60)),
                  onTap: () => Navigator.pop(ctx, b),
                ),
            ],
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
        } else {
          _to = picked;
        }
      });
    }
  }

  Widget _resultPanel(String rec) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('${_to.name} 에선 $rec 사이즈를 사세요',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  height: 1.3,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(
            '${_to.name}은(는) ${fitPhrase(_to.fit)}예요.\n'
            '${_to.fit.silhouette} 실루엣이에요.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _comparisonTable(String rec) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(8),
      child: Table(
        border: TableBorder.all(color: Colors.white10, width: 1),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(3),
        },
        children: [
          _row('항목', _from.name, _to.name, header: true),
          _row('사이즈', _size, rec),
          _row('어깨 cm', _from.shoulder.toStringAsFixed(1),
              _to.shoulder.toStringAsFixed(1)),
          _row('가슴 단면 cm', _from.chestHalf.toStringAsFixed(1),
              _to.chestHalf.toStringAsFixed(1)),
          _row('총장 cm', _from.length.toStringAsFixed(1),
              _to.length.toStringAsFixed(1)),
          _row('핏 경향', _from.fit.tendency, _to.fit.tendency),
          _row('실루엣', _from.fit.silhouette, _to.fit.silhouette),
        ],
      ),
    );
  }

  TableRow _row(String a, String b, String c, {bool header = false}) {
    final style = TextStyle(
      fontSize: 12,
      fontWeight: header ? FontWeight.w900 : FontWeight.w700,
      color: header ? Colors.white : Colors.white,
    );
    return TableRow(
      decoration: header
          ? BoxDecoration(color: Colors.white.withAlpha(25))
          : null,
      children: [
        for (final t in [a, b, c])
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(t, textAlign: TextAlign.center, style: style),
          ),
      ],
    );
  }
}

