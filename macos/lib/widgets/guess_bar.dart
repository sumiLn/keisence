import 'dart:math';
import 'package:flutter/material.dart';

class GuessBar extends StatefulWidget {
  final bool enabled;
  final double percent;
  final double lift;
  final double? correctPercent;
  final void Function(double percent, double lift) onChanged;
  final VoidCallback onSubmit;

  const GuessBar({super.key, required this.enabled, required this.percent, required this.lift, required this.correctPercent, required this.onChanged, required this.onSubmit});

  @override
  State<GuessBar> createState() => _GuessBarState();
}

class _GuessBarState extends State<GuessBar> {
  double? lockedPercent;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Opacity(
      opacity: widget.enabled ? 1 : 0.45,
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth - 72;
        final x = 36 + width * (widget.percent.clamp(0.0, 100.0) / 100);
        final lifted = widget.lift < -55;
        final safeCorrect = widget.correctPercent?.clamp(0.0, 100.0);
        final correctX = safeCorrect == null ? null : 36 + width * (safeCorrect / 100);

        return GestureDetector(
          onPanUpdate: widget.enabled
              ? (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final local = box.globalToLocal(details.globalPosition);
                  final newLift = min(0.0, local.dy - 95);
                  final rawPercent = (((local.dx - 36) / width) * 100).clamp(0.0, 100.0);
                  if (newLift < -25 && lockedPercent == null) lockedPercent = widget.percent;
                  if (newLift > -12) lockedPercent = null;
                  widget.onChanged(lockedPercent ?? rawPercent, newLift);
                }
              : null,
          onPanEnd: widget.enabled
              ? (_) {
                  final shouldSubmit = lifted;
                  final fixedPercent = widget.percent;
                  lockedPercent = null;
                  if (shouldSubmit) {
                    widget.onChanged(fixedPercent, widget.lift);
                    widget.onSubmit();
                  } else {
                    widget.onChanged(fixedPercent, 0);
                  }
                }
              : null,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            height: isMobile ? 148 : 150,
            decoration: BoxDecoration(
              color: const Color(0xAA100C08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF9C7435), width: 1),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 64,
                  left: 36,
                  right: 36,
                  child: SizedBox(
                    height: 58,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          top: 9,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(colors: [Color(0xFFD73737), Colors.white, Color(0xFF1F6FD1)]),
                              boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black54)],
                            ),
                          ),
                        ),
                        for (int i = 0; i <= 10; i++)
                          Positioned(
                            left: width * (i / 10) - 1,
                            top: i == 5 ? 0 : 5,
                            child: Container(width: 2, height: i == 5 ? 28 : 18, color: Colors.black.withOpacity(i == 5 ? 0.65 : 0.42)),
                          ),
                        if (isMobile) ...[
                          const Positioned(left: 0, top: 34, child: Text('-3000', style: TextStyle(fontSize: 11))),
                          Positioned(left: width * 0.5 - 4, top: 34, child: const Text('0', style: TextStyle(fontSize: 11))),
                          const Positioned(right: 0, top: 34, child: Text('+3000', style: TextStyle(fontSize: 11))),
                        ] else ...[
                          const Positioned(left: 0, top: 34, child: Text('-3000〜', style: TextStyle(fontSize: 12))),
                          Positioned(left: width * (1 / 3) - 18, top: 34, child: const Text('-1000', style: TextStyle(fontSize: 12))),
                          Positioned(left: width * 0.5 - 4, top: 34, child: const Text('0', style: TextStyle(fontSize: 12))),
                          Positioned(left: width * (2 / 3) - 18, top: 34, child: const Text('+1000', style: TextStyle(fontSize: 12))),
                          const Positioned(right: 0, top: 34, child: Text('+3000〜', style: TextStyle(fontSize: 12))),
                        ],
                      ],
                    ),
                  ),
                ),
                if (correctX != null)
                  Positioned(
                    left: correctX - 3,
                    top: 40,
                    child: Container(
                      width: 6,
                      height: 58,
                      decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(99), boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.greenAccent)]),
                    ),
                  ),
                const Positioned(top: 122, left: 36, child: Text('相手有利')),
                const Positioned(top: 122, right: 36, child: Text('手番側有利')),
                Positioned(top: 8, child: Text('${widget.percent.round()}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
                Positioned(
                  left: x - 46,
                  top: 28 + widget.lift,
                  child: AnimatedScale(
                    scale: lifted ? 1.18 : 1,
                    duration: const Duration(milliseconds: 80),
                    child: SizedBox(width: 92, height: 101, child: Image.asset('assets/pieces/O.png', fit: BoxFit.contain)),
                  ),
                ),
                if (lifted) const Positioned(bottom: 4, child: Text('指を離して決定', style: TextStyle(color: Colors.amber, fontSize: 16))),
              ],
            ),
          ),
        );
      }),
    );
  }
}
