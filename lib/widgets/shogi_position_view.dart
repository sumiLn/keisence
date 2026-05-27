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
  final bool perspectiveBlack;
  final VoidCallback? onFinalMove;
  final VoidCallback? onReady;

  const ShogiPositionView({
    super.key,
    required this.sfen,
    required this.beforeSfen,
    required this.moveUsi,
    this.animate = true,
    this.overTime = false,
    this.perspectiveBlack = true,
    this.onFinalMove,
    this.onReady,
  });

  const ShogiPositionView.staticView({
    super.key,
    required this.sfen,
    required this.moveUsi,
    this.perspectiveBlack = true,
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
      final boardSize = min(maxH, maxW / 1.30);
      final cellSize = boardSize / 10.0;
      final pieceWidth = cellSize * 1.18;
      final pieceHeight = cellSize * 1.32;
      final sideGap = max(2.0, cellSize * 0.05);

      final board = animate
          ? ShogiBoardGlow(
              overTime: overTime,
              child: ShogiBoardView(
                beforeSfen: beforeSfen,
                afterSfen: sfen,
                moveUsi: moveUsi,
                animate: true,
                perspectiveBlack: perspectiveBlack,
                onFinalMove: onFinalMove,
                onReady: onReady,
              ),
            )
          : StaticBoardView(
              sfen: sfen,
              moveUsi: moveUsi,
              perspectiveBlack: perspectiveBlack,
            );

      // 常に右側が手番側、左側が相手側。
      final leftIsBlack = !perspectiveBlack;
      final rightIsBlack = perspectiveBlack;

      return Center(
        child: SizedBox(
          width: boardSize + pieceWidth * 2.36 + sideGap * 2,
          height: boardSize,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SideHandColumn(
                hands: hands,
                black: leftIsBlack,
                perspectiveBlack: perspectiveBlack,
                isRightSide: false,
                pieceWidth: pieceWidth,
                pieceHeight: pieceHeight,
                boardSize: boardSize,
              ),
              SizedBox(width: sideGap),
              SizedBox(width: boardSize, height: boardSize, child: board),
              SizedBox(width: sideGap),
              SideHandColumn(
                hands: hands,
                black: rightIsBlack,
                perspectiveBlack: perspectiveBlack,
                isRightSide: true,
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
