// 바코드 스캔 → 제품 조회 → 해당 비교 카테고리로 이동.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'barcode_api.dart';
import 'beverages_data.dart';
import 'beverages_page.dart';
import 'spice_data.dart';
import 'spiciness_page.dart';
import 'portion_data.dart';
import 'portions_page.dart';
import 'pizza_page.dart';

const Color _bg = Color(0xFF0B0B0F);

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  State<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
    ],
  );

  bool _busy = false; // 조회 중이거나 결과 시트 표시 중

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _busy = true);
    await _controller.stop();

    final result = await lookupBarcode(raw);
    if (!mounted) return;
    await _showResultSheet(result);
  }

  Future<void> _resume() async {
    setState(() => _busy = false);
    try {
      await _controller.start();
    } catch (_) {}
  }

  Widget _pageForCategory(BarcodeCategory c,
      {String? scannedName, String? scannedClassification}) {
    switch (c) {
      case BarcodeCategory.beverage:
        return BeveragesPage(scannedName: scannedName);
      case BarcodeCategory.spiciness:
        return SpicinessPage(
            scannedName: scannedName,
            scannedClassification: scannedClassification);
      case BarcodeCategory.portion:
        return PortionsPage(
            scannedName: scannedName,
            scannedClassification: scannedClassification);
      case BarcodeCategory.pizza:
        return const PizzaPage();
      case BarcodeCategory.unknown:
        return PortionsPage(
            scannedName: scannedName,
            scannedClassification: scannedClassification);
    }
  }

  /// 스캔된 제품명을 데이터 리스트 직접 매칭해 카테고리 추정.
  /// 매치 길이 최대인 카테고리 선택. 모두 실패 시 null.
  BarcodeCategory? _categoryFromScannedName(String name) {
    final spice = matchSpiceFromName(name);
    final portion = matchPortionFromName(name);
    final bev = matchBeverageBrandFromName(name);
    int spiceLen = spice?.name.length ?? 0;
    int portionLen = portion?.name.length ?? 0;
    int bevLen = bev?.name.length ?? 0;
    final maxLen = [spiceLen, portionLen, bevLen]
        .reduce((a, b) => a > b ? a : b);
    if (maxLen == 0) return null;
    if (spiceLen == maxLen) return BarcodeCategory.spiciness;
    if (bevLen == maxLen) return BarcodeCategory.beverage;
    return BarcodeCategory.portion;
  }

  void _goCategory(BarcodeCategory c,
      {String? scannedName, String? scannedClassification}) {
    Navigator.of(context).pop(); // 시트 닫기
    final effective =
        (scannedName != null ? _categoryFromScannedName(scannedName) : null) ??
            c;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _pageForCategory(effective,
            scannedName: scannedName,
            scannedClassification: scannedClassification),
      ),
    );
  }

  Future<void> _showResultSheet(BarcodeLookupResult result) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF15151B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _ResultSheet(
        result: result,
        onGoCategory: (c) => _goCategory(c,
            scannedName: result.product?.productName,
            scannedClassification: result.product?.classification),
        onManualPick: () {
          Navigator.of(context).pop(); // 결과 시트 닫고
          _showManualPicker(); // 카테고리 선택 시트 열기
        },
      ),
    );
    // 시트가 닫혔는데 아직 페이지 이동을 안 했다면 다시 스캔 재개
    if (mounted && _busy) await _resume();
  }

  Future<void> _showManualBarcodeEntry() async {
    final controller = TextEditingController();
    final entered = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF15151B),
        title: const Text('바코드 직접 입력 (개발용)',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '예: 8801062636075',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4F8CFF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소',
                style: TextStyle(color: Colors.white60)),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('조회'),
          ),
        ],
      ),
    );
    if (entered == null || entered.isEmpty || !mounted) return;
    setState(() => _busy = true);
    final result = await lookupBarcode(entered);
    if (!mounted) return;
    await _showResultSheet(result);
  }

  void _showManualPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF15151B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _ManualPicker(onPick: _goCategory),
    ).whenComplete(() {
      if (mounted && _busy) _resume();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('바코드 스캔',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Container(
              color: Colors.black,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.no_photography,
                      color: Colors.white54, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    '카메라를 사용할 수 없어요.\n${error.errorDetails?.message ?? ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          // 가이드 프레임
          Center(
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2.5),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Column(
              children: [
                if (_busy)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  const Text(
                    '제품 바코드를 사각형 안에 맞춰주세요',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: _showManualPicker,
                  icon: const Icon(Icons.touch_app, color: Colors.white70),
                  label: const Text('직접 카테고리 선택',
                      style: TextStyle(color: Colors.white70)),
                ),
                if (kDebugMode)
                  TextButton.icon(
                    onPressed: _showManualBarcodeEntry,
                    icon: const Icon(Icons.keyboard,
                        color: Colors.white54),
                    label: const Text('바코드 직접 입력 (개발용)',
                        style: TextStyle(color: Colors.white54)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultSheet extends StatelessWidget {
  final BarcodeLookupResult result;
  final void Function(BarcodeCategory) onGoCategory;
  final VoidCallback onManualPick;

  const _ResultSheet({
    required this.result,
    required this.onGoCategory,
    required this.onManualPick,
  });

  @override
  Widget build(BuildContext context) {
    final p = result.product;
    final found = result.status == BarcodeLookupStatus.found && p != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (found && p != null)
              ..._foundChildren(p)
            else
              ..._notFoundChildren(),
          ],
        ),
      ),
    );
  }

  List<Widget> _foundChildren(BarcodeProduct p) {
    final cat = categoryForProduct(p);
    return [
      if (p.imageUrl.isNotEmpty) ...[
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              p.imageUrl,
              height: 96,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
      Text(p.productName,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(
        [
          if (p.company.isNotEmpty) p.company,
          if (p.classification.isNotEmpty) p.classification,
        ].join(' · '),
        style: const TextStyle(color: Colors.white60, fontSize: 13),
      ),
      const SizedBox(height: 4),
      Text('바코드 ${p.barcode}',
          style: const TextStyle(color: Colors.white30, fontSize: 12)),
      const SizedBox(height: 20),
      if (cat != BarcodeCategory.unknown)
        _PrimaryButton(
          label: '${categoryLabel(cat)} 비교 보러가기',
          onTap: () => onGoCategory(cat),
        )
      else
        const Text(
          '이 제품에 맞는 비교 카테고리를 자동으로 못 찾았어요.\n아래에서 직접 골라주세요.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      const SizedBox(height: 10),
      _SecondaryButton(label: '직접 카테고리 선택', onTap: onManualPick),
    ];
  }

  List<Widget> _notFoundChildren() {
    return [
      Row(
        children: const [
          Icon(Icons.search_off, color: Colors.white54),
          SizedBox(width: 8),
          Text('제품을 찾지 못했어요',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        _failMessage(result),
        style: const TextStyle(
            color: Colors.white60, fontSize: 13, height: 1.4),
      ),
      const SizedBox(height: 18),
      _PrimaryButton(label: '직접 카테고리 선택', onTap: onManualPick),
    ];
  }

  String _failMessage(BarcodeLookupResult r) {
    switch (r.status) {
      case BarcodeLookupStatus.missingKey:
        return r.message ?? 'API 키가 설정되지 않았습니다.';
      case BarcodeLookupStatus.networkError:
        return '네트워크 오류로 조회하지 못했어요. (${r.message ?? ''})\n'
            '직접 카테고리를 선택해 비교를 이어갈 수 있어요.';
      case BarcodeLookupStatus.notFound:
        return '공공 바코드 DB(2018년까지 등록분 위주)에 없는 제품이에요.\n'
            '직접 카테고리를 선택해 비교를 이어갈 수 있어요.';
      case BarcodeLookupStatus.found:
        return '';
    }
  }
}

class _ManualPicker extends StatelessWidget {
  final void Function(BarcodeCategory) onPick;
  const _ManualPicker({required this.onPick});

  @override
  Widget build(BuildContext context) {
    final items = <(String, String, BarcodeCategory)>[
      ('🥤', '음료', BarcodeCategory.beverage),
      ('🌶️', '맵기', BarcodeCategory.spiciness),
      ('🍚', '1인분', BarcodeCategory.portion),
      ('🍕', '피자', BarcodeCategory.pizza),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('어떤 비교를 볼까요?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            ...items.map((it) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(it.$1, style: const TextStyle(fontSize: 24)),
                  title: Text(it.$2,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.chevron_right,
                      color: Colors.white38),
                  onTap: () => onPick(it.$3),
                )),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF4F8CFF),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        child: Text(label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        child: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
