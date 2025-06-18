import 'package:flutter/material.dart';
import '../models/hymn.dart';
import 'hymn_detail_screen.dart';

class HymnsScreen extends StatefulWidget {
  const HymnsScreen({super.key});

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

  @override
  _HymnsScreenState createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredHymns = HymnsScreen.hymns
        .where((hymn) => hymn.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hymns',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 26),
            onPressed: () async {
              final query = await showSearch(context: context, delegate: HymnSearchDelegate(HymnsScreen.hymns));
              if (query != null) setState(() => _searchQuery = query);
            },
            tooltip: 'Search Hymns',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: filteredHymns.isEmpty
            ? Center(
                child: Text(
                  'No hymns found',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: filteredHymns.length,
                itemBuilder: (context, index) {
                  final hymn = filteredHymns[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HymnDetailScreen(hymn: hymn)),
                    ),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE8EAF6), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF3F51B5),
                            child: const Icon(Icons.music_note, color: Colors.white, size: 20),
                          ),
                          title: Text(
                            hymn.title,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Tune: ${hymn.tune}',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class HymnSearchDelegate extends SearchDelegate {
  final List<Hymn> hymns;

  HymnSearchDelegate(this.hymns);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF3F51B5),
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(fontFamily: 'Roboto', color: Colors.white70),
        border: InputBorder.none,
      ),
      textTheme: Theme.of(context).textTheme.copyWith(
        titleLarge: const TextStyle(
          fontFamily: 'Roboto',
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = hymns.where((hymn) => hymn.title.toLowerCase().contains(query.toLowerCase())).toList();
    return Container(
      color: Colors.grey[100],
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final hymn = filtered[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8EAF6), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF3F51B5),
                  child: const Icon(Icons.music_note, color: Colors.white, size: 20),
                ),
                title: Text(
                  hymn.title,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Tune: ${hymn.tune}',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey[400],
                ),
                onTap: () {
                  close(context, hymn.title);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HymnDetailScreen(hymn: hymn)));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}