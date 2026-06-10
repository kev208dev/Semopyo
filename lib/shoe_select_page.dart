import 'package:flutter/material.dart';
import 'shoes_data.dart';
import 'shoe_card_widgets.dart';
import 'fit_data.dart';
import 'shoes_page.dart';
import 'brand_logo.dart';

const Color _bg = Color(0xFF111111);

class ShoeSelectPage extends StatefulWidget {
  const ShoeSelectPage({super.key});

  @override
  State<ShoeSelectPage> createState() => _ShoeSelectPageState();
}

class _ShoeSelectPageState extends State<ShoeSelectPage> {
  List<ShoeModel> shoes = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await SneakerApiService().fetchShoes();
      if (!mounted) return;
      setState(() {
        shoes = res.isEmpty ? fallbackShoes : res;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = '신발 목록을 불러오지 못해 기본 목록을 사용해요.';
        shoes = fallbackShoes;
        loading = false;
      });
    }
  }

  void _assign(ShoeModel s) {
    setState(() => currentShoe = s);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          '신발 선택',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                  error!,
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: shoes.length,
                      itemBuilder: (_, i) => _tile(shoes[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(ShoeModel s) {
    final f = fitFor(s.brand, s.name);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: () => _assign(s),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(90),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFFF2F2F2),
                    child: shoeImage(s.image, width: 72, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          BrandLogo(brandName: s.brand, fallback: '👟', size: 22),
                          const SizedBox(width: 6),
                          Text(
                            s.brand,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        s.name.isEmpty ? '(이름 없음)' : s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (s.price.isNotEmpty)
                            Text(
                              '${s.price}원',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111111),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '발볼 ${f.toebox} · ${f.verdict}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle, color: Color(0xFF333333)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
