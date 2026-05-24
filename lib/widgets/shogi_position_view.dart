import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/sfen.dart';
import 'shogi_board.dart';
import 'side_hand_column.dart';

class ShogiPositionView extends StatelessWidget {
  final String sfen;
  final String beforeSfen;
  final String moveUsi;
  final bool animate;
  final bool overTime;
  final VoidCallback? onFinalMove;
  final VoidCallback? onReady;

  const ShogiPositionView({
    super.key,
    required this.sfen,
    required this.beforeSfen,
    required this.moveUsi,
    this.animate = true,
    this.overTime = false,
    this.onFinalMove,
    this.onReady,
  });

  const ShogiPositionView.staticView({
    super.key,
    required this.sfen,
    required this.moveUsi,
  })  : beforeSfen = '',
        animate = false,
        overTime = false,
        onFinalMove = null,
        onReady = null;

  @override
  Widget build(BuildContext context) {
    final hands = parseSfen(sfen).hands;
    return LayoutBuilder(builder: (context, constraints) {
      final maxW = constraints.maxWidth;
      final maxH = constraints.maxHeight;
      final boardSize = min(maxH, maxW / 1.32);
      final cellSize = boardSize / 10.0;
      final pieceWidth = cellSize * 1.18;
      final pieceHeight = cellSize * 1.32;
      final sideGap = max(4.0, cellSize * 0.08);

      final board = animate
          ? ShogiBoardGlow(
              overTime: overTime,
              child: ShogiBoardView(
                beforeSfen: beforeSfen,
                afterSfen: sfen,
                moveUsi: moveUsi,
                animate: true,
                onFinalMove: onFinalMove,
                onReady: onReady,
              ),
            )
          : StaticBoardView(sfen: sfen, moveUsi: moveUsi);

      return Center(
        child: SizedBox(
          width: boardSize + pieceWidth * 2.5 + sideGap * 2,
          height: boardSize,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SideHandColumn(
                hands: hands,
                black: false,
                pieceWidth: pieceWidth,
                pieceHeight: pieceHeight,
                boardSize: boardSize,
              ),
              SizedBox(width: sideGap),
              SizedBox(width: boardSize, height: boardSize, child: board),
              SizedBox(width: sideGap),
              SideHandColumn(
                hands: hands,
                black: true,
                pieceWidth: pieceWidth,
                pieceHeight: pieceHeight,
                boardSize: boardSize,
              ),
            ],
          ),
        ),
      );
    });
  }
}
