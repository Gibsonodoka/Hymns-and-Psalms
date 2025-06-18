import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/font_size_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themeProvider.isDarkMode
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
                colors: themeProvider.isDarkMode
                    ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                    : [Colors.grey[100]!, Colors.white],
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
                  icon: Icons.brightness_6,
                  tooltip: 'Toggle dark mode',
                ),
                Consumer<FontSizeProvider>(
                  builder: (context, fontSizeProvider, child) => _buildSettingsCard(
                    context,
                    title: 'Font Size',
                    subtitle: 'Adjust text size for lyrics and sheets.',
                    trailing: DropdownButton<String>(
                      value: fontSizeProvider.fontSize,
                      items: ['Small', 'Medium', 'Large'].map((size) {
                        return DropdownMenuItem(value: size, child: Text(size));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          fontSizeProvider.setFontSize(value);
                        }
                      },
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                      underline: const SizedBox(),
                    ),
                    icon: Icons.text_fields,
                    tooltip: 'Select font size',
                  ),
                ),
                _buildSettingsCard(
                  context,
                  title: 'Notifications',
                  subtitle: 'Receive updates on new hymns and psalms.',
                  trailing: Switch(
                    value: Provider.of<SettingsProvider>(context).notificationsEnabled,
                    onChanged: (_) => Provider.of<SettingsProvider>(context, listen: false).toggleNotifications(),
                    activeColor: const Color(0xFF3F51B5),
                    inactiveThumbColor: Colors.grey[400],
                  ),
                  icon: Icons.notifications,
                  tooltip: 'Toggle notifications',
                ),
                _buildSettingsCard(
                  context,
                  title: 'Audio Quality',
                  subtitle: 'Choose audio streaming quality.',
                  trailing: DropdownButton<String>(
                    value: Provider.of<SettingsProvider>(context).audioQuality,
                    items: ['Low', 'Medium', 'High'].map((quality) {
                      return DropdownMenuItem(value: quality, child: Text(quality));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        Provider.of<SettingsProvider>(context, listen: false).setAudioQuality(value);
                      }
                    },
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                    underline: const SizedBox(),
                  ),
                  icon: Icons.audiotrack,
                  tooltip: 'Select audio quality',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget trailing,
    required IconData icon,
    required String tooltip,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: themeProvider.isDarkMode
                ? [const Color(0xFF1E1E1E), const Color(0xFF424242)]
                : [const Color(0xFFE8EAF6), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Tooltip(
          message: tooltip,
          child: ListTile(
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
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}