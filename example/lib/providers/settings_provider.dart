import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/settings.dart';

part 'settings_provider.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<Settings> build() async {
    return Settings.load();
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final settings = await Settings.load();
      settings.themeMode = themeMode;
      await settings.save();
      return settings;
    });
  }

  Future<void> updateFontSize(double fontSize) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final settings = await Settings.load();
      settings.fontSize = fontSize;
      await settings.save();
      return settings;
    });
  }

  Future<void> updateServerSettings({String? serverName, int? port}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final settings = await Settings.load();
      if (serverName != null) settings.serverName = serverName;
      if (port != null) settings.port = port;
      await settings.save();
      return settings;
    });
  }

  Future<void> updateSecretKey(String? secretKey) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final settings = await Settings.load();
      settings.secretKey = secretKey;
      await settings.save();
      return settings;
    });
  }
}
