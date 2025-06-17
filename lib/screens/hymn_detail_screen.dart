import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/hymn.dart';

class HymnDetailScreen extends StatefulWidget {
  final Hymn hymn;
  const HymnDetailScreen({super.key, required this.hymn});

  @override
  _HymnDetailScreenState createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  bool _showSheet = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hymn.title),
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Placeholder for audio controls on web
                        const Text(
                          'Audio not supported on web',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
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
                  ],
                ),
              ),
            ),
          ),
          // Content area (PDF or Lyrics)
          Expanded(
            child: _showSheet
                ? const Center(child: Text('PDF not supported on web'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.hymn.lyrics,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}