import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'device_sim_data.dart';

const Color _accent = Color(0xFF34D399);

typedef SlotTapCallback = void Function(String slotId);

/// 슬롯 배지: 탭하면 해당 슬롯 부품 선택 시트를 연다. 채워지면 초록, 비면 회색.
class SlotBadge extends StatelessWidget {
  final DeviceSlot slot;
  final DevicePart? part;
  final VoidCallback onTap;
  const SlotBadge({super.key, required this.slot, required this.part, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final filled = part != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: filled ? _accent.withAlpha(45) : Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: filled ? _accent : Colors.white38),
        ),
        child: Text(
          '${slot.emoji} ${slot.label}',
          style: TextStyle(
            color: filled ? _accent : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// 완성(isComplete) 시 0→1을 계속 반복하는 공용 애니메이션 티커.
/// 팬 회전, RGB 순환, 화면 발광 등 모든 "작동하는 것처럼" 연출의 기반.
class PoweredOnTicker extends StatefulWidget {
  final bool active;
  final Widget Function(BuildContext context, double t) builder;
  const PoweredOnTicker({super.key, required this.active, required this.builder});

  @override
  State<PoweredOnTicker> createState() => _PoweredOnTickerState();
}

class _PoweredOnTickerState extends State<PoweredOnTicker> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(PoweredOnTicker old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => widget.builder(context, _c.value),
    );
  }
}

/// 0~1 진행값을 3색 순환 색상으로 변환 (RGB 테두리 펄스용).
Color rgbCycle(double t) {
  const colors = [Color(0xFF34D399), Color(0xFF60A5FA), Color(0xFFF472B6)];
  final seg = (t * colors.length) % colors.length;
  final i = seg.floor() % colors.length;
  final j = (i + 1) % colors.length;
  final localT = seg - i;
  return Color.lerp(colors[i], colors[j], localT)!;
}

/// 0~1 진행값을 은은한 발광 강도(0~1)로 변환 (화면/링 글로우용).
double glowPulse(double t) => 0.5 + 0.5 * math.sin(t * 2 * math.pi);

// ── 데스크탑 ──────────────────────────────────────────────────────

class DesktopShape extends StatelessWidget {
  final DeviceBuild device;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
  const DesktopShape({super.key, required this.device, required this.isComplete, required this.onSlotTap});

  DeviceSlot _slot(String id) => device.def.slots.firstWhere((s) => s.id == id);

  @override
  Widget build(BuildContext context) {
    return PoweredOnTicker(
      active: isComplete,
      builder: (context, t) {
        final rgb = isComplete ? rgbCycle(t) : Colors.white24;
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0F14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 10, right: 10, bottom: 56,
                child: Container(height: 4, color: const Color(0xFF3A2A1A)),
              ),
              Positioned(
                left: 38, bottom: 66,
                child: Column(
                  children: [
                    Container(
                      width: 120, height: 76,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF444444), width: 4),
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(0xFF000733),
                      ),
                    ),
                    Container(width: 14, height: 16, color: const Color(0xFF444444)),
                    Container(
                      width: 46, height: 5,
                      decoration: BoxDecoration(color: const Color(0xFF444444), borderRadius: BorderRadius.circular(3)),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 30, bottom: 20,
                child: CustomPaint(size: const Size(80, 40), painter: _PowerCablePainter(active: isComplete, t: t)),
              ),
              Positioned(
                right: 20, bottom: 14,
                child: Container(
                  width: 14, height: 18,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF666666), width: 2),
                    borderRadius: BorderRadius.circular(2),
                    color: const Color(0xFF222222),
                  ),
                ),
              ),
              Positioned(
                right: 36, bottom: 60,
                child: Container(
                  width: 58, height: 130,
                  decoration: BoxDecoration(
                    border: Border.all(color: rgb, width: 3),
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1A1C22), Color(0xFF0D0F14)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 15, top: 34,
                        child: Transform.rotate(
                          angle: isComplete ? t * 2 * math.pi : 0.0,
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white54, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 6, bottom: 6,
                        child: Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isComplete ? _accent : Colors.white24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(left: 20, top: 16, child: SlotBadge(slot: _slot('cpu'), part: device['cpu'], onTap: () => onSlotTap('cpu'))),
              Positioned(left: 20, top: 48, child: SlotBadge(slot: _slot('gpu'), part: device['gpu'], onTap: () => onSlotTap('gpu'))),
              Positioned(right: 20, top: 16, child: SlotBadge(slot: _slot('ram'), part: device['ram'], onTap: () => onSlotTap('ram'))),
              Positioned(right: 20, top: 48, child: SlotBadge(slot: _slot('storage'), part: device['storage'], onTap: () => onSlotTap('storage'))),
              Positioned(left: 20, top: 80, child: SlotBadge(slot: _slot('board'), part: device['board'], onTap: () => onSlotTap('board'))),
              Positioned(right: 20, top: 80, child: SlotBadge(slot: _slot('psu'), part: device['psu'], onTap: () => onSlotTap('psu'))),
            ],
          ),
        );
      },
    );
  }
}

