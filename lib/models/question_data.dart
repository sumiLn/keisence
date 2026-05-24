class QuestionData {
  final String id;
  final String sfen;
  final String beforeSfen;
  final String moveUsi;
  final String bestMove;
  final int evalCp;
  final double winRateBlack;
  final String sideToMoveAfter;

  const QuestionData({
    required this.id,
    required this.sfen,
    required this.beforeSfen,
    required this.moveUsi,
    required this.bestMove,
    required this.evalCp,
    required this.winRateBlack,
    required this.sideToMoveAfter,
  });

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      id: json['id'] ?? '',
      sfen: json['sfen'] ?? '',
      beforeSfen: json['before_sfen'] ?? json['sfen'] ?? '',
      moveUsi: json['move_usi'] ?? '',
      bestMove: json['best_move'] ?? '',
      evalCp: json['eval_cp'] ?? 0,
      winRateBlack: (json['win_rate_black'] as num?)?.toDouble() ?? 0.5,
      sideToMoveAfter: json['side_to_move_after'] ?? '',
    );
  }

  String get hands {
    final parts = sfen.split(' ');
    return parts.length > 2 ? parts[2] : '-';
  }
}
