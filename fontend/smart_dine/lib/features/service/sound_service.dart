import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Phát âm thanh khi hoàn thành món
  Future<void> playCompletedSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/completed.mp3'));
      print('🔊 [SoundService] Playing completed sound');
    } catch (e) {
      print('❌ [SoundService] Error playing completed sound: $e');
    }
  }

  /// Phát âm thanh khi hết món
  Future<void> playOutOfStockSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/out_of_stock.mp3'));
      print('🔊 [SoundService] Playing out of stock sound');
    } catch (e) {
      print('❌ [SoundService] Error playing out of stock sound: $e');
    }
  }

  /// Stop âm thanh
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
}
