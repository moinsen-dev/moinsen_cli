import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';
import 'package:moinsen_cli/moinsen_cli.dart';

import '../models/chat_message.dart';
import '../models/command_history.dart';
import '../models/settings.dart';
import '../providers/settings_provider.dart';

final _log = Logger('CommandProvider');

class CommandState {
  final bool connected;
  final bool isServerTyping;
  final bool awaitingPrompt;
  final List<ChatMessage> messages;
  final String currentResponseBuffer;
  final DateTime? responseStartTime;

  CommandState({
    this.connected = false,
    this.isServerTyping = false,
    this.awaitingPrompt = false,
    this.messages = const [],
    this.currentResponseBuffer = '',
    this.responseStartTime,
  });

  CommandState copyWith({
    bool? connected,
    bool? isServerTyping,
    bool? awaitingPrompt,
    List<ChatMessage>? messages,
    String? currentResponseBuffer,
    DateTime? responseStartTime,
  }) {
    return CommandState(
      connected: connected ?? this.connected,
      isServerTyping: isServerTyping ?? this.isServerTyping,
      awaitingPrompt: awaitingPrompt ?? this.awaitingPrompt,
      messages: messages ?? this.messages,
      currentResponseBuffer:
          currentResponseBuffer ?? this.currentResponseBuffer,
      responseStartTime: responseStartTime ?? this.responseStartTime,
    );
  }
}

class CommandNotifier extends StateNotifier<AsyncValue<CommandState>> {
  final Ref ref;
  ClientChannel? _channel;
  CommandServiceClient? _client;
  final _requestStreamController = StreamController<CommandRequest>();
  StreamSubscription<CommandResponse>? _responseSubscription;
  Timer? _typingTimer;
  final String _currentSessionId = 'demo-session';

