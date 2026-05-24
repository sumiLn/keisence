import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'piece_asset.dart';

class CapturedPiecesPanel extends StatelessWidget {
  final String title;
  final String hands;
  final bool black;
  final Color accent;

  const CapturedPiecesPanel({
    super.key,
    required this.title,
    required this.hands,
    required this.black,
    required this.accent,
  });

  Map<String, int> parseHandsForSide() {
    final result = <String, int>{};
    if (hands == '-') return result;
    int countBuffer = 0;
    for (int i = 0; i < hands.length; i++) {
      final ch = hands[i];
      final digit = int.tryParse(ch);
      if (digit != null) {
        countBuffer = countBuffer * 10 + digit;
        continue;
      }
      final isBlackPiece = ch == ch.toUpperCase();
      if (isBlackPiece == black) {
        final key = ch.toUpperCase();
        result[key] = (result[key] ?? 0) + (countBuffer == 0 ? 1 : countBuffer);
      }
      countBuffer = 0;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final parsed = parseHandsForSide();
    const order = ['R', 'B', 'G', 'S', 'N', 'L', 'P'];
    final pieceWidgets = <Widget>[
      for (final piece in order)
        if (parsed[piece] != null)
          for (int i = 0; i < parsed[piece]!; i++)
            SizedBox(width: 92, height: 104, child: PieceAsset(piece: piece, isWhite: !black)),
    ];

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12100E).withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF9C7435), width: 1.3),
        boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black54)],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: accent.withOpacity(0.88), borderRadius: BorderRadius.circular(8)),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerifJp(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: parsed.isEmpty
                ? const Center(child: Text('なし', style: TextStyle(color: Colors.white54, fontSize: 18)))
                : Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: 276,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 0,
                          runSpacing: 2,
                          children: pieceWidgets,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
