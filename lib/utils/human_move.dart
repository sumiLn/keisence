import '../models/play_record.dart';
import 'sfen.dart';

String humanMove(PlayRecord r) {
  final usi = r.question.bestMove;
  if (usi.isEmpty) return '不明';

  const nums = {'1': '１', '2': '２', '3': '３', '4': '４', '5': '５', '6': '６', '7': '７', '8': '８', '9': '９'};
  const ranks = {'a': '一', 'b': '二', 'c': '三', 'd': '四', 'e': '五', 'f': '六', 'g': '七', 'h': '八', 'i': '九'};
  const pieces = {'P': '歩', 'L': '香', 'N': '桂', 'S': '銀', 'G': '金', 'B': '角', 'R': '飛', 'K': '玉'};

  final black = r.question.sideToMoveAfter == 'black';
  final mark = black ? '▲' : '△';

  if (usi.contains('*') && usi.length >= 4) {
    final p = usi[0];
    final to = usi.substring(2, 4);
    return '$mark${nums[to[0]] ?? to[0]}${ranks[to[1]] ?? to[1]}${pieces[p] ?? p}打';
  }

  if (usi.length >= 4) {
    final from = usi.substring(0, 2);
    final to = usi.substring(2, 4);
    final parsed = parseSfen(r.question.sfen);
    final fromIndex = usiSquareToIndex(from);
    String pieceName = '';
    if (fromIndex != null && fromIndex >= 0 && fromIndex < 81) {
      final p = parsed.board[fromIndex].replaceAll('+', '').toUpperCase();
      pieceName = pieces[p] ?? '';
    }
    final promote = usi.endsWith('+') ? '成' : '';
    return '$mark${nums[to[0]] ?? to[0]}${ranks[to[1]] ?? to[1]}$pieceName$promote';
  }

  return usi;
}
