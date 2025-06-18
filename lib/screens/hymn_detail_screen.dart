import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/hymn.dart';

class HymnDetailScreen extends StatefulWidget {
  final Hymn hymn;
  const HymnDetailScreen({super.key, required this.hymn});

  @override
  _HymnDetailScreenState createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  bool _showSheet = false;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isAudioInitialized = false;
  bool _isAudioLoading = false;
  bool _isLooping = false;
  String? _pdfPath;
  bool _isPdfInitialized = false;
  bool _isPdfLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _initializePdf();
    // Listen to position and duration streams for progress bar
    _player.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
    _player.durationStream.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration ?? Duration.zero);
      }
    });
  }

  Future<void> _initializeAudio() async {
    if (kIsWeb) {
      print('Web platform detected, audio disabled');
      setState(() => _isAudioInitialized = false);
      return;
    }
    setState(() => _isAudioLoading = true);
    try {
      print('Initializing audio for: ${widget.hymn.audioUrl}');
      await _player.setAsset(widget.hymn.audioUrl);
      await _player.setLoopMode(LoopMode.off); // Default: no looping
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state.playing);
        }
      });
      if (mounted) {
        setState(() {
          _isAudioInitialized = true;
          _isAudioLoading = false;
        });
        print('Audio initialized successfully');
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isAudioInitialized = false;
          _isAudioLoading = false;
        });
        print('Error initializing audio: $e\nStackTrace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing audio: $e')),
        );
      }
    }
  }

  Future<void> _initializePdf() async {
    if (kIsWeb) {
      print('Web platform detected, PDF disabled');
      setState(() => _isPdfInitialized = false);
      return;
    }
    setState(() => _isPdfLoading = true);
    try {
      print('Loading PDF: ${widget.hymn.sheetUrl}');
      final bytes = await DefaultAssetBundle.of(context).load(widget.hymn.sheetUrl);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${widget.hymn.title.replaceAll(' ', '_')}.pdf');
      await tempFile.writeAsBytes(bytes.buffer.asUint8List());
      if (mounted) {
        setState(() {
          _pdfPath = tempFile.path;
          _isPdfInitialized = true;
          _isPdfLoading = false;
        });
        print('PDF loaded successfully: $_pdfPath');
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isPdfInitialized = false;
          _isPdfLoading = false;
        });
        print('Error loading PDF: $e\nStackTrace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading PDF: $e')),
        );
      }
    }
  }

  Future<void> _toggleLoop() async {
    try {
      await _player.setLoopMode(_isLooping ? LoopMode.off : LoopMode.one);
      setState(() => _isLooping = !_isLooping);
      print('Loop mode set to: ${_isLooping ? 'on' : 'off'}');
    } catch (e) {
      print('Error toggling loop: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling loop: $e')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.hymn.title,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Compact media player controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: kIsWeb || !_isAudioInitialized
                    ? _isAudioLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const Text(
                            'Audio not supported',
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          )
                    : Column(
                        children: [
                          // Duration labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: const TextStyle(fontSize: 10, color: Colors.black54),
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: const TextStyle(fontSize: 10, color: Colors.black54),
                              ),
                            ],
                          ),
                          // Progress bar and controls in one row
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.music_note,
                                  size: 24,
                                  color: Theme.of(context).primaryColor,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  try {
                                    if (_isPlaying) {
                                      await _player.pause();
                                    } else {
                                      await _player.play();
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error playing audio: $e')),
                                    );
                                  }
                                },
                                tooltip: _isPlaying ? 'Pause' : 'Play',
                              ),
                              Expanded(
                                child: Slider(
                                  value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                                  max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
                                  activeColor: Theme.of(context).primaryColor,
                                  inactiveColor: Colors.grey[400],
                                  onChanged: (value) async {
                                    try {
                                      final newPosition = Duration(seconds: value.toInt());
                                      await _player.seek(newPosition);
                                      print('Seeked to: $newPosition');
                                    } catch (e) {
                                      print('Error seeking: $e');
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.repeat,
                                  size: 24,
                                  color: _isLooping ? Theme.of(context).primaryColor : Colors.grey,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: _toggleLoop,
                                tooltip: _isLooping ? 'Disable Loop' : 'Enable Loop',
                              ),
                              const SizedBox(width: 4), 
                              IconButton(
                                icon: Icon(
                                  _showSheet ? Icons.lyrics : Icons.description,
                                  size: 24,
                                  color: Theme.of(context).primaryColor,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () => setState(() => _showSheet = !_showSheet),
                                tooltip: _showSheet ? 'Show Lyrics' : 'Show Music Sheet',
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
          // Content area (PDF or Lyrics)
          Expanded(
            child: _showSheet
                ? kIsWeb || !_isPdfInitialized || _pdfPath == null
                    ? _isPdfLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Center(
                            child: Text(
                              'PDF not supported: ${_pdfPath ?? 'No file'}',
                              style: const TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          )
                    : PDFView(
                        filePath: _pdfPath!,
                        autoSpacing: true,
                        enableSwipe: true,
                        swipeHorizontal: true,
                        onError: (error) {
                          print('PDFView error: $error');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error rendering PDF: $error')),
                          );
                        },
                      )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.hymn.lyrics,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}