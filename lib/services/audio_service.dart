import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum SoundEffect {
  save,
  delete,
  cardOpen,
  cardClose,
  tap,
  notification,
  navigation,
  success,
  error,
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  
  AudioService._internal() {
    _audioPlayer = AudioPlayer();
    _backgroundMusicPlayer = AudioPlayer();
  }
  
  late final AudioPlayer _audioPlayer;
  late final AudioPlayer _backgroundMusicPlayer;
  bool _isBackgroundMusicPlaying = false;
  
  Future<void> playSoundEffect(SoundEffect effect) async {
    try {
      String soundPath;
      switch (effect) {
        case SoundEffect.save:
          soundPath = 'assets/audio/sfx/save.mp3';
          break;
        case SoundEffect.delete:
          soundPath = 'assets/audio/sfx/delete.mp3';
          break;
        case SoundEffect.cardOpen:
          soundPath = 'assets/audio/sfx/card_open.mp3';
          break;
        case SoundEffect.cardClose:
          soundPath = 'assets/audio/sfx/card_close.mp3';
          break;
        case SoundEffect.tap:
          soundPath = 'assets/audio/sfx/tap.mp3';
          break;
        case SoundEffect.notification:
          soundPath = 'assets/audio/sfx/notification.mp3';
          break;
        case SoundEffect.navigation:
          soundPath = 'assets/audio/sfx/navigation.mp3';
          break;
        case SoundEffect.success:
          soundPath = 'assets/audio/sfx/success.mp3';
          break;
        case SoundEffect.error:
          soundPath = 'assets/audio/sfx/error.mp3';
          break;
      }
      
      await _audioPlayer.play(AssetSource(soundPath.replaceFirst('assets/', '')));
    } catch (e) {
      // Silently fail if audio file doesn't exist
    }
  }
  
  Future<void> playBackgroundMusic() async {
    if (_isBackgroundMusicPlaying) return;
    
    try {
      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundMusicPlayer.setVolume(1.0);
      await _backgroundMusicPlayer.play(AssetSource('audio/background_music.mp3'));
      _isBackgroundMusicPlaying = true;
    } catch (e) {
      debugPrint('Error playing background music: $e');
      _isBackgroundMusicPlaying = false;
    }
  }
  
  Future<void> stopBackgroundMusic() async {
    await _backgroundMusicPlayer.stop();
    _isBackgroundMusicPlaying = false;
  }
  
  Future<void> pauseBackgroundMusic() async {
    await _backgroundMusicPlayer.pause();
  }
  
  Future<void> resumeBackgroundMusic() async {
    await _backgroundMusicPlayer.resume();
  }
  
  bool get isBackgroundMusicPlaying => _isBackgroundMusicPlaying;
  
  void dispose() {
    _audioPlayer.dispose();
    _backgroundMusicPlayer.dispose();
  }
}
