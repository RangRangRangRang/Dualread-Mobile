import 'package:audioplayers/audioplayers.dart';

class SoundHelper {
  static final AudioPlayer player = AudioPlayer();

  static Future<void> playPage() async {
    try {
      await player.stop();
      await player.play(AssetSource('sounds/page.wav'));
    } catch (e) {
      return;
    }
  }
}