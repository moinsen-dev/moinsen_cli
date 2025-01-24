import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../screens/connection_screen.dart';

class MoinsenMaterialApp extends StatelessWidget {
  final ThemeMode themeMode;
  final Widget home;

  const MoinsenMaterialApp({
    super.key,
    required this.themeMode,
    required this.home,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moinsen gRPC Command Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFECE5DD),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
      ),
      themeMode: themeMode,
      home: home,
    );
  }
}

class MoinsenApp extends ConsumerWidget {
  const MoinsenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return settingsAsync.when(
      loading: () {
        return const MoinsenMaterialApp(
          themeMode: ThemeMode.system,
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
      error: (error, _) {
        return MoinsenMaterialApp(
          themeMode: ThemeMode.system,
          home: Scaffold(
            body: Center(
              child: Text('Error: $error'),
            ),
          ),
        );
      },
      data: (settings) {
        return MoinsenMaterialApp(
          themeMode: settings.themeMode,
          home: const ConnectionScreen(),
        );
      },
    );
  }
}
