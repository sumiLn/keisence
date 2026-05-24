import 'question_data.dart';

class PlayRecord {
  final QuestionData question;
  final int predictedEval;
  final int correctEval;
  final double diffPercent;
  final int damage;
  final int heal;
  final bool perfect;
  final bool critical;

  const PlayRecord({
    required this.question,
    required this.predictedEval,
    required this.correctEval,
    required this.diffPercent,
    required this.damage,
    required this.heal,
    required this.perfect,
    required this.critical,
  });
}
