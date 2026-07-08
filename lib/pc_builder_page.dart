import 'package:flutter/material.dart';
import 'pc_builder_data.dart';

const Color _bg = Color(0xFF111111);
const Color _accent = Color(0xFF34D399);

/// PC 부품 조합 → 성능 예측 시뮬레이션 페이지 (프레임).
/// 견적 A/B 두 개를 만들어 비교할 수 있다.
class PcBuilderPage extends StatefulWidget {
  const PcBuilderPage({super.key});

  @override
  State<PcBuilderPage> createState() => _PcBuilderPageState();
}

class _PcBuilderPageState extends State<PcBuilderPage> {
  final _builds = [PcBuild(), PcBuild()];
  int _active = 0; // 0 = 견적 A, 1 = 견적 B

  PcBuild get _build => _builds[_active];

  @override
  Widget build(BuildContext context) {
    final result = simulate(_build);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Row(
          children: const [
            Text('PC 성능 시뮬',
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
                '부품을 골라 견적을 짜면\n예상 성능을 계산하고 두 견적을 비교해드려요.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ 지금은 프레임 단계 — 샘플 부품·임시 계산식이에요.',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              _buildTabs(),
              const SizedBox(height: 16),
              _slotList(),
              const SizedBox(height: 24),
              const Text('예상 성능',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _resultCard(result),
              const SizedBox(height: 24),
              const Text('견적 비교',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _compareCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ── 견적 A/B 토글 ──────────────────────────────────────────────

  Widget _buildTabs() {
    return Row(
      children: [
        for (var i = 0; i < _builds.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _tabButton(i)),
        ],
      ],
    );
  }

  Widget _tabButton(int i) {
    final selected = i == _active;
    final label = i == 0 ? '견적 A' : '견적 B';
    return GestureDetector(
      onTap: () => setState(() => _active = i),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _accent : Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? _accent : Colors.white24),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    color: selected ? Colors.black : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text('${_builds[i].pickedCount}/${PcPartType.values.length} 선택',
                style: TextStyle(
                    color: selected ? Colors.black54 : Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ── 부품 슬롯 ─────────────────────────────────────────────────

  Widget _slotList() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          for (final t in PcPartType.values) _slotRow(t),
        ],
      ),
    );
  }

  Widget _slotRow(PcPartType t) {
    final part = _build[t];
    return InkWell(
      onTap: () => _openPicker(t),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        child: Row(
          children: [
            Text(t.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            SizedBox(
              width: 76,
              child: Text(t.label,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: Text(
                part?.name ?? '부품 선택',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: part != null ? Colors.white : Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              part != null ? Icons.check_circle : Icons.add_circle_outline,
              color: part != null ? _accent : Colors.white38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker(PcPartType t) async {
    final picked = await showModalBottomSheet<_PickResult>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PartPickerSheet(type: t, current: _build[t]),
    );
    if (picked == null) return;
    setState(() => _build[t] = picked.part);
  }

  // ── 예상 성능 카드 ─────────────────────────────────────────────

  Widget _resultCard(SimResult r) {
    if (_build.isEmpty) {
      return _emptyCard('부품을 선택하면 예상 성능이 여기 표시돼요.');
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _scoreBar('게임 성능', r.gamingScore, _accent),
          const SizedBox(height: 12),
          _scoreBar('작업 성능', r.workScore, const Color(0xFF60A5FA)),
          const SizedBox(height: 16),
          Row(
            children: [
              _statChip(Icons.bolt, '예상 전력', '${r.totalWatt}W'),
              const SizedBox(width: 8),
              _statChip(Icons.payments_outlined, '예상 가격',
                  '${_formatWon(r.totalPrice)}원'),
            ],
          ),
          if (r.bottleneck != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade700),
              ),
              child: Text('⚠️ ${r.bottleneck}',
                  style: TextStyle(
                      color: Colors.orange.shade300,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          ],
          if (!_build.isComplete) ...[
            const SizedBox(height: 10),
            Text(
              '아직 ${PcPartType.values.length - _build.pickedCount}개 슬롯이 비어 있어요. 채울수록 정확해져요.',
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _scoreBar(String label, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('$score',
                style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900)),
            const Text(' /100',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                  Text(value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 견적 A vs B 비교 ──────────────────────────────────────────

  Widget _compareCard() {
    final a = simulate(_builds[0]);
    final b = simulate(_builds[1]);
    if (_builds[0].isEmpty || _builds[1].isEmpty) {
      return _emptyCard('견적 A와 B 둘 다 부품을 담으면 비교해드려요.');
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          _compareRow('게임 성능', '${a.gamingScore}', '${b.gamingScore}',
              higherWins: true,
              aVal: a.gamingScore.toDouble(),
              bVal: b.gamingScore.toDouble()),
          const Divider(color: Colors.white12, height: 20),
          _compareRow('작업 성능', '${a.workScore}', '${b.workScore}',
              higherWins: true,
              aVal: a.workScore.toDouble(),
              bVal: b.workScore.toDouble()),
          const Divider(color: Colors.white12, height: 20),
          _compareRow('예상 전력', '${a.totalWatt}W', '${b.totalWatt}W',
              higherWins: false,
              aVal: a.totalWatt.toDouble(),
              bVal: b.totalWatt.toDouble()),
          const Divider(color: Colors.white12, height: 20),
          _compareRow('예상 가격', '${_formatWon(a.totalPrice)}원',
              '${_formatWon(b.totalPrice)}원',
              higherWins: false,
              aVal: a.totalPrice.toDouble(),
              bVal: b.totalPrice.toDouble()),
        ],
      ),
    );
  }

  Widget _compareRow(String label, String aText, String bText,
      {required bool higherWins,
      required double aVal,
      required double bVal}) {
    final aWins = higherWins ? aVal > bVal : aVal < bVal;
    final bWins = higherWins ? bVal > aVal : bVal < aVal;
    TextStyle style(bool wins) => TextStyle(
          color: wins ? _accent : Colors.white70,
          fontSize: 14,
          fontWeight: wins ? FontWeight.w900 : FontWeight.w700,
        );
    return Row(
      children: [
        Expanded(
            child: Text(aText,
                textAlign: TextAlign.left, style: style(aWins))),
        SizedBox(
          width: 90,
          child: Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
        Expanded(
            child: Text(bText,
                textAlign: TextAlign.right, style: style(bWins))),
      ],
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white38,
            fontSize: 13,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  static String _formatWon(int won) {
    final s = won.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

/// 바텀시트 선택 결과. part == null 이면 '선택 해제'.
class _PickResult {
  final PcPart? part;
  const _PickResult(this.part);
}

class _PartPickerSheet extends StatelessWidget {
  final PcPartType type;
  final PcPart? current;
  const _PartPickerSheet({required this.type, this.current});

  @override
  Widget build(BuildContext context) {
    final parts = partsOf(type);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(type.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text('${type.label} 선택',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 14),
            for (final p in parts) _partTile(context, p),
            if (current != null) ...[
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pop(context, const _PickResult(null)),
                  child: const Text('선택 해제',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _partTile(BuildContext context, PcPart p) {
    final selected = p.id == current?.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.pop(context, _PickResult(p)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? _accent.withAlpha(30)
                : Colors.white.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? _accent : Colors.white24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      '성능 ${p.perfScore} · ${p.watt}W · ${_PcBuilderPageState._formatWon(p.price)}원',
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: _accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
