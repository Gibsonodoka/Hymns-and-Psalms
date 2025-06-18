import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _buildSettingsCard(
              context,
              title: 'Dark Mode',
              subtitle: 'Switch to dark theme for better readability.',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                activeColor: const Color(0xFF3F51B5),
                inactiveThumbColor: Colors.grey[400],
              ),
            ),
            _buildSettingsCard(
              context,
              title: 'Font Size',
              subtitle: 'Adjust text size for lyrics and sheets.',
              trailing: DropdownButton<String>(
                value: 'Medium',
                items: ['Small', 'Medium', 'Large'].map((size) {
                  return DropdownMenuItem(value: size, child: Text(size));
                }).toList(),
                onChanged: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Font size adjustment coming soon!')),
                  );
                },
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                underline: const SizedBox(),
              ),
            ),
            _buildSettingsCard(
              context,
              title: 'Notifications',
              subtitle: 'Receive updates on new hymns and psalms.',
              trailing: Switch(
                value: false,
                onChanged: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon!')),
                  );
                },
                activeColor: const Color(0xFF3F51B5),
                inactiveThumbColor: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required String title, required String subtitle, required Widget trailing}) {
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
            child: const Icon(Icons.settings, color: Colors.white, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          trailing: trailing,
        ),
      ),
    );
  }
}