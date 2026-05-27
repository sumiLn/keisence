import 'dart:math';
import 'package:flutter/material.dart';

class PieceAsset extends StatelessWidget {
  final String piece;
  final bool isWhite;
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

    final angle = (isWhite == perspectiveBlack) ? pi : 0.0;

    return Transform.rotate(
      angle: angle,
      child: Image.asset(
        'assets/pieces/${assetName()}',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
