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

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  // Combine hymns and psalms into a single list
  static final List<Map<String, dynamic>> items = [
    ...HymnsScreen.hymns.map((hymn) => {'type': 'Hymn', 'data': hymn}),
    ...PsalmsScreen.psalms.map((psalm) => {'type': 'Psalm', 'data': psalm}),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hymn & Psalm App')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isHymn = item['type'] == 'Hymn';
          final hymn = item['data'] as Hymn;
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                isHymn ? Icons.music_note : Icons.book,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              title: Text(hymn.title, style: const TextStyle(fontSize: 18)),
              subtitle: Text('Type: ${item['type']} | Tune: ${hymn.tune}'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HymnDetailScreen(hymn: hymn),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}