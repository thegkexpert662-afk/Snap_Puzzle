import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String sound) async {
    final prefs = await SharedPreferences.getInstance();

    final soundOn = prefs.getBool("sound") ?? true;

    if (!soundOn) return;

    await _player.play(
      AssetSource("sounds/$sound"),
    );
  }
}