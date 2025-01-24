import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/settings.dart';
import '../providers/command_provider.dart';
import '../providers/settings_provider.dart';
import '../services/toast_service.dart';
import 'home_screen.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _securityController = TextEditingController();
  bool _isConnecting = false;
  bool _obscureSecurityToken = true;

  @override
  void initState() {
    super.initState();
    // Load settings after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsNotifierProvider).value;
      if (settings != null) {
        _hostController.text = settings.serverName;
        _portController.text = settings.port.toString();
        _securityController.text = settings.secretKey ?? '';
      }
    });
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _securityController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isConnecting = true);

    try {
      // Save settings first
      final settings = await Settings.load();
      settings.serverName = _hostController.text;
      settings.port = int.parse(_portController.text);
      settings.secretKey =
          _securityController.text.isEmpty ? null : _securityController.text;
      await settings.save();

      // Update provider settings
      if (mounted) {
        await ref.read(settingsNotifierProvider.notifier).updateServerSettings(
              serverName: settings.serverName,
              port: settings.port,
            );
        if (settings.secretKey != null && mounted) {
          await ref.read(settingsNotifierProvider.notifier).updateSecretKey(
                settings.secretKey,
              );
        }
      }

      // Attempt connection
      if (mounted) {
        final success = await ref.read(commandProvider.notifier).connect(
              host: settings.serverName,
              port: settings.port,
              security: settings.secretKey,
            );

        if (success && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (mounted) {
          ToastService.showError(
            'Failed to connect. Please check your settings.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Server'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/moinsen-bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                elevation: 8,
                color: Theme.of(context).cardColor.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _hostController,
                          decoration: InputDecoration(
                            labelText: 'Host',
                            border: const OutlineInputBorder(),
                            suffixIcon: _hostController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _hostController.clear();
                                      });
                                    },
                                  )
                                : null,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a host';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _portController,
                          decoration: InputDecoration(
                            labelText: 'Port',
                            border: const OutlineInputBorder(),
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
                              return 'Please enter a port';
                            }
                            final port = int.tryParse(value);
                            if (port == null || port <= 0 || port > 65535) {
                              return 'Please enter a valid port number (1-65535)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _securityController,
                          decoration: InputDecoration(
                            labelText: 'Security Token (Optional)',
                            border: const OutlineInputBorder(),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_securityController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _securityController.clear();
                                      });
                                    },
                                  ),
                                IconButton(
                                  icon: Icon(
                                    _obscureSecurityToken
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureSecurityToken =
                                          !_obscureSecurityToken;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          obscureText: _obscureSecurityToken,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isConnecting ? null : _connect,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isConnecting
                              ? const CircularProgressIndicator()
                              : const Text('Connect'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
