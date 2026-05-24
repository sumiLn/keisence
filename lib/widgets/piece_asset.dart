import 'dart:math';
import 'package:flutter/material.dart';

class PieceAsset extends StatelessWidget {
  final String piece;
  final bool isWhite;

  const PieceAsset({super.key, required this.piece, required this.isWhite});

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
    return Transform.rotate(
      angle: isWhite ? pi : 0,
      child: Image.asset(
        'assets/pieces/${assetName()}',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
