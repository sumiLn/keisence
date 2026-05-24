import 'package:flutter/material.dart';
import '../utils/sfen.dart';
import 'piece_asset.dart';

class SideHandColumn extends StatelessWidget {
  final String hands;
  final bool black;
  final double pieceWidth;
  final double pieceHeight;
  final double boardSize;

  const SideHandColumn({
    super.key,
    required this.hands,
    required this.black,
    required this.pieceWidth,
    required this.pieceHeight,
    required this.boardSize,
  });

  @override
  Widget build(BuildContext context) {
    final parsed = parseHandsForSide(hands, black: black);
    const order = ['R', 'B', 'G', 'S', 'N', 'L', 'P'];
    final pieces = <String>[];
    for (final p in order) {
      final n = parsed[p] ?? 0;
      for (int i = 0; i < n; i++) pieces.add(p);
    }

    return SizedBox(
      width: pieceWidth * 1.25,
      height: boardSize,
      child: pieces.isEmpty
          ? const SizedBox.shrink()
          : FittedBox(
              fit: BoxFit.scaleDown,
              alignment: black ? Alignment.bottomCenter : Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final p in pieces)
                    SizedBox(
                      width: pieceWidth,
                      height: pieceHeight,
                      child: PieceAsset(piece: p, isWhite: !black),
                    ),
                ],
              ),
            ),
    );
  }
}
