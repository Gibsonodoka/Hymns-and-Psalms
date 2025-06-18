import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/hymn.dart';
import '../providers/font_size_provider.dart';
import '../providers/theme_provider.dart';

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
      setState(() => _isAudioInitialized = false);
      return;
    }
    setState(() => _isAudioLoading = true);
    try {
      await _player.setAsset(widget.hymn.audioUrl);
      await _player.setLoopMode(LoopMode.off);
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAudioInitialized = false;
          _isAudioLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing audio: $e')),
        );
      }
    }
  }

  Future<void> _initializePdf() async {
    if (kIsWeb) {
      setState(() => _isPdfInitialized = false);
      return;
    }
    setState(() => _isPdfLoading = true);
    try {
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPdfInitialized = false;
          _isPdfLoading = false;
        });
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
    } catch (e) {
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
        title: Consumer<FontSizeProvider>(
          builder: (context, fontSizeProvider, child) => Text(
            widget.hymn.title,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20 * fontSizeProvider.fontScale,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Provider.of<ThemeProvider>(context).isDarkMode
                  ? [const Color(0xFF1A237E), const Color(0xFF1565C0)]
                  : [const Color(0xFF3F51B5), const Color(0xFF2196F3)],
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Provider.of<ThemeProvider>(context).isDarkMode
                        ? [const Color(0xFF1E1E1E), const Color(0xFF424242)]
                        : [Colors.grey[100]!, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: kIsWeb || !_isAudioInitialized
                    ? _isAudioLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Consumer<FontSizeProvider>(
                            builder: (context, fontSizeProvider, child) => Text(
                              'Audio not supported',
                              style: TextStyle(
                                fontSize: 14 * fontSizeProvider.fontScale,
                                color: Colors.red,
                              ),
                            ),
                          )
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Consumer<FontSizeProvider>(
                                builder: (context, fontSizeProvider, child) => Text(
                                  _formatDuration(_position),
                                  style: TextStyle(
                                    fontSize: 10 * fontSizeProvider.fontScale,
                                    color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.grey[400] : Colors.black54,
                                  ),
                                ),
                              ),
                              Consumer<FontSizeProvider>(
                                builder: (context, fontSizeProvider, child) => Text(
                                  _formatDuration(_duration),
                                  style: TextStyle(
                                    fontSize: 10 * fontSizeProvider.fontScale,
                                    color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.grey[400] : Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error seeking: $e')),
                                      );
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
          Expanded(
            child: _showSheet
                ? kIsWeb || !_isPdfInitialized || _pdfPath == null
                    ? _isPdfLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Consumer<FontSizeProvider>(
                            builder: (context, fontSizeProvider, child) => Center(
                              child: Text(
                                'PDF not supported: ${_pdfPath ?? 'No file'}',
                                style: TextStyle(
                                  fontSize: 16 * fontSizeProvider.fontScale,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          )
                    : PDFView(
                        filePath: _pdfPath!,
                        autoSpacing: true,
                        enableSwipe: true,
                        swipeHorizontal: true,
                        onError: (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error rendering PDF: $error')),
                          );
                        },
                      )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Consumer<FontSizeProvider>(
                      builder: (context, fontSizeProvider, child) => Text(
                        widget.hymn.lyrics,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16 * fontSizeProvider.fontScale,
                          height: 1.5,
                          color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}