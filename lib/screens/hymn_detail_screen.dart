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
  String? _pdfPath;
  bool _isPdfInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _initializePdf();
  }

  Future<void> _initializeAudio() async {
    if (kIsWeb) {
      setState(() => _isAudioInitialized = false);
      return;
    }
    try {
      await _player.setAsset(widget.hymn.audioUrl);
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state.playing);
        }
      });
      setState(() => _isAudioInitialized = true);
    } catch (e) {
      if (mounted) {
        setState(() => _isAudioInitialized = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio: $e')),
        );
      }
    }
  }

  Future<void> _initializePdf() async {
    if (kIsWeb) {
      setState(() => _isPdfInitialized = false);
      return;
    }
    try {
      // Copy PDF from assets to temporary directory
      final bytes = await DefaultAssetBundle.of(context).load(widget.hymn.sheetUrl);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${widget.hymn.title.replaceAll(' ', '_')}.pdf');
      await tempFile.writeAsBytes(bytes.buffer.asUint8List());
      setState(() {
        _pdfPath = tempFile.path;
        _isPdfInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isPdfInitialized = false);
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
          // Music controls and PDF toggle in a Card
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
                    // Audio controls
                    kIsWeb || !_isAudioInitialized
                        ? const Text(
                            'Audio not supported',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          )
                        : Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 28,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  if (_isPlaying) {
                                    _player.pause();
                                  } else {
                                    _player.play();
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
                                onPressed: () {
                                  _player.stop();
                                  _player.seek(Duration.zero);
                                },
                                tooltip: 'Stop',
                              ),
                            ],
                          ),
                    // PDF toggle button
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
          // Content area (PDF or Lyrics)
          Expanded(
            child: _showSheet
                ? kIsWeb || !_isPdfInitialized || _pdfPath == null
                    ? const Center(child: Text('PDF not supported'))
                    : PDFView(
                        filePath: _pdfPath!,
                        autoSpacing: true,
                        enableSwipe: true,
                        swipeHorizontal: true,
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