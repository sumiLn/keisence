import 'package:shared_preferences/shared_preferences.dart';

class SoundSettings {
  static bool bgmOn = true;
  static bool seOn = true;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    bgmOn = prefs.getBool('bgmOn') ?? true;
    seOn = prefs.getBool('seOn') ?? true;
  }

  static Future<void> setBgm(bool value) async {
    bgmOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bgmOn', value);
  }

  static Future<void> setSe(bool value) async {
    seOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seOn', value);
  }
}
