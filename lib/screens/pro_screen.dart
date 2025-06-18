import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_size_provider.dart';
import '../providers/theme_provider.dart';

class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<FontSizeProvider>(
          builder: (context, fontSizeProvider, child) => Text(
            'PRO',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 22 * fontSizeProvider.fontScale,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Provider.of<ThemeProvider>(context).isDarkMode
                ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                : [Colors.grey[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Provider.of<ThemeProvider>(context).isDarkMode
                        ? [const Color(0xFF1A237E), const Color(0xFF1565C0)]
                        : [const Color(0xFF3F51B5), const Color(0xFF2196F3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Consumer<FontSizeProvider>(
                  builder: (context, fontSizeProvider, child) => Column(
                    children: [
                      Text(
                        'Unlock PRO Features',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 28 * fontSizeProvider.fontScale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enjoy full access to premium content and features!',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16 * fontSizeProvider.fontScale,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PRO subscription coming soon!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF3F51B5),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16 * fontSizeProvider.fontScale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Get PRO Now'),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    _buildFeatureCard(
                      context,
                      icon: Icons.music_note,
                      title: 'Unlimited Audio Playback',
                      subtitle: 'Stream hymns and psalms without limits.',
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.picture_as_pdf,
                      title: 'Premium Sheet Music',
                      subtitle: 'Access high-quality PDF sheets.',
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.cloud_download,
                      title: 'Offline Access',
                      subtitle: 'Download content for offline use.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: Provider.of<ThemeProvider>(context).isDarkMode
                ? [const Color(0xFF1E1E1E), const Color(0xFF424242)]
                : [const Color(0xFFE8EAF6), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<FontSizeProvider>(
          builder: (context, fontSizeProvider, child) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF3F51B5),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16 * fontSizeProvider.fontScale,
                fontWeight: FontWeight.w500,
                color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12 * fontSizeProvider.fontScale,
                color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}