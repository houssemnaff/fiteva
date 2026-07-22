import 'package:audioplayers/audioplayers.dart';

class TickSoundService {
  TickSoundService._();
  static final TickSoundService instance = TickSoundService._();

  final _player = AudioPlayer();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await _player.setSource(AssetSource('audio/tick.wav'));
    await _player.setVolume(0.3);
    _ready = true;
  }

  Future<void> tick() async {
    if (!_ready) await init();
    await _player.stop();
    await _player.seek(Duration.zero);
    await _player.resume();
  }

  void dispose() {
    _player.dispose();
  }
}
