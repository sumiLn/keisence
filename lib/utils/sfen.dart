class ParsedSfen {
  final List<String> board;
  final String turn;
  final String hands;

  const ParsedSfen({required this.board, required this.turn, required this.hands});
}

ParsedSfen parseSfen(String sfen) {
  final parts = sfen.split(' ');
  final rows = parts.first.split('/');
  final cells = <String>[];

  for (final row in rows) {
    bool promoted = false;
    for (int i = 0; i < row.length; i++) {
      final ch = row[i];
      if (ch == '+') {
        promoted = true;
        continue;
      }
      final empty = int.tryParse(ch);
      if (empty != null) {
        for (int j = 0; j < empty; j++) cells.add('');
      } else {
        cells.add(promoted ? '+$ch' : ch);
        promoted = false;
      }
    }
  }

  while (cells.length < 81) cells.add('');

  return ParsedSfen(
    board: cells.take(81).toList(),
    turn: parts.length > 1 ? parts[1] : 'b',
    hands: parts.length > 2 ? parts[2] : '-',
  );
}

int? usiSquareToIndex(String sq) {
  if (sq.length != 2) return null;
  final file = int.tryParse(sq[0]);
  final rank = 'abcdefghi'.indexOf(sq[1]);
  if (file == null || rank < 0) return null;
  return rank * 9 + (9 - file);
}

int? moveToIndex(String move) {
  if (move.contains('*') && move.length >= 4) return usiSquareToIndex(move.substring(2, 4));
  if (move.length >= 4) return usiSquareToIndex(move.substring(2, 4));
  return null;
}

Map<String, int> parseHandsForSide(String hands, {required bool black}) {
  final result = <String, int>{};
  if (hands == '-') return result;
  int countBuffer = 0;
  for (int i = 0; i < hands.length; i++) {
    final ch = hands[i];
    final digit = int.tryParse(ch);
    if (digit != null) {
      countBuffer = countBuffer * 10 + digit;
      continue;
    }
    final isBlackPiece = ch == ch.toUpperCase();
    if (isBlackPiece == black) {
      final key = ch.toUpperCase();
      result[key] = (result[key] ?? 0) + (countBuffer == 0 ? 1 : countBuffer);
    }
    countBuffer = 0;
  }
  return result;
}
