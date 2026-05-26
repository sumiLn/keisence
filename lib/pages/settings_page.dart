import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sound_settings.dart';

class SettingsPage extends StatefulWidget {
  final AudioPlayer? homeBgm;
  const SettingsPage({super.key, this.homeBgm});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool bgmOn = SoundSettings.bgmOn;
  bool seOn = SoundSettings.seOn;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await SoundSettings.load();
    setState(() {
      bgmOn = SoundSettings.bgmOn;
      seOn = SoundSettings.seOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090806),
      appBar: AppBar(title: const Text('設定')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('BGM'),
              value: bgmOn,
              onChanged: (v) async {
                await SoundSettings.setBgm(v);
                if (!v) await widget.homeBgm?.stop();
                setState(() => bgmOn = v);
              },
            ),
            SwitchListTile(
              title: const Text('効果音'),
              value: seOn,
              onChanged: (v) async {
                await SoundSettings.setSe(v);
                setState(() => seOn = v);
              },
            ),
            const Divider(height: 36),
            Text('クレジット', style: GoogleFonts.notoSerifJp(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            const Text('製作者：住野生朔', style: TextStyle(fontSize: 18)),
            const Text('MUSIC：DOVA-SYNDROME、効果音ラボ', style: TextStyle(fontSize: 18)),
            const Text('評価値解析：水匠5 / やねうら王 NNUE V9.00Git（30秒読込）', style: TextStyle(fontSize: 18)),
            const Text('他：ChatGPT', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            const Text('バージョン1.0.0-1', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
