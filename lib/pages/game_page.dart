import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/play_record.dart';
import '../models/question_data.dart';
import '../services/sound.dart';
import '../services/sound_settings.dart';
import '../utils/constants.dart';
import '../utils/eval_utils.dart';
import '../widgets/game_header.dart';
import '../widgets/guess_bar.dart';
import '../widgets/life_pieces.dart';
import '../widgets/result_flash.dart';
import '../widgets/shogi_position_view.dart';
import '../widgets/timer_view.dart';
import 'result_page.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final AudioPlayer bgm = AudioPlayer();
  final AudioPlayer se = AudioPlayer();

  List<QuestionData> questions = [];
  List<PlayRecord> records = [];
  QuestionData? currentQuestion;

  double guessPercent = 50;
  double dragLift = 0;
  double? correctPercent;

  int lastTickPercent = 50;
  int score = 0;
  int lives = maxLives;
  int previousLives = maxLives;
  int questionCount = 0;
  int bestScore = 0;

  int lastDamage = 0;
  int lastHeal = 0;
  int lastPredictedEval = 0;
  int lastCorrectEval = 0;
  double lastDiffPercent = 0;
  bool lastPerfect = false;
  bool lastCritical = false;

  bool loading = true;
  bool answered = false;
  bool boardReady = false;
  bool timerRunning = false;
  bool overTime = false;
  bool showResultOverlay = false;

  Timer? countdownTimer;
  Timer? overtimeTimer;
  int remainingTenths = answerLimitSeconds * 10;
  int overtimeSeconds = 0;

  @override
  void initState() {
    super.initState();
    initGame();
  }

  Future<void> initGame() async {
    await SoundSettings.load();
    await Sound.loop(bgm, 'battle_bgm.mp3', volume: 0.36);
    await loadGame();
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt('bestScore') ?? 0;
    final recentIds = prefs.getStringList('recentQuestionIds') ?? <String>[];
    final recentSet = recentIds.toSet();

    final jsonString = await rootBundle.loadString('assets/data/positions.json');
    final List<dynamic> data = json.decode(jsonString);

    final seenSfen = <String>{};
    final uniqueQuestions = <QuestionData>[];

    for (final e in data) {
      final q = QuestionData.fromJson(e);
      if (q.sfen.isEmpty) continue;
      if (seenSfen.add(q.sfen)) uniqueQuestions.add(q);
    }

    final filtered = uniqueQuestions.where((q) => !recentSet.contains(q.id)).toList();
    questions = (filtered.length >= 30 ? filtered : uniqueQuestions)..shuffle();
    debugPrint('[Keisense] loaded=${data.length}, unique=${uniqueQuestions.length}, playable=${questions.length}');
    nextQuestion();
  }

  Future<void> saveRecentQuestion(String id) async {
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('recentQuestionIds') ?? <String>[];
    recent.remove(id);
    recent.add(id);
    final trimmed = recent.length > 100 ? recent.sublist(recent.length - 100) : recent;
    await prefs.setStringList('recentQuestionIds', trimmed);
  }

  void nextQuestion() {
    stopTimers();
    final next = questions[questionCount % questions.length];
    unawaited(saveRecentQuestion(next.id));
    setState(() {
      currentQuestion = next;
      guessPercent = 50;
      dragLift = 0;
      correctPercent = null;
      lastTickPercent = 50;
      answered = false;
      boardReady = false;
      timerRunning = false;
      overTime = false;
      showResultOverlay = false;
      loading = false;
      previousLives = lives;
      remainingTenths = answerLimitSeconds * 10;
      overtimeSeconds = 0;
    });
  }

  void stopTimers() {
    countdownTimer?.cancel();
    overtimeTimer?.cancel();
    countdownTimer = null;
    overtimeTimer = null;
  }

  void startAnswerTimer() {
    if (timerRunning || answered) return;
    setState(() {
      timerRunning = true;
      overTime = false;
      remainingTenths = answerLimitSeconds * 10;
      overtimeSeconds = 0;
    });
    countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || answered) {
        timer.cancel();
        return;
      }
      setState(() => remainingTenths -= 1);
      if (remainingTenths <= 0) {
        timer.cancel();
        startOvertimePenalty();
      }
    });
  }

  void startOvertimePenalty() {
    if (answered || !mounted) return;
    setState(() {
      overTime = true;
      overtimeSeconds = 0;
    });
    overtimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted || answered) {
        timer.cancel();
        return;
      }
      setState(() {
        previousLives = lives;
        lives -= 1;
        overtimeSeconds += 1;
      });
      await Sound.play(se, 'se_damage.mp3', volume: 0.65);
      if (lives <= 0) {
        timer.cancel();
        await showGameOver();
      }
    });
  }

  Future<void> submitAnswer() async {
    if (currentQuestion == null || answered || !boardReady) return;
    stopTimers();
    await Sound.play(se, 'se_piece.mp3', volume: 1.0);

    final displayEval = displayEvalForTurn(
      blackEvalCp: currentQuestion!.evalCp,
      sideToMoveAfter: currentQuestion!.sideToMoveAfter,
    );
    final predictedEval = percentToEval(guessPercent);
    final correct = evalToPercent(displayEval).clamp(0.0, 100.0);
    final diffPercent = (guessPercent - correct).abs();
    final perfect = diffPercent < 0.05;
    final critical = !perfect && diffPercent <= 2.0;
    int damage = damageFromDiff(diffPercent);
    int heal = 0;
    if (perfect) {
      damage = 0;
      heal = 3;
    }
    final gain = perfect ? 150 : critical ? 120 : max(0, 100 - (diffPercent * 2).round());

    records.add(PlayRecord(
      question: currentQuestion!,
      predictedEval: predictedEval,
      correctEval: displayEval,
      diffPercent: diffPercent,
      damage: damage,
      heal: heal,
      perfect: perfect,
      critical: critical,
    ));

    setState(() {
      answered = true;
      correctPercent = correct;
      lastDamage = damage;
      lastHeal = heal;
      lastPredictedEval = predictedEval;
      lastCorrectEval = displayEval;
      lastDiffPercent = diffPercent;
      lastPerfect = perfect;
      lastCritical = critical;
      previousLives = lives;
      lives = heal > 0 ? min(maxLives, lives + heal) : lives - damage;
      score += gain;
      questionCount++;
      showResultOverlay = true;
    });

    await Future.delayed(const Duration(milliseconds: 230));
    if (perfect) {
      await Sound.play(se, 'se_heal.mp3', volume: 0.75);
    } else if (critical) {
      await Sound.play(se, 'se_critical.mp3', volume: 0.75);
    } else if (damage > 0) {
      await Sound.play(se, 'se_damage.mp3', volume: 0.65);
    }
    await Future.delayed(const Duration(milliseconds: 1050));
    if (!mounted) return;
    if (lives <= 0) {
      await showGameOver();
    } else {
      nextQuestion();
    }
  }

  Future<void> showGameOver() async {
    stopTimers();
    if (score > bestScore) {
      bestScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('bestScore', bestScore);
    }
    await bgm.stop();
    await Sound.play(se, 'se_lose.mp3', volume: 0.85);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultPage(score: score, bestScore: bestScore, questionCount: questionCount, records: records)),
    );
  }

  @override
  void dispose() {
    stopTimers();
    bgm.dispose();
    se.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading || currentQuestion == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final perspectiveBlack = perspectiveBlackForTurn(currentQuestion!.sideToMoveAfter);

    return Scaffold(
      backgroundColor: const Color(0xFF090806),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(center: Alignment.topCenter, radius: 1.25, colors: [Color(0xFF22170E), Color(0xFF0A0907)]),
                ),
              ),
            ),
            Column(
              children: [
                GameHeader(score: score, question: questionCount + 1),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 700;
                    if (isMobile) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: TimerView(
                                remainingTenths: remainingTenths,
                                overTime: overTime,
                                overtimeSeconds: overtimeSeconds,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LifePieces(lives: lives, previousLives: previousLives),
                          ],
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        children: [
                          const SizedBox(width: 220),
                          Expanded(child: Center(child: LifePieces(lives: lives, previousLives: previousLives))),
                          SizedBox(
                            width: 220,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TimerView(
                                remainingTenths: remainingTenths,
                                overTime: overTime,
                                overtimeSeconds: overtimeSeconds,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: ShogiPositionView(
                      key: ValueKey(currentQuestion!.id),
                      beforeSfen: currentQuestion!.beforeSfen,
                      sfen: currentQuestion!.sfen,
                      moveUsi: currentQuestion!.moveUsi,
                      overTime: overTime,
                      perspectiveBlack: perspectiveBlack,
                      onFinalMove: () => Sound.play(se, 'se_piece.mp3', volume: 0.85),
                      onReady: () {
                        setState(() => boardReady = true);
                        startAnswerTimer();
                      },
                    ),
                  ),
                ),
                GuessBar(
                  enabled: boardReady && !answered,
                  percent: guessPercent,
                  lift: dragLift,
                  correctPercent: correctPercent,
                  onChanged: (p, lift) async {
                    if (!boardReady || answered) return;
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
                  onSubmit: submitAnswer,
                ),
                const SizedBox(height: 8),
              ],
            ),
            if (showResultOverlay)
              Center(
                child: ResultFlash(
                  predictedEval: lastPredictedEval,
                  correctEval: lastCorrectEval,
                  diffPercent: lastDiffPercent,
                  damage: lastDamage,
                  heal: lastHeal,
                  perfect: lastPerfect,
                  critical: lastCritical,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
