import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  ThemeMode themeMode;
  double fontSize;
  String serverName;
  int port;

  Settings({
    this.themeMode = ThemeMode.system,
    this.fontSize = 14.0,
    this.serverName = 'localhost',
    this.port = 50051,
  });

  static const String _themeModeKey = 'theme_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _serverNameKey = 'server_name';
  static const String _portKey = 'port';

  // Load settings from SharedPreferences
  static Future<Settings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Initialize with default values if not set
      if (!prefs.containsKey(_themeModeKey)) {
        await prefs.setInt(_themeModeKey, ThemeMode.system.index);
      }
      if (!prefs.containsKey(_fontSizeKey)) {
        await prefs.setDouble(_fontSizeKey, 14.0);
      }
      if (!prefs.containsKey(_serverNameKey)) {
        await prefs.setString(_serverNameKey, 'localhost');
      }
      if (!prefs.containsKey(_portKey)) {
        await prefs.setInt(_portKey, 50051);
      }

      return Settings(
        themeMode: ThemeMode
            .values[prefs.getInt(_themeModeKey) ?? ThemeMode.system.index],
        fontSize: prefs.getDouble(_fontSizeKey) ?? 14.0,
        serverName: prefs.getString(_serverNameKey) ?? 'localhost',
        port: prefs.getInt(_portKey) ?? 50051,
      );
    } catch (e) {
      // Return default settings if there's any error
      return Settings();
    }
  }

  // Save settings to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_themeModeKey, themeMode.index);
    await prefs.setDouble(_fontSizeKey, fontSize);
    await prefs.setString(_serverNameKey, serverName);
    await prefs.setInt(_portKey, port);
  }
}
