import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import 'package:moinsen_cli/moinsen_cli.dart';

import '../models/chat_message.dart';
import '../models/command_history.dart';
import '../providers/settings_provider.dart';

class CommandState {
  final List<ChatMessage> messages;
  final bool isServerTyping;
  final bool connected;
  final bool awaitingPrompt;
  final String currentResponseBuffer;

  const CommandState({
    this.messages = const [],
    this.isServerTyping = false,
    this.connected = false,
    this.awaitingPrompt = false,
    this.currentResponseBuffer = '',
  });

  CommandState copyWith({
    List<ChatMessage>? messages,
    bool? isServerTyping,
    bool? connected,
    bool? awaitingPrompt,
    String? currentResponseBuffer,
  }) {
    return CommandState(
      messages: messages ?? this.messages,
      isServerTyping: isServerTyping ?? this.isServerTyping,
      connected: connected ?? this.connected,
      awaitingPrompt: awaitingPrompt ?? this.awaitingPrompt,
      currentResponseBuffer:
          currentResponseBuffer ?? this.currentResponseBuffer,
    );
  }
}

class CommandNotifier extends AsyncNotifier<CommandState> {
  ClientChannel? _channel;
  CommandServiceClient? _client;
  final _requestStreamController = StreamController<CommandRequest>();
  StreamSubscription<CommandResponse>? _responseSubscription;
  Timer? _typingTimer;
  final String _currentSessionId = 'demo-session';

  @override
  Future<CommandState> build() async {
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

    try {
      final settings = await ref.watch(settingsNotifierProvider.future);
      await _initGrpcConnection(settings.serverName, settings.port);
      return state.value ?? const CommandState();
    } catch (e) {
      return CommandState(
        messages: [
          ChatMessage(
            text: 'Failed to initialize connection',
            isCommand: false,
          ),
        ],
      );
    }
  }

  Future<void> _initGrpcConnection(String serverName, int port) async {
    try {
      // Clean up existing connection first
      await _responseSubscription?.cancel();
      await _channel?.shutdown();

      // Log connection attempt
      state = AsyncData(CommandState(
        connected: false,
        messages: [
          ChatMessage(
            text:
                'Attempting to connect to gRPC server on $serverName:$port...',
            isCommand: false,
          ),
        ],
      ));

      _channel = ClientChannel(
        serverName,
        port: port,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          // Add timeout for connection attempts
          connectTimeout: Duration(seconds: 5),
          // Add keepalive ping
          idleTimeout: Duration(seconds: 10),
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

      _client = CommandServiceClient(_channel!);

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

      state = AsyncData(CommandState(
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

      state = AsyncData(CommandState(
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
      state = AsyncData(state.value!.copyWith(connected: false));

      final settings = await ref.read(settingsNotifierProvider.future);
      await _initGrpcConnection(settings.serverName, settings.port);
    } catch (e) {
      _handleError('Reconnection failed: ${e.toString()}');
    }
  }

  void _handleResponse(CommandResponse response) {
    _appendToCurrentResponse(response.outputData);

    if (response.isPrompt) {
      state = AsyncData(state.value!.copyWith(
        awaitingPrompt: true,
        isServerTyping: false,
      ));
    }
  }

  void _handleError(dynamic error) {
    final currentState = state.value ?? const CommandState();
    state = AsyncData(currentState.copyWith(
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
    final currentState = state.value ?? const CommandState();
    state = AsyncData(currentState.copyWith(
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

  void _appendToCurrentResponse(String text) {
    final currentState = state.value ?? const CommandState();
    final newBuffer = '${currentState.currentResponseBuffer}$text\n';

    state = AsyncData(currentState.copyWith(
      currentResponseBuffer: newBuffer,
      isServerTyping: true,
    ));

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 800), () {
      if (newBuffer.isNotEmpty) {
        final timerState = state.value ?? const CommandState();
        state = AsyncData(timerState.copyWith(
          messages: [
            ...timerState.messages,
            ChatMessage(
              text: newBuffer.trim(),
              isCommand: false,
              lines: newBuffer.trim().split('\n'),
            ),
          ],
          currentResponseBuffer: '',
          isServerTyping: false,
        ));
      }
    });
  }

  Future<void> sendCommand(String command) async {
    final currentState = state.value ?? const CommandState();
    if (command.isEmpty || _client == null || !currentState.connected) {
      _handleError('Cannot send command: Client not connected');
      return;
    }

    try {
      state = AsyncData(currentState.copyWith(
        messages: [
          ...currentState.messages,
          ChatMessage(
            text: command,
            isCommand: true,
          ),
        ],
      ));

      await CommandHistoryDatabase.instance.create(
        CommandHistory(
          command: command,
          timestamp: DateTime.now(),
        ),
      );

      final request = CommandRequest(
        sessionId: _currentSessionId,
        inputData: 'START:$command',
        isInteractiveAnswer: false,
      );

      _requestStreamController.add(request);
    } catch (e) {
      _handleError('Failed to send command: ${e.toString()}');
    }
  }

  Future<void> sendPromptAnswer(String answer) async {
    final currentState = state.value ?? const CommandState();
    if (answer.isEmpty || _client == null || !currentState.connected) {
      _handleError('Cannot send prompt answer: Client not connected');
      return;
    }

    try {
      state = AsyncData(currentState.copyWith(
        messages: [
          ...currentState.messages,
          ChatMessage(
            text: answer,
            isCommand: true,
          ),
        ],
        awaitingPrompt: false,
      ));

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

final commandProvider = AsyncNotifierProvider<CommandNotifier, CommandState>(
    () => CommandNotifier());
