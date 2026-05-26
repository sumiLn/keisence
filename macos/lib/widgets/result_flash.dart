import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/eval_utils.dart';

class ResultFlash extends StatelessWidget {
  final int predictedEval;
  final int correctEval;
  final double diffPercent;
  final int damage;
  final int heal;
  final bool perfect;
  final bool critical;

  const ResultFlash({super.key, required this.predictedEval, required this.correctEval, required this.diffPercent, required this.damage, required this.heal, required this.perfect, required this.critical});

  @override
  Widget build(BuildContext context) {
    final title = perfect ? '完全正解' : critical ? '会心' : '結果';
    final titleColor = perfect ? Colors.lightGreenAccent : critical ? Colors.cyanAccent : Colors.amber;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 180),
      builder: (context, value, child) => Transform.scale(scale: value, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xEE120D09),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: titleColor, width: 2),
          boxShadow: const [BoxShadow(blurRadius: 24, color: Colors.black87)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: GoogleFonts.notoSerifJp(color: titleColor, fontSize: 34, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('予測 ${formatEval(predictedEval)}', style: const TextStyle(fontSize: 24)),
            Text('正解 ${formatEval(correctEval)}', style: const TextStyle(fontSize: 24, color: Colors.greenAccent)),
            Text('誤差 ${diffPercent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            if (heal > 0)
              Text('+$heal 命駒', style: const TextStyle(color: Colors.lightGreenAccent, fontSize: 34, fontWeight: FontWeight.bold))
            else if (damage == 0)
              const Text('ノーダメージ', style: TextStyle(color: Colors.cyanAccent, fontSize: 32, fontWeight: FontWeight.bold))
            else
              Text('-$damage 命駒', style: const TextStyle(color: Colors.redAccent, fontSize: 34, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
