import 'dart:math';

String formatEval(int eval) => eval > 0 ? '+$eval' : '$eval';

/// 評価値は保存上は常に先手視点。
/// 画面上では常に「手番側視点」に変換して使う。
bool isWhiteTurn(String sideToMoveAfter) {
  final s = sideToMoveAfter.trim().toLowerCase();
  return s == 'white' || s == 'w' || s == '後手';
}

/// 評価値は保存上は常に先手視点。
/// 画面上では常に「手番側視点」に変換して使う。
int displayEvalForTurn({required int blackEvalCp, required String sideToMoveAfter}) {
  return isWhiteTurn(sideToMoveAfter) ? -blackEvalCp : blackEvalCp;
}

bool perspectiveBlackForTurn(String sideToMoveAfter) {
  return !isWhiteTurn(sideToMoveAfter);
}

double evalToPercent(int evalCp) {
  final clamped = evalCp.clamp(-3000, 3000).toDouble();
  return ((clamped + 3000.0) / 6000.0) * 100.0;
}

int percentToEval(double percent) {
  final p = percent.clamp(0.0, 100.0);
  return ((p / 100.0) * 6000.0 - 3000.0).round();
}

int damageFromDiff(double diffPercent) {
  if (diffPercent <= 2.0) return 0;
  if (diffPercent < 10.0) return 1;
  return min(20, (diffPercent ~/ 10) + 1);
}
