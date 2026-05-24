import 'dart:math';

String formatEval(int eval) => eval > 0 ? '+$eval' : '$eval';

double evalToPercent(int evalCp) {
  final clamped = evalCp.clamp(-3000, 3000).toDouble();
  return ((clamped + 3000.0) / 6000.0) * 100.0;
}

int percentToEval(double percent) {
  return (((percent - 50.0) / 50.0) * 3000.0).round();
}

int damageFromDiff(double diffPercent) {
  if (diffPercent <= 2.0) return 0;
  if (diffPercent < 10.0) return 1;
  return min(20, (diffPercent ~/ 10) + 1);
}
