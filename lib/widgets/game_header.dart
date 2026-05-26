import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameHeader extends StatelessWidget {
  final int score;
  final int question;
  const GameHeader({super.key, required this.score, required this.question});

  Widget logo({double height = 94}) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const SizedBox(width: 100),
    );
  }

  Widget pawns({double size = 28}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Image.asset('assets/pieces/P.png', width: size, height: size * 1.2, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      height: isMobile ? 76 : 96,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 4 : 6),
      decoration: const BoxDecoration(
        color: Color(0xFFE8C77A),
        border: Border(bottom: BorderSide(color: Color(0xFFB8862D), width: 2)),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black54)],
      ),
      child: isMobile
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '第 $question 問',
                    style: GoogleFonts.notoSerifJp(color: Colors.black, fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'スコア $score',
                    style: GoogleFonts.notoSansJp(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                logo(),
                pawns(),
                logo(),
                pawns(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '第 $question 問',
                        style: GoogleFonts.notoSerifJp(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'スコア $score',
                        style: GoogleFonts.notoSansJp(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                pawns(),
                logo(),
                pawns(),
                logo(),
              ],
            ),
    );
  }
}
