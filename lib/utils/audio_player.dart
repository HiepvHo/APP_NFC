import 'package:audioplayers/audioplayers.dart';

class AudioPlayerUtil {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playAssetAudio(String assetPath) async {
    try {
      print('Playing audio: $assetPath'); // Debug log
      await _audioPlayer
          .play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  static Future<void> stop() async {
    await _audioPlayer.stop();
  }
}
