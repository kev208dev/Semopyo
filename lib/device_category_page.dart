import 'package:flutter/material.dart';
import 'device_sim_data.dart';
import 'device_shapes.dart';
import 'device_builder_page.dart';

const Color _bg = Color(0xFF111111);

/// "전자기기 성능 비교" 진입 화면. 기기 종류 5개 중 하나를 고르면
/// 그 카테고리의 DeviceBuilderPage로 이동한다.
class DeviceCategoryPage extends StatelessWidget {
  const DeviceCategoryPage({super.key});

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
            Text('전자기기 성능 비교',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
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
                '기기 종류를 고르면\n부품을 배치하며 예상 성능을 비교할 수 있어요.',
                style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ 지금은 프레임 단계 — 샘플 부품·임시 계산식이에요.',
                style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [for (final def in allDeviceCategoryDefs) _categoryCard(context, def)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryCard(BuildContext context, DeviceCategoryDef def) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceBuilderPage(def: def))),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Expanded(child: devicePreviewFor(def)),
            const SizedBox(height: 8),
            Text('${def.emoji} ${def.label}',
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
