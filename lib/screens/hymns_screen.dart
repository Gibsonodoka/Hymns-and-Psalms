import 'package:flutter/material.dart';
import '../models/hymn.dart';
import 'hymn_detail_screen.dart';

class HymnsScreen extends StatefulWidget {
  const HymnsScreen({super.key});

  @override
  _HymnsScreenState createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen> {
  static const List<Hymn> hymns = [
    Hymn(
      id: 1,
      title: 'Amazing Grace',
      lyrics: 'Amazing grace, how sweet the sound\nThat saved a wretch like me...',
      tune: 'New Britain',
      audioUrl: 'assets/audio/amazing_grace.mp3',
      sheetUrl: 'assets/sheets/amazing_grace.pdf',
    ),
    Hymn(
      id: 2,
      title: 'How Great Thou Art',
      lyrics: 'O Lord my God, when I in awesome wonder...',
      tune: 'St. Columba',
      audioUrl: 'assets/audio/how_great.mp3',
      sheetUrl: 'assets/sheets/how_great.pdf',
    ),
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredHymns = hymns.where((hymn) => hymn.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hymns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final query = await showSearch(context: context, delegate: HymnSearchDelegate(hymns));
              if (query != null) setState(() => _searchQuery = query);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredHymns.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Text('${filteredHymns[index].id}'),
            title: Text(filteredHymns[index].title),
            subtitle: Text('Tune: ${filteredHymns[index].tune}'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HymnDetailScreen(hymn: filteredHymns[index])),
            ),
          );
        },
      ),
    );
  }
}

class HymnSearchDelegate extends SearchDelegate {
  final List<Hymn> hymns;

  HymnSearchDelegate(this.hymns);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = hymns.where((hymn) => hymn.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) => ListTile(
        leading: Text('${filtered[index].id}'),
        title: Text(filtered[index].title),
        subtitle: Text('Tune: ${filtered[index].tune}'),
        onTap: () {
          close(context, filtered[index].title);
          Navigator.push(context, MaterialPageRoute(builder: (context) => HymnDetailScreen(hymn: filtered[index])));
        },
      ),
    );
  }
}