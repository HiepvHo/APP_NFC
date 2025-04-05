import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  // Tạo một instance AudioPlayer
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // Hàm phát âm thanh từ Asset
  static Future<void> playAudioFromAssets(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print("Lỗi khi phát âm thanh: $e");
    }
  }



  // Dừng âm thanh
  static void stopAudio() {
    _audioPlayer.stop();
  }

  // Tạm dừng âm thanh
  static void pauseAudio() {
    _audioPlayer.pause();
  }
}
