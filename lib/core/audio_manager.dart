import 'package:audioplayers/audioplayers.dart';

/// Centralized audio manager for all game sounds and music.
class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  Future<void> initialize() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.4);
    await _sfxPlayer.setVolume(0.8);
  }

  // ── Music ─────────────────────────────────────────────────────────────────────

  Future<void> playMenuMusic() async {
    if (!_musicEnabled) return;
    // await _musicPlayer.play(AssetSource('audio/menu_music.mp3'));
  }

  Future<void> playGameMusic() async {
    if (!_musicEnabled) return;
    // await _musicPlayer.play(AssetSource('audio/game_music.mp3'));
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  // ── SFX ───────────────────────────────────────────────────────────────────────

  Future<void> playArrowTap() async {
    if (!_soundEnabled) return;
    // await _sfxPlayer.play(AssetSource('audio/arrow_tap.mp3'));
  }

  Future<void> playArrowExit() async {
    if (!_soundEnabled) return;
    // await _sfxPlayer.play(AssetSource('audio/arrow_exit.mp3'));
  }

  Future<void> playArrowBlock() async {
    if (!_soundEnabled) return;
    // await _sfxPlayer.play(AssetSource('audio/arrow_block.mp3'));
  }

  Future<void> playLevelComplete() async {
    if (!_soundEnabled) return;
    // await _sfxPlayer.play(AssetSource('audio/level_complete.mp3'));
  }

  Future<void> playLifeLost() async {
    if (!_soundEnabled) return;
    // await _sfxPlayer.play(AssetSource('audio/life_lost.mp3'));
  }

  Future<void> playGameOver() async {
    if (!_soundEnabled) return;
    // await _sfxPlayer.play(AssetSource('audio/game_over.mp3'));
  }

  Future<void> playStreakExtended() async {
    if (!_soundEnabled) return;
    // await _sfxPlayer.play(AssetSource('audio/streak.mp3'));
  }

  // ── Settings ──────────────────────────────────────────────────────────────────

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    if (!value) _sfxPlayer.stop();
  }

  void setMusicEnabled(bool value) {
    _musicEnabled = value;
    if (!value) {
      _musicPlayer.stop();
    }
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
