import 'package:audioplayers/audioplayers.dart';
import 'sound_settings.dart';

class Sound {
  static Future<void> play(AudioPlayer player, String file, {double volume = 0.8}) async {
    await SoundSettings.load();
    if (!SoundSettings.seOn) {
      try { await player.stop(); } catch (_) {}
      return;
    }
    try {
      await player.stop();
      await player.setReleaseMode(ReleaseMode.release);
      await player.play(AssetSource('audio/$file'), volume: volume);
    } catch (_) {}
  }

  static Future<void> loop(AudioPlayer player, String file, {double volume = 0.45}) async {
    await SoundSettings.load();
    if (!SoundSettings.bgmOn) {
      try { await player.stop(); } catch (_) {}
      return;
    }
    try {
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('audio/$file'), volume: volume);
    } catch (_) {}
  }

  static Future<void> applyBgmSetting(AudioPlayer player, String file, {double volume = 0.45}) async {
    await SoundSettings.load();
    if (SoundSettings.bgmOn) {
      await loop(player, file, volume: volume);
    } else {
      try { await player.stop(); } catch (_) {}
    }
  }
}
