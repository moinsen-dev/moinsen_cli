import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _portController = TextEditingController();
  final _secretKeyController = TextEditingController();
  bool _obscureSecretKey = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsNotifierProvider).value;
      if (settings != null) {
        _serverController.text = settings.serverName;
        _portController.text = settings.port.toString();
        _secretKeyController.text = settings.secretKey ?? '';
      }
    });
  }

  @override
  void dispose() {
    _serverController.dispose();
    _portController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      ref.read(settingsNotifierProvider.notifier).updateServerSettings(
            serverName: _serverController.text,
            port: int.parse(_portController.text),
          );
      ref.read(settingsNotifierProvider.notifier).updateSecretKey(
            _secretKeyController.text.isEmpty
                ? null
                : _secretKeyController.text,
          );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (settings) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Dark'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.settings_brightness),
                    label: Text('System'),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (Set<ThemeMode> selected) {
                  ref
                      .read(settingsNotifierProvider.notifier)
                      .updateThemeMode(selected.first);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Font Size',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: settings.fontSize,
                min: 12,
                max: 24,
                divisions: 12,
                label: settings.fontSize.toStringAsFixed(1),
                onChanged: (value) {
                  ref
                      .read(settingsNotifierProvider.notifier)
                      .updateFontSize(value);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Server Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _serverController,
                decoration: InputDecoration(
                  labelText: 'Server Name',
                  hintText: 'localhost',
                  suffixIcon: _serverController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _serverController.clear();
                            });
                          },
                        )
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a server name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portController,
                decoration: InputDecoration(
                  labelText: 'Port',
                  hintText: '50051',
                  suffixIcon: _portController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _portController.clear();
                            });
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a port number';
                  }
                  final port = int.tryParse(value);
                  if (port == null || port <= 0 || port > 65535) {
                    return 'Please enter a valid port number (1-65535)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _secretKeyController,
                decoration: InputDecoration(
                  labelText: 'Secret Key',
                  hintText: 'Optional',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _obscureSecretKey
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureSecretKey = !_obscureSecretKey;
                          });
                        },
                      ),
                      if (_secretKeyController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _secretKeyController.clear();
                            });
                          },
                        ),
                    ],
                  ),
                ),
                obscureText: _obscureSecretKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
