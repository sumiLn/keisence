import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimerView extends StatelessWidget {
  final int remainingTenths;
  final bool overTime;
  final int overtimeSeconds;

  const TimerView({super.key, required this.remainingTenths, required this.overTime, required this.overtimeSeconds});

  @override
  Widget build(BuildContext context) {
    final seconds = max(0, remainingTenths) / 10.0;
    final danger = seconds <= 3.0 || overTime;
    return Text(
      overTime ? 'OVER +$overtimeSeconds' : '${seconds.toStringAsFixed(1)}s',
      style: GoogleFonts.notoSansJp(color: danger ? Colors.redAccent : Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
    );
  }
}
