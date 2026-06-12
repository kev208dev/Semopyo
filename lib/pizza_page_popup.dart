import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pizza_data.dart';
import 'pizza_page.dart';

int selectedSlot = 1;

const Color _bg = Color(0xFF0B0B0F);
const Color _slot1 = Color(0xFFFF7A45);
const Color _slot2 = Color(0xFF4F8CFF);

class PizzaPagePopup extends StatefulWidget {
  const PizzaPagePopup({super.key});

  @override
  State<PizzaPagePopup> createState() => _PizzaPagePopupState();
}

class _PizzaPagePopupState extends State<PizzaPagePopup> {
  List<Map<String, dynamic>> _allPizzas =
      pizzaList.map((e) => Map<String, dynamic>.from(e)).toList();
  String _query = '';
  String? _selectedBrand;

  @override
  void initState() {
    super.initState();
    _loadGlobal();
  }

  Future<void> _loadGlobal() async {
    try {
      final globals = await loadGlobalPizzas();
      if (!mounted) return;
      setState(() {
        _allPizzas = [
          ...pizzaList.map((e) => Map<String, dynamic>.from(e)),
          ...globals,
        ];
      });
    } catch (_) {/* 폴백: 기본 리스트만 */}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (pizza1 != null) {
      await prefs.setString('pizza1', jsonEncode(pizza1));
    }
    if (pizza2 != null) {
      await prefs.setString('pizza2', jsonEncode(pizza2));
    }
  }

  void _selectPizza(Map<String, dynamic> data) {
    setState(() {
      if (selectedSlot == 1) {
        pizza1 = data;
        if (pizza2 == null) selectedSlot = 2;
      } else {
        pizza2 = data;
        if (pizza1 == null) selectedSlot = 1;
      }
    });
    _persist();
  }

  /// 브랜드별 그룹 (정렬: 메뉴 수 많은 순).
  List<MapEntry<String, List<Map<String, dynamic>>>> _brandGroups() {
    final m = <String, List<Map<String, dynamic>>>{};
    for (final p in _allPizzas) {
      final b = (p['name'] as String?) ?? '?';
      m.putIfAbsent(b, () => []).add(p);
    }
    final list = m.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    return list;
  }

