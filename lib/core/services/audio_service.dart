import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playSoundThemePreview(String theme) async {
    try {
      await _audioPlayer.stop();
      // Plays sound cues or test tone
      if (theme == 'chime') {
        await _audioPlayer.play(AssetSource('sounds/chime.mp3'));
      } else if (theme == 'gentle') {
        await _audioPlayer.play(AssetSource('sounds/gentle.mp3'));
      } else {
        // Fallback default system player action / notification tone
        await _audioPlayer.play(
          UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'),
        );
      }
    } catch (e) {
      // Audio preview fallback gracefully if offline or sound asset unavailable
    }
  }

  static Future<void> stop() async {
    await _audioPlayer.stop();
  }
}
