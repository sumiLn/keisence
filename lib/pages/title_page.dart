import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sound.dart';
import '../services/sound_settings.dart';
import '../widgets/shogi_buttons.dart';
import 'game_page.dart';
import 'how_to_page.dart';
import 'settings_page.dart';

class TitlePage extends StatefulWidget {
  final bool skipTapToStart;
  const TitlePage({super.key, this.skipTapToStart = false});

  @override
  State<TitlePage> createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> {
  final AudioPlayer bgm = AudioPlayer();
  final AudioPlayer se = AudioPlayer();
  int bestScore = 0;
  late bool soundStarted;
  late bool menuVisible;
  bool fading = false;

  @override
  void initState() {
    super.initState();
    soundStarted = widget.skipTapToStart;
    menuVisible = widget.skipTapToStart;
    init();
  }

  Future<void> init() async {
    await SoundSettings.load();
    final prefs = await SharedPreferences.getInstance();
    setState(() => bestScore = prefs.getInt('bestScore') ?? 0);
    if (widget.skipTapToStart) await Sound.loop(bgm, 'home_bgm.mp3', volume: 0.34);
  }

  Future<void> startSoundAndMenu() async {
    if (soundStarted) return;
    setState(() => soundStarted = true);
    await Sound.loop(bgm, 'home_bgm.mp3', volume: 0.34);
    if (!mounted) return;
    setState(() => menuVisible = true);
  }

  Future<void> startGame() async {
    if (fading) return;
    setState(() => fading = true);
    await Sound.play(se, 'se_start.mp3', volume: 0.85);
    await Future.delayed(const Duration(milliseconds: 500));
    await bgm.stop();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GamePage()));
  }

  Future<void> openSettings() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage(homeBgm: bgm)));
    await Sound.applyBgmSetting(bgm, 'home_bgm.mp3', volume: 0.34);
  }

  void openHowTo() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const HowToPage()));
  }

  @override
  void dispose() {
    bgm.dispose();
    se.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFD6AA63),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: soundStarted ? null : startSoundAndMenu,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFEBCB8A), Color(0xFFD09C4D), Color(0xFFB7772B)],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15,
                  child: CustomPaint(painter: TitleWavePainter()),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: h * 0.39,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Text('ケイセンス', style: GoogleFonts.notoSerifJp(fontSize: 76, color: Colors.black, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 10),
                    if (!soundStarted)
                      Text('画面を押して開始', style: GoogleFonts.notoSerifJp(color: Colors.black87, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 2)),
                    AnimatedOpacity(
                      opacity: menuVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 450),
                      child: IgnorePointer(
                        ignoring: !menuVisible,
                        child: Column(
                          children: [
                            Text('BEST SCORE  $bestScore', style: GoogleFonts.notoSansJp(color: Colors.black87, fontSize: 25, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 26),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SmallPieceButton(text: '設定', onTap: openSettings),
                                const SizedBox(width: 18),
                                ShogiPieceButton(text: '対局開始', onTap: startGame),
                                const SizedBox(width: 18),
                                SmallPieceButton(text: '遊び方', onTap: openHowTo),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: fading ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: IgnorePointer(ignoring: !fading, child: Container(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class TitleWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    for (double y = size.height * 0.12; y < size.height; y += 44) {
      final path = Path()..moveTo(0, y);
      for (double x = 0; x < size.width; x += 30) {
        path.quadraticBezierTo(x + 15, y - 14, x + 30, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
