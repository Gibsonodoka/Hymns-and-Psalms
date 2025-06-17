import 'package:flutter/material.dart';
import 'hymns_screen.dart';
import 'psalms_screen.dart';
import 'settings_screen.dart';
import 'pro_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/hymn.dart';
import 'hymn_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const HymnsScreen(),
    const PsalmsScreen(),
    const SettingsScreen(),
    const ProScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _searchQuery = '';

  // Combine hymns and psalms into a single list
  static final List<Map<String, dynamic>> items = [
    ...HymnsScreen.hymns.map((hymn) => {'type': 'Hymn', 'data': hymn}),
    ...PsalmsScreen.psalms.map((psalm) => {'type': 'Psalm', 'data': psalm}),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter items based on search query
    final filteredItems = _searchQuery.isEmpty
        ? items
        : items.where((item) {
            final hymn = item['data'] as Hymn;
            return hymn.title.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hymn & Psalm',
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
              final query = await showSearch(context: context, delegate: HomeSearchDelegate(items));
              if (query != null) {
                setState(() => _searchQuery = query);
              }
            },
            tooltip: 'Search Hymns & Psalms',
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
        child: filteredItems.isEmpty
            ? Center(
                child: Text(
                  'No results found',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isHymn = item['type'] == 'Hymn';
                  final hymn = item['data'] as Hymn;
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HymnDetailScreen(hymn: hymn),
                      ),
                    ),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: isHymn
                                ? [const Color(0xFFE8EAF6), Colors.white]
                                : [const Color(0xFFF1F8E9), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: isHymn ? const Color(0xFF3F51B5) : const Color(0xFF4CAF50),
                            child: Icon(
                              isHymn ? Icons.music_note : Icons.auto_stories,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            hymn.title,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Type: ${item['type']} | Tune: ${hymn.tune}',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
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

// Search delegate for HomeContent
class HomeSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> items;

  HomeSearchDelegate(this.items);

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
    final filtered = items.where((item) {
      final hymn = item['data'] as Hymn;
      return hymn.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Container(
      color: Colors.grey[100],
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final item = filtered[index];
          final isHymn = item['type'] == 'Hymn';
          final hymn = item['data'] as Hymn;
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: isHymn ? const Color(0xFF3F51B5) : const Color(0xFF4CAF50),
                child: Icon(
                  isHymn ? Icons.music_note : Icons.auto_stories,
                  color: Colors.white,
                  size: 20,
                ),
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
                'Type: ${item['type']} | Tune: ${hymn.tune}',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              onTap: () {
                close(context, hymn.title);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HymnDetailScreen(hymn: hymn)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}