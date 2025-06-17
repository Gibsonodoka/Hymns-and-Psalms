import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../models/hymn.dart';

class HymnDetailScreen extends StatefulWidget {
  final Hymn hymn;
  const HymnDetailScreen({super.key, required this.hymn});

  @override
  _HymnDetailScreenState createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _showSheet = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.setAsset(widget.hymn.audioUrl).catchError((error) {
      print('Error loading audio: $error');
    });
    _player.positionStream.listen((position) {
      setState(() => _position = position);
    });
    _player.durationStream.listen((duration) {
      setState(() => _duration = duration ?? Duration.zero);
    });
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
        title: Text(widget.hymn.title),
        actions: [
          IconButton(
            icon: Icon(_showSheet ? Icons.lyrics : Icons.description),
            onPressed: () => setState(() => _showSheet = !_showSheet),
            tooltip: _showSheet ? 'Show Lyrics' : 'Show Music Sheet',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_player.playing ? Icons.pause : Icons.play_arrow),
                  onPressed: () async => _player.playing ? await _player.pause() : await _player.play(),
                  iconSize: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: _duration.inSeconds > 0 ? _position.inSeconds / _duration.inSeconds : 0,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / '
                  '${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ),
          Expanded(
            child: _showSheet
                ? PDFView(filePath: widget.hymn.sheetUrl)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16), // Fixed: EdgeInserts -> EdgeInsets
                    child: Text(widget.hymn.lyrics, style: const TextStyle(fontSize: 16)),
                  ),
          ),
        ],
      ),
    );
  }
}