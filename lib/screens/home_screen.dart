import 'package:flutter/material.dart';
import 'hymns_screen.dart';
import 'psalms_screen.dart';
import 'settings_screen.dart';
import 'pro_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(), // Added Home content
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

// Simple Home content widget
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hymn & Psalm App')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Hymn & Psalm App!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('Explore hymns, psalms, and more.', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}