/// 타워 뒤에서 콘센트로 이어지는 곡선 전원선. 완성 시 점선이 흐르는 것처럼 보이게 위상을 이동한다.
class _PowerCablePainter extends CustomPainter {
  final bool active;
  final double t;
  _PowerCablePainter({required this.active, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width - 10, 5)
      ..cubicTo(size.width - 40, 5, size.width - 50, size.height - 5, size.width - 75, size.height - 5);
    final paint = Paint()
      ..color = active ? _accent.withAlpha(180) : Colors.white38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(_dashPath(path, active ? t : 0), paint);
  }

  Path _dashPath(Path source, double phase) {
    final dashed = Path();
    const dashLen = 6.0;
    const gapLen = 4.0;
    for (final metric in source.computeMetrics()) {
      var distance = -phase * (dashLen + gapLen);
      while (distance < metric.length) {
        final start = distance < 0 ? 0.0 : distance;
        final end = (distance + dashLen) > metric.length ? metric.length : (distance + dashLen);
        if (end > start) {
          dashed.addPath(metric.extractPath(start, end), Offset.zero);
        }
        distance += dashLen + gapLen;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(covariant _PowerCablePainter old) => old.active != active || old.t != t;
}

// ── 노트북 ────────────────────────────────────────────────────────

class LaptopShape extends StatelessWidget {
  final DeviceBuild device;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
  const LaptopShape({super.key, required this.device, required this.isComplete, required this.onSlotTap});

  DeviceSlot _slot(String id) => device.def.slots.firstWhere((s) => s.id == id);

  @override
  Widget build(BuildContext context) {
    return PoweredOnTicker(
      active: isComplete,
      builder: (context, t) {
        final glowAlpha = isComplete ? (glowPulse(t) * 160).round() : 0;
        return Container(
          height: 260,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0F14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 220, height: 130,
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3A4048),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.circular(2)),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF20242A),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isComplete ? [BoxShadow(color: _accent.withAlpha(glowAlpha), blurRadius: 18)] : null,
                      ),
                    ),
                  ),
                  Container(
                    width: 250, height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC8CCD0),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                    ),
                  ),
                ],
              ),
              Positioned(left: 30, top: 30, child: SlotBadge(slot: _slot('cpu'), part: device['cpu'], onTap: () => onSlotTap('cpu'))),
              Positioned(right: 30, top: 30, child: SlotBadge(slot: _slot('gpu'), part: device['gpu'], onTap: () => onSlotTap('gpu'))),
              Positioned(left: 30, bottom: 40, child: SlotBadge(slot: _slot('ram'), part: device['ram'], onTap: () => onSlotTap('ram'))),
              Positioned(right: 30, bottom: 40, child: SlotBadge(slot: _slot('storage'), part: device['storage'], onTap: () => onSlotTap('storage'))),
              Positioned(bottom: 8, child: SlotBadge(slot: _slot('battery'), part: device['battery'], onTap: () => onSlotTap('battery'))),
            ],
          ),
        );
      },
    );
  }
}

// ── 폰 / 태블릿 (공유 몸체) ─────────────────────────────────────────

class _MobileBodyShape extends StatelessWidget {
  final DeviceBuild device;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
  final double bodyWidth;
  final double bodyHeight;
  const _MobileBodyShape({
    required this.device,
    required this.isComplete,
    required this.onSlotTap,
    required this.bodyWidth,
    required this.bodyHeight,
  });

  DeviceSlot _slot(String id) => device.def.slots.firstWhere((s) => s.id == id);