  CommandNotifier(this.ref) : super(AsyncValue.data(CommandState())) {
    // Initialize logging with more detailed format
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // Using debugPrint instead of print for better logging
      debugPrint(
          '${record.time}: ${record.level.name}: ${record.loggerName}: ${record.message}');
      if (record.error != null) {
        debugPrint('Error: ${record.error}');
        if (record.stackTrace != null) {
          debugPrint('Stack trace: ${record.stackTrace}');
        }
      }
    });

    ref.listen(settingsNotifierProvider, (previous, next) {
      next.whenData((settings) async {
        final prevSettings = previous?.value;
        if (prevSettings != null) {
          final needsReconnect =
              prevSettings.serverName != settings.serverName ||
                  prevSettings.port != settings.port;
          if (needsReconnect) {
            await _reconnect();
          }
        }
      });
    });

    // Initialize connection based on settings
    ref.read(settingsNotifierProvider.future).then((settings) async {
      try {
        await _initGrpcConnection(settings.serverName, settings.port);
      } catch (e) {
        state = AsyncValue.data(CommandState(
          messages: [
            ChatMessage(
              text: 'Failed to initialize connection',
              isCommand: false,
            ),
          ],
        ));
      }
    });
  }

  Future<bool> connect({
    required String host,
    required int port,
    String? security,
  }) async {
    try {
      await _responseSubscription?.cancel();
      await _channel?.shutdown();

      _channel = ClientChannel(
        host,
        port: port,
        options: ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          connectTimeout: const Duration(seconds: 5),
          idleTimeout: const Duration(seconds: 10),
        ),
      );

      if (_channel == null) {
        throw GrpcError.internal('Failed to create channel');
      }

      Map<String, String> metadata = {};
      if (security != null && security.isNotEmpty) {
        metadata['secret'] = security;
      }

      _client = CommandServiceClient(
        _channel!,
        options: CallOptions(metadata: metadata),
      );

      final responseStream =
          _client?.streamCommand(_requestStreamController.stream);
      if (responseStream == null) {
        throw GrpcError.internal('Failed to create response stream');
      }

      _responseSubscription = responseStream.listen(
        (response) => _handleResponse(response),
        onError: (error) => _handleError(error),
        onDone: () => _handleDone(),
      );

      state = AsyncValue.data(state.value!.copyWith(
        connected: true,
        messages: [
          ChatMessage(
            text: 'Successfully connected to gRPC server on $host:$port',
            isCommand: false,
          ),
        ],
      ));
      return true;
    } catch (e) {
      String errorMessage = 'Connection failed: ';
      if (e is GrpcError) {
        errorMessage += '${e.code} - ${e.message}';
      } else {
        errorMessage += e.toString();
      }

      state = AsyncValue.data(state.value!.copyWith(
        connected: false,
        messages: [
          ChatMessage(
            text: errorMessage,
            isCommand: false,
          ),
        ],
      ));
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _responseSubscription?.cancel();
      await _channel?.shutdown();
      _client = null;
      state = AsyncValue.data(state.value!.copyWith(connected: false));
    } catch (e) {
      _handleError('Disconnect failed: ${e.toString()}');
    }
  }

  Future<void> _initGrpcConnection(String serverName, int port) async {
    try {
      // Clean up existing connection first
      await _responseSubscription?.cancel();
      await _channel?.shutdown();

      // Log connection attempt
      state = AsyncValue.data(state.value!.copyWith(
        connected: false,
        messages: [
          ChatMessage(
            text:
                'Attempting to connect to gRPC server on $serverName:$port...',
            isCommand: false,
          ),
        ],
      ));

      final settings = await Settings.load();
      Map<String, String> metadata = {};
      if (settings.secretKey != null && settings.secretKey!.isNotEmpty) {
        metadata['secret'] = settings.secretKey!;
      }

      _channel = ClientChannel(
        serverName,
        port: port,
        options: ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          // Add timeout for connection attempts
          connectTimeout: const Duration(seconds: 5),
          // Add keepalive ping
          idleTimeout: const Duration(seconds: 10),
        ),
      );

      if (_channel == null) {
        throw GrpcError.internal('Failed to create channel');
      }

      // Test the connection before proceeding
      final connection = await _channel?.getConnection();
      if (connection == null) {
        throw GrpcError.internal('Failed to create connection');
      }

      _client = CommandServiceClient(
        _channel!,
        options: CallOptions(metadata: metadata),
      );

      final responseStream =
          _client?.streamCommand(_requestStreamController.stream);
      if (responseStream == null) {
        throw GrpcError.internal('Failed to create response stream');
      }

      _responseSubscription = responseStream.listen(
        (response) => _handleResponse(response),
        onError: (error) => _handleError(error),
        onDone: () => _handleDone(),
      );

      if (_client == null || _responseSubscription == null) {
        throw GrpcError.internal(
            'Failed to initialize client or response stream');
      }

      state = AsyncValue.data(state.value!.copyWith(
        connected: true,
        messages: [
          ChatMessage(
            text: 'Successfully connected to gRPC server on $serverName:$port',
            isCommand: false,
          ),
        ],
      ));
    } catch (e) {
      String errorMessage = 'Connection failed: ';
      if (e is GrpcError) {
        errorMessage += '${e.code} - ${e.message}';
      } else {
        errorMessage += e.toString();
      }

      state = AsyncValue.data(state.value!.copyWith(
        connected: false,
        messages: [
          ChatMessage(
            text: errorMessage,
            isCommand: false,
          ),
        ],
      ));

      rethrow;
    }
  }

  Future<void> _reconnect() async {
    try {
      await _responseSubscription?.cancel();
      await _channel?.shutdown();
      _client = null;
      state = AsyncValue.data(state.value!.copyWith(connected: false));

      final settings = await ref.read(settingsNotifierProvider.future);
      await _initGrpcConnection(settings.serverName, settings.port);
    } catch (e) {
      _handleError('Reconnection failed: ${e.toString()}');
    }
  }

  void _handleResponse(CommandResponse response) {
    _log.fine('Raw response received: ${response.toString()}');
    final currentState = state.value!;

    // Log the response type and content
    _log.info('Response type: ${response.isPrompt ? "Prompt" : "Output"}');
    _log.info('Response content length: ${response.outputData.length}');

    if (response.outputData.isNotEmpty) {
      _log.info('Processing non-empty response');
      final lines = response.outputData.trim().split('\n');
      _log.fine('Response split into ${lines.length} lines');

      // Calculate execution time if available
      final executionTime = currentState.responseStartTime != null
          ? DateTime.now()
              .difference(currentState.responseStartTime!)
              .inMilliseconds
          : null;

      if (executionTime != null) {
        _log.info('Command execution time: ${executionTime}ms');
      }

      // Create new message
      final newMessage = ChatMessage(
        text: response.outputData.trim(),
        isCommand: false,
        lines: lines,
        executionTimeMs: executionTime,
      );

      _log.fine(
          'Adding new message to state: ${newMessage.text.substring(0, min(50, newMessage.text.length))}...');

      state = AsyncValue.data(currentState.copyWith(
        messages: [...currentState.messages, newMessage],
        isServerTyping: false,
        responseStartTime: null,
      ));
    } else if (response.isPrompt) {
      _log.info('Handling prompt response');
      state = AsyncValue.data(currentState.copyWith(
        awaitingPrompt: true,
        isServerTyping: false,
        responseStartTime: null,
      ));
    } else {
      _log.info('Handling empty non-prompt response');
      state = AsyncValue.data(currentState.copyWith(
        messages: [
          ...currentState.messages,
          ChatMessage(
            text: "Command executed successfully",
            isCommand: false,
          ),
        ],
        isServerTyping: false,
        responseStartTime: null,
      ));
    }
  }

  void _handleError(dynamic error) {
    final currentState = state.value!;
    state = AsyncValue.data(currentState.copyWith(
      messages: [
        ...currentState.messages,
        ChatMessage(
          text: 'ERROR: $error',
          isCommand: false,
        ),
      ],
      isServerTyping: false,
      connected: false,
    ));
  }

  void _handleDone() {
    final currentState = state.value!;
    state = AsyncValue.data(currentState.copyWith(
      messages: [
        ...currentState.messages,
        ChatMessage(
          text: 'Server closed the stream.',
          isCommand: false,
        ),
      ],
      isServerTyping: false,
      connected: false,
    ));
  }

  void deleteMessage(int index) {
    final currentState = state.value!;
    final newMessages = List<ChatMessage>.from(currentState.messages);
    if (index >= 0 && index < newMessages.length) {
      newMessages.removeAt(index);
      state = AsyncValue.data(currentState.copyWith(messages: newMessages));
    }
  }

  void sendCommand(String command) async {
    _log.info('Preparing to send command: $command');
    if (!state.value!.connected || _client == null) {
      _log.warning('Cannot send command - not connected or client is null');
      _handleError('Not connected to server');
      return;
    }

    final currentState = state.value!;
    _log.fine(
        'Current state - connected: ${currentState.connected}, typing: ${currentState.isServerTyping}');

    state = AsyncValue.data(currentState.copyWith(
      messages: [
        ...currentState.messages,
        ChatMessage(
          text: command,
          isCommand: true,
        ),
      ],
      isServerTyping: true,
      responseStartTime: DateTime.now(),
    ));

    try {
      await CommandHistoryDatabase.instance.create(
        CommandHistory(
          command: command,
          timestamp: DateTime.now(),
        ),
      );

      final request = CommandRequest(
        sessionId: _currentSessionId,
        inputData: command, // Removed START: prefix as it might cause issues
        isInteractiveAnswer: false,
      );

      _log.info('Sending command request: ${request.toString()}');
      _requestStreamController.add(request);
    } catch (e, stackTrace) {
      _log.severe('Error sending command', e, stackTrace);
      _handleError('Failed to send command: ${e.toString()}');
    }
  }

  void sendPromptAnswer(String answer) {
    if (!state.value!.connected ||
        !state.value!.awaitingPrompt ||
        _client == null) {
      return;
    }

    final currentState = state.value!;
    state = AsyncValue.data(currentState.copyWith(
      messages: [
        ...currentState.messages,
        ChatMessage(
          text: answer,
          isCommand: true,
        ),
      ],
      awaitingPrompt: false,
      isServerTyping: true,
    ));

    try {
      final request = CommandRequest(
        sessionId: _currentSessionId,
        inputData: answer,
        isInteractiveAnswer: true,
      );

      _requestStreamController.add(request);
    } catch (e) {
      _handleError('Failed to send prompt answer: ${e.toString()}');
    }
  }

  void cleanUp() {
    _typingTimer?.cancel();
    _responseSubscription?.cancel();
    _channel?.shutdown();
    _requestStreamController.close();
  }
}

final commandProvider =
    StateNotifierProvider<CommandNotifier, AsyncValue<CommandState>>(
  (ref) => CommandNotifier(ref),
);
