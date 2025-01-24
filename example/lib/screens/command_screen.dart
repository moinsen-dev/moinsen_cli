import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/command_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/connection_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/command_input_widget.dart';
import '../widgets/typing_indicator.dart';

class CommandPage extends ConsumerStatefulWidget {
  const CommandPage({super.key});

  @override
  ConsumerState<CommandPage> createState() => _CommandPageState();
}

class _CommandPageState extends ConsumerState<CommandPage> {
  final TextEditingController _cmdController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _cmdController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendCommand(String command) {
    if (command.isEmpty) return;
    ref.read(commandProvider.notifier).sendCommand(command);
    _scrollToBottom();
  }

  void _sendPromptAnswer() {
    final promptText = _promptController.text.trim();
    if (promptText.isEmpty) return;

    ref.read(commandProvider.notifier).sendPromptAnswer(promptText);
    _promptController.clear();
    _scrollToBottom();
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commandState = ref.watch(commandProvider);

    return commandState.when(
      loading: () {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stack) {
        return Scaffold(
          body: Center(
            child: Text('Error: $error'),
          ),
        );
      },
      data: (state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Moinsen AI'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _openSettings,
                tooltip: 'Settings',
              ),
              if (state.connected)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    ref.read(commandProvider.notifier).disconnect();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const ConnectionScreen(),
                      ),
                    );
                  },
                  tooltip: 'Disconnect',
                ),
              if (state.connected)
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.circle, color: Colors.green, size: 12),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: () {
                      final settings =
                          ref.read(settingsNotifierProvider).valueOrNull;
                      if (settings != null) {
                        ref.read(commandProvider.notifier).connect(
                              host: settings.serverName,
                              port: settings.port,
                            );
                      }
                    },
                    child: const Tooltip(
                      message: 'Click to reconnect',
                      child: Icon(Icons.circle, color: Colors.red, size: 12),
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount:
                      state.messages.length + (state.isServerTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length) {
                      return const TypingIndicator();
                    }
                    final settings =
                        ref.watch(settingsNotifierProvider).valueOrNull;
                    return ChatMessageWidget(
                      message: state.messages[index],
                      fontSize: settings?.fontSize ?? 14.0,
                      onDelete: () {
                        ref.read(commandProvider.notifier).deleteMessage(index);
                      },
                      onEdit: (text) {
                        _cmdController.text = text;
                        _cmdController.selection = TextSelection.fromPosition(
                          TextPosition(offset: text.length),
                        );
                      },
                    );
                  },
                ),
              ),
              state.awaitingPrompt
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promptController,
                              decoration: const InputDecoration(
                                hintText: 'Enter your response...',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _sendPromptAnswer(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _sendPromptAnswer,
                          ),
                        ],
                      ),
                    )
                  : CommandInputWidget(
                      controller: _cmdController,
                      onSendCommand: _sendCommand,
                    ),
            ],
          ),
        );
      },
    );
  }
}