  @override
  Widget build(BuildContext context) {
    return PoweredOnTicker(
      active: isComplete,
      builder: (context, t) {
        final glowAlpha = isComplete ? (140 + glowPulse(t) * 100).round() : 0;
        return Container(
          height: 280,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0F14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: bodyWidth, height: bodyHeight,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF444444), width: 4),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF000733),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isComplete ? [BoxShadow(color: _accent.withAlpha(glowAlpha), blurRadius: 20)] : null,
                  ),
                ),
              ),
              Positioned(top: 24, child: SlotBadge(slot: _slot('chipset'), part: device['chipset'], onTap: () => onSlotTap('chipset'))),
              Positioned(left: 8, child: SlotBadge(slot: _slot('ram'), part: device['ram'], onTap: () => onSlotTap('ram'))),
              Positioned(right: 8, child: SlotBadge(slot: _slot('storage'), part: device['storage'], onTap: () => onSlotTap('storage'))),
              Positioned(bottom: 24, child: SlotBadge(slot: _slot('battery'), part: device['battery'], onTap: () => onSlotTap('battery'))),
            ],
          ),
        );
      },
    );
  }
}

class PhoneShape extends StatelessWidget {
  final DeviceBuild device;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
  const PhoneShape({super.key, required this.device, required this.isComplete, required this.onSlotTap});

  @override
  Widget build(BuildContext context) =>
      _MobileBodyShape(device: device, isComplete: isComplete, onSlotTap: onSlotTap, bodyWidth: 130, bodyHeight: 240);
}

class TabletShape extends StatelessWidget {
  final DeviceBuild device;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
  const TabletShape({super.key, required this.device, required this.isComplete, required this.onSlotTap});

  @override
  Widget build(BuildContext context) =>
      _MobileBodyShape(device: device, isComplete: isComplete, onSlotTap: onSlotTap, bodyWidth: 210, bodyHeight: 230);
}

// ── 워치 ──────────────────────────────────────────────────────────

class WatchShape extends StatelessWidget {
  final DeviceBuild device;
  final bool isComplete;
  final SlotTapCallback onSlotTap;
  const WatchShape({super.key, required this.device, required this.isComplete, required this.onSlotTap});

  DeviceSlot _slot(String id) => device.def.slots.firstWhere((s) => s.id == id);

  @override
  Widget build(BuildContext context) {
    return PoweredOnTicker(
      active: isComplete,
      builder: (context, t) {
        final glowAlpha = isComplete ? (glowPulse(t) * 220).round() : 0;
        return Container(
          height: 260,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0F14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 26, height: 150, color: const Color(0xFF2A2A2A)),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF000733),
                  border: Border.all(color: const Color(0xFF555555), width: 4),
                  boxShadow: isComplete ? [BoxShadow(color: _accent.withAlpha(glowAlpha), blurRadius: 22, spreadRadius: 2)] : null,
                ),
              ),
              Positioned(top: 40, child: SlotBadge(slot: _slot('chipset'), part: device['chipset'], onTap: () => onSlotTap('chipset'))),
              Positioned(bottom: 60, left: 60, child: SlotBadge(slot: _slot('battery'), part: device['battery'], onTap: () => onSlotTap('battery'))),
              Positioned(bottom: 60, right: 60, child: SlotBadge(slot: _slot('display'), part: device['display'], onTap: () => onSlotTap('display'))),
            ],
          ),
        );
      },
    );
  }
}

// ── 카테고리 -> 위젯 매핑 ────────────────────────────────────────────

/// 빌더 화면에서 쓰는 실사용 위젯 (탭 가능, isComplete로 연출 전환).
Widget deviceShapeFor(DeviceBuild build, bool isComplete, SlotTapCallback onSlotTap) {
  return switch (build.def.category) {
    DeviceCategory.desktop => DesktopShape(device: build, isComplete: isComplete, onSlotTap: onSlotTap),
    DeviceCategory.laptop => LaptopShape(device: build, isComplete: isComplete, onSlotTap: onSlotTap),
    DeviceCategory.phone => PhoneShape(device: build, isComplete: isComplete, onSlotTap: onSlotTap),
    DeviceCategory.tablet => TabletShape(device: build, isComplete: isComplete, onSlotTap: onSlotTap),
    DeviceCategory.watch => WatchShape(device: build, isComplete: isComplete, onSlotTap: onSlotTap),
  };
}

/// 진입 화면 카드용 미니 프리뷰 (탭 비활성, 항상 빈 상태).
Widget devicePreviewFor(DeviceCategoryDef def) {
  final dummyBuild = DeviceBuild(def);
  return IgnorePointer(
    child: FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 280,
        height: 300,
        child: deviceShapeFor(dummyBuild, false, (_) {}),
      ),
    ),
  );
}
