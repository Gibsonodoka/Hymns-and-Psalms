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
  String? _pdfPath;
  bool _isPdfInitialized = false;
  bool _isPdfLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _initializePdf();
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    kIsWeb || !_isAudioInitialized
                        ? _isAudioLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Audio not supported',
                                style: TextStyle(fontSize: 14, color: Colors.red),
                              )
                        : Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 28,
                                  color: Theme.of(context).primaryColor,
                                ),
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
                              IconButton(
                                icon: Icon(
                                  Icons.stop,
                                  size: 28,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () async {
                                  try {
                                    await _player.stop();
                                    await _player.seek(Duration.zero);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error stopping audio: $e')),
                                    );
                                  }
                                },
                                tooltip: 'Stop',
                              ),
                            ],
                          ),
                    IconButton(
                      icon: Icon(
                        _showSheet ? Icons.lyrics : Icons.description,
                        size: 28,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () => setState(() => _showSheet = !_showSheet),
                      tooltip: _showSheet ? 'Show Lyrics' : 'Show Music Sheet',
                    ),
                  ],
                ),
              ),
            ),
          ),
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