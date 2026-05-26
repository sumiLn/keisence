import 'dart:math';
import 'package:flutter/material.dart';

class PieceAsset extends StatelessWidget {
  final String piece;
  final bool isWhite;

  /// true: 先手側から見る / false: 後手側から見る
  final bool perspectiveBlack;

  const PieceAsset({
    super.key,
    required this.piece,
    required this.isWhite,
    this.perspectiveBlack = true,
  });

  String assetName() {
    final promoted = piece.startsWith('+');
    final raw = piece.replaceAll('+', '').toUpperCase();
    if (promoted) return 'P$raw.png';
    if (raw == 'K') return isWhite ? 'K.png' : 'O.png';
    return '$raw.png';
  }

  @override
  Widget build(BuildContext context) {
    if (piece.isEmpty) return const SizedBox.shrink();

    // 盤を手番側視点にするため、手前側の駒を正立させる。
    final rotate180 = isWhite == perspectiveBlack;

    return Transform.rotate(
      angle: rotate180 ? pi : 0,
      child: Image.asset(
        'assets/pieces/${assetName()}',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
