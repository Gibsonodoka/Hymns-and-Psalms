import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioService extends BaseAudioHandler {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  AudioService._internal() {
    _initPlayer();
  }

  AudioPlayer get player => _player;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      print('Starting AudioService initialization');
      // Temporarily disable JustAudioBackground for debugging
      // await JustAudioBackground.init(
      //   androidNotificationChannelId: 'com.example.musicapp.audio',
      //   androidNotificationChannelName: 'MusicApp Playback',
      //   androidNotificationOngoing: true,
      //   androidNotificationIcon: 'mipmap/ic_launcher',
      // );
      _isInitialized = true;
      print('AudioService initialized successfully');
    } catch (e, stackTrace) {
      _isInitialized = false;
      print('Error initializing AudioService: $e\nStackTrace: $stackTrace');
      rethrow;
    }
  }

  void _initPlayer() {
    _player.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        playing: _player.playing,
        controls: [
          MediaControl.skipToPrevious,
          _player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        processingState: _player.processingState == ProcessingState.loading
            ? AudioProcessingState.loading
            : _player.processingState == ProcessingState.buffering
                ? AudioProcessingState.buffering
                : _player.processingState == ProcessingState.ready
                    ? AudioProcessingState.ready
                    : AudioProcessingState.completed,
      ));
    });
  }

  Future<void> playAudio(String audioUrl, String title) async {
    if (!_isInitialized) {
      print('AudioService not initialized, attempting to initialize...');
      await init();
    }
    try {
      print('Attempting to play audio: $audioUrl');
      final mediaItem = MediaItem(
        id: audioUrl,
        title: title,
        album: 'Hymn & Psalm',
      );
      this.mediaItem.add(mediaItem);
      final assetPath = audioUrl.startsWith('assets/') ? audioUrl.replaceFirst('assets/', '') : audioUrl;
      print('Using asset path: asset:///$assetPath');
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse('asset:///$assetPath'),
          tag: mediaItem,
        ),
      );
      await _player.play();
      print('Audio playback started successfully');
    } catch (e, stackTrace) {
      print('Error playing audio: $e\nStackTrace: $stackTrace');
      throw Exception('Error loading audio: $e');
    }
  }

  @override
  Future<void> play() async {
    try {
      await _player.play();
      print('Audio play resumed');
    } catch (e) {
      print('Error resuming audio: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
      print('Audio paused');
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      await super.stop();
      print('Audio stopped');
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  Future<void> toggleLoop() async {
    try {
      final isLooping = _player.loopMode == LoopMode.one;
      await _player.setLoopMode(isLooping ? LoopMode.off : LoopMode.one);
      print('Loop mode set to: ${isLooping ? 'off' : 'on'}');
    } catch (e) {
      print('Error toggling loop: $e');
    }
  }

  bool get isPlaying => _player.playing;

  bool get isLooping => _player.loopMode == LoopMode.one;

  @override
  Future<void> dispose() async {
    try {
      await _player.dispose();
      await super.stop();
      print('AudioService disposed');
    } catch (e) {
      print('Error disposing AudioService: $e');
    }
  }
}