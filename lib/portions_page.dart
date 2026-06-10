import 'package:flutter/material.dart';
import 'portion_data.dart';
import 'brand_logo.dart';

const Color _bg = Color(0xFF111111);

class PortionsPage extends StatefulWidget {
  const PortionsPage({super.key});
  @override
  State<PortionsPage> createState() => _PortionsPageState();
}

class _PortionsPageState extends State<PortionsPage> {
  PortionItem _item = portionItems.firstWhere((p) => p.name == '빅맥');

  @override
  Widget build(BuildContext context) {
    final ratio = _item.unit == 'g' ? _item.amount / riceBowlG : null;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Row(
          children: const [
            Text('음식 1인분 비교',
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
                '음식을 고르면 1인분이 얼마인지\n밥 한공기(210g) 기준으로 환산해드려요.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),
              _picker(),
              const SizedBox(height: 20),
              _bigCard(),
              const SizedBox(height: 18),
              if (ratio != null) _riceBowlBar(ratio),
              const SizedBox(height: 18),
              _calorieRow(),
            ],
          ),
        ),
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
              imageAsset: portionImageFor(_item),
              imageUrl: _item.image.startsWith('http') ? _item.image : null,
              brandName: _item.brand,
              size: 36,
              fallbackIcon: Icons.restaurant,
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
                  Text('${_item.brand} · ${_item.type}',
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
    final picked = await showModalBottomSheet<PortionItem>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String query = '';
        return SafeArea(
          child: StatefulBuilder(builder: (ctx, setSheet) {
            final filtered = query.isEmpty
                ? portionItems
                : portionItems
                    .where((p) =>
                        p.name.toLowerCase().contains(query.toLowerCase()) ||
                        p.brand.toLowerCase().contains(query.toLowerCase()) ||
                        p.type.contains(query))
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
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: '음식·브랜드·종류 검색',
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
                        final p = filtered[i];
                        return ListTile(
                          leading: ProductImage(
                            imageAsset: portionImageFor(p),
                            imageUrl:
                                p.image.startsWith('http') ? p.image : null,
                            brandName: p.brand,
                            size: 30,
                            fallbackIcon: Icons.restaurant,
                          ),
                          title: Text(p.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800)),
                          subtitle: Text(
                              '${p.brand} · ${p.amount}${p.unit}',
                              style: const TextStyle(color: Colors.white60)),
                          trailing: p.kcal == null
                              ? null
                              : Text('${p.kcal}kcal',
                                  style: const TextStyle(
                                      color: Colors.orangeAccent,
                                      fontWeight: FontWeight.w800)),
                          onTap: () => Navigator.pop(ctx, p),
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

  Widget _bigCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ProductImage(
            imageAsset: portionImageFor(_item),
            imageUrl: _item.image.startsWith('http') ? _item.image : null,
            brandName: _item.brand,
            size: 72,
            fallbackIcon: Icons.restaurant,
          ),
          const SizedBox(height: 6),
          Text(_item.name,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900)),
          Text(_item.brand,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_item.amount}',
                  style: const TextStyle(
                      fontSize: 42, fontWeight: FontWeight.w900)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_item.unit,
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_item.type,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _riceBowlBar(double ratio) {
    final full = ratio.floor();
    final partial = ratio - full;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🍚 ',
                  style: TextStyle(fontSize: 20)),
              const Text('밥 한공기 기준',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('${ratio.toStringAsFixed(1)} 공기',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (int i = 0; i < full.clamp(0, 8); i++)
                const Text('🍚', style: TextStyle(fontSize: 30)),
              if (partial > 0.05 && full < 8)
                Opacity(
                  opacity: partial.clamp(0.3, 1.0),
                  child: const Text('🍚', style: TextStyle(fontSize: 30)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calorieRow() {
    if (_item.kcal == null) return const SizedBox.shrink();
    final kcal = _item.kcal!;
    final dailyPct = (kcal / 2000 * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$kcal kcal',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900)),
                Text('성인 1일 권장(2000kcal)의 $dailyPct%',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
