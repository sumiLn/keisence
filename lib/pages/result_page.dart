import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/play_record.dart';
import '../services/sound.dart';
import '../utils/eval_utils.dart';
import '../utils/sfen.dart';
import '../widgets/shogi_position_view.dart';
import 'game_page.dart';
import 'title_page.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final int bestScore;
  final int questionCount;
  final List<PlayRecord> records;

  const ResultPage({super.key, required this.score, required this.bestScore, required this.questionCount, required this.records});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final AudioPlayer bgm = AudioPlayer();
  final AudioPlayer se = AudioPlayer();

  late PageController pageController;
  int selected = 0;
  bool fading = false;
  double dragStartX = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 0.42);
    Sound.loop(bgm, 'result_bgm.mp3', volume: 0.36);
  }

  @override
  void dispose() {
    pageController.dispose();
    bgm.dispose();
    se.dispose();
    super.dispose();
  }

  String humanMove(PlayRecord r) {
    final usi = r.question.bestMove;
    if (usi.isEmpty) return '不明';
    const nums = {'1': '１', '2': '２', '3': '３', '4': '４', '5': '５', '6': '６', '7': '７', '8': '８', '9': '９'};
    const ranks = {'a': '一', 'b': '二', 'c': '三', 'd': '四', 'e': '五', 'f': '六', 'g': '七', 'h': '八', 'i': '九'};
    const pieces = {'P': '歩', 'L': '香', 'N': '桂', 'S': '銀', 'G': '金', 'B': '角', 'R': '飛', 'K': '玉'};
    final mark = r.question.sideToMoveAfter == 'black' ? '▲' : '△';
    if (usi.contains('*')) {
      final p = usi[0];
      final to = usi.substring(2, 4);
      return '$mark${nums[to[0]]}${ranks[to[1]]}${pieces[p]}打';
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
      return '$mark${nums[to[0]]}${ranks[to[1]]}$pieceName$promote';
    }
    return usi;
  }

  Future<void> goTitle() async {
    if (fading) return;
    setState(() => fading = true);
    await Sound.play(se, 'se_start.mp3', volume: 0.85);
    await Future.delayed(const Duration(milliseconds: 500));
    await bgm.stop();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TitlePage(skipTapToStart: true)));
  }

  void movePage(int next) {
    if (next < 0 || next >= widget.records.length) return;
    pageController.animateToPage(next, duration: const Duration(milliseconds: 160), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final records = widget.records;
    final current = records.isEmpty ? null : records[selected.clamp(0, records.length - 1)];
    return Scaffold(
      backgroundColor: const Color(0xFF090806),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                Text('投了', style: GoogleFonts.notoSerifJp(fontSize: 48, fontWeight: FontWeight.w900)),
                Text('SCORE ${widget.score}', style: const TextStyle(fontSize: 26)),
                Text('BEST ${widget.bestScore}', style: const TextStyle(fontSize: 20, color: Colors.amber)),
                Text('到達問題数 ${widget.questionCount}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                if (records.isNotEmpty)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: (d) => dragStartX = d.globalPosition.dx,
                      onHorizontalDragUpdate: (d) {
                        final diff = d.globalPosition.dx - dragStartX;
                        if (diff.abs() > 22) {
                          movePage(diff < 0 ? selected + 1 : selected - 1);
                          dragStartX = d.globalPosition.dx;
                        }
                      },
                      child: PageView.builder(
                        itemCount: records.length,
                        controller: pageController,
                        onPageChanged: (i) => setState(() => selected = i),
                        itemBuilder: (context, index) {
                          final r = records[index];
                          final active = index == selected;
                          return AnimatedScale(
                            scale: active ? 1.0 : 0.74,
                            duration: const Duration(milliseconds: 160),
                            child: Opacity(
                              opacity: active ? 1 : 0.62,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ShogiPositionView.staticView(
                                      sfen: r.question.sfen,
                                      moveUsi: r.question.moveUsi,
                                      perspectiveBlack: perspectiveBlackForTurn(r.question.sideToMoveAfter),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (current != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xCC120D09), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF9C7435))),
                      child: Column(
                        children: [
                          Text('第 ${selected + 1} 問', style: GoogleFonts.notoSerifJp(fontSize: 22, fontWeight: FontWeight.w900)),
                          Text('予測 ${formatEval(current.predictedEval)} / 正解 ${formatEval(current.correctEval)}'),
                          Text('誤差 ${current.diffPercent.toStringAsFixed(1)}% / ダメージ ${current.damage} / 回復 ${current.heal}'),
                          Text('最善手 ${humanMove(current)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await bgm.stop();
                          if (!context.mounted) return;
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GamePage()));
                        },
                        child: const Text('もう一局', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 16),
                      TextButton(onPressed: goTitle, child: const Text('タイトルへ')),
                    ],
                  ),
                ),
              ],
            ),
            AnimatedOpacity(
              opacity: fading ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: IgnorePointer(ignoring: !fading, child: Container(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
