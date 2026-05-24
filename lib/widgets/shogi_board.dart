import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/sfen.dart';
import 'piece_asset.dart';
import 'piece_asset.dart';

class ShogiBoardGlow extends StatefulWidget {
  final bool overTime;
  final Widget child;
  const ShogiBoardGlow({super.key, required this.overTime, required this.child});

  @override
  State<ShogiBoardGlow> createState() => _ShogiBoardGlowState();
}

class _ShogiBoardGlowState extends State<ShogiBoardGlow> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final color = widget.overTime ? const Color(0xFF8B1E1E) : Colors.cyanAccent;
        final power = widget.overTime ? (0.35 + controller.value * 0.35) : 0.28;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: color.withOpacity(power), blurRadius: widget.overTime ? 38 : 28, spreadRadius: widget.overTime ? 10 : 7),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class ShogiBoardView extends StatefulWidget {
  final String beforeSfen;
  final String afterSfen;
  final String moveUsi;
  final VoidCallback? onFinalMove;
  final VoidCallback? onReady;
  final bool animate;

  const ShogiBoardView({
    super.key,
    required this.beforeSfen,
    required this.afterSfen,
    required this.moveUsi,
    this.onFinalMove,
    this.onReady,
    this.animate = true,
  });

  @override
  State<ShogiBoardView> createState() => _ShogiBoardViewState();
}

class _ShogiBoardViewState extends State<ShogiBoardView> {
  int revealedCount = 0;
  bool showAfter = false;
  bool impact = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  void didUpdateWidget(covariant ShogiBoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.afterSfen != widget.afterSfen) startAnimation();
  }

  void startAnimation() {
    timer?.cancel();
    if (!widget.animate) {
      setState(() {
        revealedCount = 81;
        showAfter = true;
        impact = false;
      });
      return;
    }
    revealedCount = 0;
    showAfter = false;
    impact = false;
    timer = Timer.periodic(const Duration(milliseconds: 7), (t) {
      if (!mounted) return;
      setState(() => revealedCount += 6);
      if (revealedCount >= 81) {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 380), () {
          if (!mounted) return;
          setState(() { showAfter = true; impact = true; });
          widget.onFinalMove?.call();
          Future.delayed(const Duration(milliseconds: 260), () {
            if (!mounted) return;
            setState(() => impact = false);
            Future.delayed(const Duration(milliseconds: 180), () {
              if (mounted) widget.onReady?.call();
            });
          });
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BoardCore(
      sfen: showAfter ? widget.afterSfen : widget.beforeSfen,
      revealedCount: revealedCount,
      highlightIndex: showAfter ? moveToIndex(widget.moveUsi) : null,
      impact: impact,
      animatePieces: true,
    );
  }
}

class StaticBoardView extends StatelessWidget {
  final String sfen;
  final String moveUsi;
  const StaticBoardView({super.key, required this.sfen, required this.moveUsi});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: BoardCore(
        sfen: sfen,
        revealedCount: 81,
        highlightIndex: moveToIndex(moveUsi),
        impact: false,
        animatePieces: false,
      ),
    );
  }
}

class BoardCore extends StatelessWidget {
  final String sfen;
  final int revealedCount;
  final int? highlightIndex;
  final bool impact;
  final bool animatePieces;

  const BoardCore({
    super.key,
    required this.sfen,
    required this.revealedCount,
    required this.highlightIndex,
    required this.impact,
    required this.animatePieces,
  });

  bool isWhitePiece(String p) {
    if (p.isEmpty) return false;
    final raw = p.replaceAll('+', '');
    return raw == raw.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final parsed = parseSfen(sfen);
    final cells = parsed.board;
    return LayoutBuilder(builder: (context, constraints) {
      final boardSize = min(constraints.maxWidth, constraints.maxHeight);
      final cellSize = boardSize / 10.0;
      final gridLeft = cellSize * 0.5;
      final gridTop = cellSize * 0.5;
      final pieceWidth = cellSize * 1.18;
      final pieceHeight = cellSize * 1.32;

      return AnimatedSlide(
        offset: impact ? const Offset(0.012, -0.006) : Offset.zero,
        duration: const Duration(milliseconds: 80),
        child: SizedBox(
          width: boardSize,
          height: boardSize,
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(image: AssetImage('assets/images/board.png'), fit: BoxFit.contain),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black87)],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (int index = 0; index < 81; index++)
                  _PositionedPiece(
                    index: index,
                    gridLeft: gridLeft,
                    gridTop: gridTop,
                    cellSize: cellSize,
                    pieceWidth: pieceWidth,
                    pieceHeight: pieceHeight,
                    visible: index < revealedCount,
                    piece: cells[index],
                    isWhite: isWhitePiece(cells[index]),
                    highlighted: index == highlightIndex,
                    impact: impact,
                    animatePieces: animatePieces,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _PositionedPiece extends StatelessWidget {
  final int index;
  final double gridLeft;
  final double gridTop;
  final double cellSize;
  final double pieceWidth;
  final double pieceHeight;
  final bool visible;
  final String piece;
  final bool isWhite;
  final bool highlighted;
  final bool impact;
  final bool animatePieces;

  const _PositionedPiece({
    required this.index,
    required this.gridLeft,
    required this.gridTop,
    required this.cellSize,
    required this.pieceWidth,
    required this.pieceHeight,
    required this.visible,
    required this.piece,
    required this.isWhite,
    required this.highlighted,
    required this.impact,
    required this.animatePieces,
  });

  @override
  Widget build(BuildContext context) {
    final row = index ~/ 9;
    final col = index % 9;
    final centerX = gridLeft + col * cellSize + cellSize / 2;
    final centerY = gridTop + row * cellSize + cellSize / 2;
    final show = visible && piece.isNotEmpty;
    return Positioned(
      left: centerX - pieceWidth / 2,
      top: centerY - pieceHeight / 2,
      width: pieceWidth,
      height: pieceHeight,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (highlighted)
            Container(
              width: cellSize * 1.04,
              height: cellSize * 1.04,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.34),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(blurRadius: 18, color: Colors.amber)],
              ),
            ),
          AnimatedScale(
            scale: show ? (highlighted && impact ? 1.62 : 1.0) : 0.6,
            duration: animatePieces ? const Duration(milliseconds: 220) : Duration.zero,
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: show ? 1 : 0,
              duration: animatePieces ? const Duration(milliseconds: 140) : Duration.zero,
              child: PieceAsset(piece: piece, isWhite: isWhite),
            ),
          ),
        ],
      ),
    );
  }
}
