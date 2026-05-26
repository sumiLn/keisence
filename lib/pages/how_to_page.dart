import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question_data.dart';
import '../services/sound.dart';
import '../utils/eval_utils.dart';
import '../widgets/guess_bar.dart';
import '../widgets/shogi_position_view.dart';

class HowToPage extends StatefulWidget {
  const HowToPage({super.key});

  @override
  State<HowToPage> createState() => _HowToPageState();
}

class _HowToPageState extends State<HowToPage> {
  final AudioPlayer se = AudioPlayer();
  List<QuestionData> questions = [];
  QuestionData? question;
  double guessPercent = 50;
  double dragLift = 0;
  double? correctPercent;
  int lastTickPercent = 50;
  String resultText = '';
  bool boardReady = false;

  @override
  void initState() {
    super.initState();
    loadQuestion();
  }

  Future<void> loadQuestion() async {
    final jsonString = await rootBundle.loadString('assets/data/positions.json');
    final List<dynamic> data = json.decode(jsonString);
    questions = data.map((e) => QuestionData.fromJson(e)).toList()..shuffle();
    nextSample();
  }

  void nextSample() {
    setState(() {
      question = questions[Random().nextInt(questions.length)];
      guessPercent = 50;
      dragLift = 0;
      correctPercent = null;
      resultText = '';
      boardReady = false;
    });
  }

  Future<void> submitPractice() async {
    if (question == null || !boardReady) return;
    await Sound.play(se, 'se_piece.mp3', volume: 1.0);
    final displayEval = displayEvalForTurn(
      blackEvalCp: question!.evalCp,
      sideToMoveAfter: question!.sideToMoveAfter,
    );
    final correct = evalToPercent(displayEval).clamp(0.0, 100.0);
    final predicted = percentToEval(guessPercent);
    final diff = (guessPercent - correct).abs();
    setState(() {
      correctPercent = correct;
      resultText = '予測 ${formatEval(predicted)} / 正解 ${formatEval(displayEval)} / 誤差 ${diff.toStringAsFixed(1)}%';
    });
  }

  @override
  void dispose() {
    se.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (question == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: const Color(0xFF090806),
      appBar: AppBar(title: const Text('遊び方')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '局面を見て形勢を予想し、王将を左右に動かします。ここだと思ったら上にフリックして解答します。',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSerifJp(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShogiPositionView(
                  key: ValueKey(question!.id),
                  beforeSfen: question!.beforeSfen,
                  sfen: question!.sfen,
                  moveUsi: question!.moveUsi,
                  perspectiveBlack: perspectiveBlackForTurn(question!.sideToMoveAfter),
                  onFinalMove: () => Sound.play(se, 'se_piece.mp3', volume: 0.85),
                  onReady: () => setState(() => boardReady = true),
                ),
              ),
            ),
            if (resultText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(resultText, style: const TextStyle(fontSize: 18, color: Colors.greenAccent)),
              ),
            GuessBar(
              enabled: boardReady,
              percent: guessPercent,
              lift: dragLift,
              correctPercent: correctPercent,
              onChanged: (p, lift) async {
                final rounded = p.round();
                if (rounded != lastTickPercent) {
                  lastTickPercent = rounded;
                  HapticFeedback.selectionClick();
                  await Sound.play(se, 'se_tick.mp3', volume: 0.35);
                }
                setState(() {
                  guessPercent = p;
                  dragLift = lift;
                });
              },
              onSubmit: submitPractice,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: nextSample, child: const Text('もう一問試す')),
                  const SizedBox(width: 16),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('タイトルへ')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
