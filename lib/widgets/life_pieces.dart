import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LifePieces extends StatelessWidget {
  final int lives;
  final int previousLives;

  const LifePieces({super.key, required this.lives, required this.previousLives});

  static const List<String> lifeOrder = [
    'O',
    'R',
    'B',
    'G',
    'G',
    'S',
    'S',
    'N',
    'N',
    'L',
    'L',
    'P',
    'P',
    'P',
    'P',
    'P',
    'P',
    'P',
    'P',
    'P',
  ];

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxLives, (i) {
          final alive = i < max(0, lives);
          final wasAlive = i < max(0, previousLives);
          final justLost = wasAlive && !alive;
          final justHealed = !wasAlive && alive;
          return AnimatedScale(
            scale: justLost ? 0.2 : justHealed ? 1.25 : 1.0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: alive ? 1 : 0.14,
              duration: const Duration(milliseconds: 260),
              child: SizedBox(
                width: 64,
                height: 76,
                child: Image.asset('assets/pieces/${lifeOrder[i]}.png', fit: BoxFit.contain),
              ),
            ),
          );
        }),
      ),
    );
  }
}