  List<Map<String, dynamic>> _searchResults() {
    final q = _query.toLowerCase();
    if (q.isEmpty) return const [];
    return _allPizzas.where((p) {
      return (p['name'] as String).toLowerCase().contains(q) ||
          (p['pizzaName'] as String).toLowerCase().contains(q) ||
          (p['size'] as String).toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.isNotEmpty;
    final inBrand = !hasQuery && _selectedBrand != null;
    final searchResults = hasQuery ? _searchResults() : const [];
    final brandItems = inBrand
        ? _allPizzas.where((p) => p['name'] == _selectedBrand).toList()
        : const [];

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: inBrand
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => setState(() => _selectedBrand = null),
              )
            : null,
        title: Text(
          inBrand ? (_selectedBrand ?? '피자 선택') : '피자 선택',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('완료',
                style: TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Row(
                children: [
                  Expanded(child: _slotChip(1, pizza1, _slot1, '첫번째')),
                  const SizedBox(width: 10),
                  Expanded(child: _slotChip(2, pizza2, _slot2, '두번째')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: inBrand
                      ? '$_selectedBrand 안에서 검색…'
                      : '브랜드·피자명·사이즈 검색',
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
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _headerRow(
                  hasQuery, inBrand, searchResults.length, brandItems.length),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: hasQuery
                  ? _searchList(searchResults.cast<Map<String, dynamic>>())
                  : (inBrand
                      ? _productGroupView(brandItems.cast<Map<String, dynamic>>())
                      : _brandGrid()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerRow(bool hasQuery, bool inBrand, int searchN, int brandN) {
    String left;
    String right;
    if (hasQuery) {
      left = '검색 결과';
      right = '$searchN개';
    } else if (inBrand) {
      left = selectedSlot == 1 ? '첫번째 피자 고르는 중' : '두번째 피자 고르는 중';
      final productCount = _groupProducts(
              _allPizzas.where((p) => p['name'] == _selectedBrand).toList())
          .length;
      right = '$productCount종 / $brandN사이즈';
    } else {
      left = '브랜드 선택';
      right = '${_brandGroups().length}개';
    }
    return Row(
      children: [
        Text(left,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        const Spacer(),
        Text(right,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _brandGrid() {
    final groups = _brandGroups();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.4,
      ),
      itemCount: groups.length,
      itemBuilder: (ctx, i) {
        final e = groups[i];
        final brand = e.key;
        final count = e.value.length;
        final hasSelected = (pizza1 != null && pizza1!['name'] == brand) ||
            (pizza2 != null && pizza2!['name'] == brand);
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _selectedBrand = brand),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: hasSelected
                        ? brandLogoColor(brand)
                        : Colors.white24,
                    width: hasSelected ? 2 : 1),
              ),
              child: Row(
                children: [
                  pizzaBrandLogo(brand, 44),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text('$count종',
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Colors.white38, size: 22),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _searchList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _pizzaTile(items[i], showBrand: true),
    );
  }

  /// 같은 brand 안에서 pizzaName(제품명) 기준 그룹화.
  /// pizzaName 비어있으면 '기본 메뉴'로 묶음.
  List<MapEntry<String, List<Map<String, dynamic>>>> _groupProducts(
      List<Map<String, dynamic>> items) {
    final m = <String, List<Map<String, dynamic>>>{};
    for (final p in items) {
      final raw = (p['pizzaName'] as String?) ?? '';
      final key = raw.trim().isEmpty ? '기본 메뉴' : raw.trim();
      m.putIfAbsent(key, () => []).add(p);
    }
    final list = m.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    return list;
  }

  Widget _productGroupView(List<Map<String, dynamic>> items) {
    final groups = _groupProducts(items);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: groups.length,
      itemBuilder: (ctx, i) {
        final product = groups[i].key;
        final sizes = [...groups[i].value]
          ..sort((a, b) =>
              (a['diameter'] as double).compareTo(b['diameter'] as double));
        return _productCard(product, sizes);
      },
    );
  }

  Widget _productCard(String product, List<Map<String, dynamic>> sizes) {
    final brand = (sizes.first['name'] as String?) ?? '';
    final brandColor = brandLogoColor(brand);
    final slotColor = selectedSlot == 1 ? _slot1 : _slot2;
    final selectedHere = sizes.any((s) =>
        (selectedSlot == 1 && pizza1 != null &&
            pizza1!['name'] == s['name'] &&
            pizza1!['size'] == s['size'] &&
            pizza1!['pizzaName'] == s['pizzaName']) ||
        (selectedSlot == 2 && pizza2 != null &&
            pizza2!['name'] == s['name'] &&
            pizza2!['size'] == s['size'] &&
            pizza2!['pizzaName'] == s['pizzaName']));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: selectedHere
              ? slotColor.withAlpha(40)
              : Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selectedHere ? slotColor : Colors.white24,
              width: selectedHere ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                pizzaBrandLogo(brand, 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '${sizes.length} 사이즈',
                        style: TextStyle(
                            color: brandColor.withAlpha(220),
                            fontSize: 11,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sizes.map((s) => _sizeChip(s)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sizeChip(Map<String, dynamic> p) {
    final name = p['name'] as String;
    final pizzaName = (p['pizzaName'] as String?) ?? '';
    final size = p['size'] as String;
    final diameter = p['diameter'] as double;
    final price = p['price'] as int;
    final area = (3.14159265 * (diameter / 2) * (diameter / 2)).toInt();
    final isSelected = (selectedSlot == 1 && pizza1 != null &&
            pizza1!['name'] == name &&
            pizza1!['size'] == size &&
            pizza1!['pizzaName'] == pizzaName) ||
        (selectedSlot == 2 && pizza2 != null &&
            pizza2!['name'] == name &&
            pizza2!['size'] == size &&
            pizza2!['pizzaName'] == pizzaName);
    final slotColor = selectedSlot == 1 ? _slot1 : _slot2;
    final priceTxt = price == 0
        ? '가격?'
        : '${price.toString().replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            )}원';
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _selectPizza({
          'thumbnail': p['thumbnail'],
          'name': name,
          'pizzaName': pizzaName,
          'size': size,
          'area': area,
          'price': price,
          'diameter': diameter,
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? slotColor
                : Colors.white.withAlpha(22),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isSelected ? Colors.white : Colors.white24,
                width: isSelected ? 2 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(size,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900)),
              const SizedBox(width: 6),
              Text('ø${diameter.toStringAsFixed(0)}cm',
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(width: 1, height: 12, color: Colors.white24),
              const SizedBox(width: 8),
              Text(priceTxt,
                  style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (price == 0
                              ? Colors.white38
                              : const Color(0xFFFFD54F)),
                      fontSize: 12,
                      fontWeight: FontWeight.w900)),
              if (isSelected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check, color: Colors.white, size: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _slotChip(int slot, Map<String, dynamic>? p, Color color, String label) {
    final active = selectedSlot == slot;
    return GestureDetector(
      onTap: () => setState(() => selectedSlot = slot),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? color.withAlpha(60) : Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: active ? color : Colors.white24,
              width: active ? 2 : 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: p == null
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withAlpha(140), width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.add, color: Colors.black38, size: 22),
                      ),
                    )
                  : pizzaBrandLogo(p['name'] as String, 46, ring: true),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: active ? Colors.white : Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                  Text(
                    p == null ? '미선택' : (p['name'] as String),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900),
                  ),
                  if (p != null)
                    Text(
                      '${p['size']} · ø${p['diameter']}cm',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pizzaTile(Map<String, dynamic> p, {required bool showBrand}) {
    final name = p['name'] as String;
    final pizzaName = (p['pizzaName'] as String?) ?? '';
    final size = p['size'] as String;
    final diameter = p['diameter'] as double;
    final price = p['price'] as int;
    final area = (3.14159265 * (diameter / 2) * (diameter / 2)).toInt();
    final isSelected = (selectedSlot == 1 && pizza1 != null &&
            pizza1!['name'] == name &&
            pizza1!['size'] == size) ||
        (selectedSlot == 2 && pizza2 != null &&
            pizza2!['name'] == name &&
            pizza2!['size'] == size);
    final slotColor = selectedSlot == 1 ? _slot1 : _slot2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _selectPizza({
            'thumbnail': p['thumbnail'],
            'name': name,
            'pizzaName': pizzaName,
            'size': size,
            'area': area,
            'price': price,
            'diameter': diameter,
          }),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? slotColor.withAlpha(40)
                  : Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isSelected ? slotColor : Colors.white24,
                  width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                pizzaBrandLogo(name, 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showBrand ? name : (pizzaName.isEmpty ? name : pizzaName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900),
                      ),
                      if (showBrand && pizzaName.isNotEmpty)
                        Text(pizzaName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _chip('${diameter.toStringAsFixed(0)}cm'),
                          _chip(size),
                          _chip('${area}cm²'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price == 0
                            ? '가격 정보 없음'
                            : '${price.toString().replaceAllMapped(
                                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                                  (m) => '${m[1]},',
                                )}원',
                        style: TextStyle(
                            color: price == 0
                                ? Colors.white38
                                : const Color(0xFFFFD54F),
                            fontSize: 14,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: slotColor, size: 28)
                else
                  const Icon(Icons.add_circle_outline,
                      color: Colors.white38, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(28),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(t,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800)),
    );
  }
}
