import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameHeader extends StatelessWidget {
  final int score;
  final int question;
  const GameHeader({super.key, required this.score, required this.question});

  Widget logo() => Image.asset('assets/images/logo.png', height: 94, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox(width: 120));

  Widget pawns() => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (_) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Image.asset('assets/pieces/P.png', width: 28, height: 34))),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFFE8C77A),
        border: Border(bottom: BorderSide(color: Color(0xFFB8862D), width: 2)),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black54)],
      ),
      child: Row(
        children: [
          logo(), pawns(), logo(), pawns(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('第 $question 問', style: GoogleFonts.notoSerifJp(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w900)),
                Text('スコア $score', style: GoogleFonts.notoSansJp(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          pawns(), logo(), pawns(), logo(),
        ],
      ),
    );
  }
}
