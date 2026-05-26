import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'piece_asset.dart';

enum CapturedSide { left, right }

class CapturedPiecesPanel extends StatelessWidget {
  final String title;
  final String hands;
  final bool black;
  final Color accent;

  // Compatibility fields used by newer game_page.dart.
  final String? sfen;
  final CapturedSide? side;

  const CapturedPiecesPanel({
    super.key,
    required this.title,
    required this.hands,
    required this.black,
    required this.accent,
    this.sfen,
    this.side,
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

    final pieces = <String>[];
    for (final piece in order) {
      final count = parsed[piece] ?? 0;
      for (int i = 0; i < count; i++) {
        pieces.add(piece);
      }
    }

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(10),
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
            decoration: BoxDecoration(
              color: accent.withOpacity(0.88),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerifJp(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: pieces.isEmpty
                ? const Center(
                    child: Text(
                      'なし',
                      style: TextStyle(color: Colors.white54, fontSize: 18),
                    ),
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final piece in pieces)
                          SizedBox(
                            width: 82,
                            height: 96,
                            child: PieceAsset(
                              piece: piece,
                              isWhite: !black,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
