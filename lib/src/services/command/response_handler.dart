import 'dart:async';

import 'package:fixnum/fixnum.dart' show Int64;
import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/generated/command.pb.dart';
import 'package:moinsen_cli/src/services/cli_logging_service.dart';

/// Handles the streaming of command responses.
class ResponseHandler {
  /// Creates a new instance of [ResponseHandler].
  ResponseHandler({required CliLoggingService logger}) : _logger = logger;

  final CliLoggingService _logger;

  /// Stream controller for command responses.
  StreamController<CommandResponse>? _controller;

  /// The stream of command responses.
  Stream<CommandResponse>? get responseStream => _controller?.stream;

  /// Initializes the response handler.
  void initialize() {
    _controller = StreamController<CommandResponse>();
  }

  /// Adds a response to the stream.
  void addResponse(
    String output,
    String sessionId, {
    bool isPrompt = false,
    bool isStreaming = false,
  }) {
    if (_controller == null || _controller!.isClosed) return;

    final response = CommandResponse(
      sessionId: sessionId,
      outputData: output,
      isPrompt: isPrompt,
      timestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      commandType: CommandType.COMMAND_TYPE_UNSPECIFIED,
      success: true,
      isPartial: isStreaming,
      isComplete: !isStreaming,
    );

    _controller!.add(response);
  }

  /// Adds a final response to the stream for streaming mode
  void addFinalResponse(String sessionId) {
    if (_controller == null || _controller!.isClosed) return;

    final response = CommandResponse(
      sessionId: sessionId,
      outputData: '',
      isPrompt: false,
      timestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      commandType: CommandType.COMMAND_TYPE_UNSPECIFIED,
      success: true,
      isPartial: false,
      isComplete: true,
    );

    _controller!.add(response);
  }

  /// Adds an error response to the stream.
  void addErrorResponse(String error, String sessionId) {
    if (_controller == null || _controller!.isClosed) return;

    final response = CommandResponse(
      sessionId: sessionId,
      outputData: error,
      isPrompt: false,
      timestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      commandType: CommandType.COMMAND_TYPE_UNSPECIFIED,
      success: false,
      errorMessage: error,
      isPartial: false,
      isComplete: true,
    );

    _controller!.add(response);
  }

  /// Adds a command response directly to the stream.
  void addCommandResponse(CommandResponse response) {
    if (_controller == null || _controller!.isClosed) {
      _logger.log(
        Level.error,
        'Response handler is not initialized or is closed',
      );
      return;
    }

    response.timestamp = Int64(DateTime.now().millisecondsSinceEpoch);
    response.isComplete = true;
    _controller!.add(response);

    _logger.log(
      Level.verbose,
      'Sent response: ${response.commandType}, success: ${response.success}, '
      'output length: ${response.outputData.length}, '
      'files: ${response.fileList.length}',
    );
  }

  /// Disposes of the response handler.
  Future<void> dispose() async {
    await _controller?.close();
    _controller = null;
  }
}
