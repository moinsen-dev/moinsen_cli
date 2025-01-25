import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fixnum/fixnum.dart' show Int64;
import 'package:grpc/grpc.dart' as $grpc;
import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/generated/command.pb.dart' as pb;
import 'package:moinsen_cli/src/generated/command.pbgrpc.dart' as pbgrpc;

/// Implementation of the gRPC command service.
///
/// This service handles bidirectional streaming of commands and responses between
/// the client and server. It extends [pbgrpc.CommandServiceBase] which is generated
/// from the protobuf definitions.
class CommandServiceImpl extends pbgrpc.CommandServiceBase {
  /// Creates a new instance of [CommandServiceImpl].
  ///
  /// The [secret] parameter is optional and can be used to secure the service.
  /// If provided, clients must include this secret in their metadata.
  ///
  /// The [logger] parameter is optional and defaults to a new [Logger] instance
  /// if not provided.
  ///
  /// The [logFile] parameter is optional and can be used to log command execution.
  CommandServiceImpl({
    this.secret,
    Logger? logger,
    this.logFile,
  }) : _logger = logger ?? Logger();

  /// Optional secret key for authentication.
  final String? secret;

  /// Logger instance for service-wide logging.
  final Logger _logger;

  /// Optional log file for command logging
  final File? logFile;

  /// The currently running process.
  ///
  /// Only one process can be active at a time. Starting a new process while
  /// one is running will terminate the existing process.
  Process? _currentProcess;

  /// Stream controller for sending responses back to the client.
  ///
  /// Each streaming session has its own controller instance.
  StreamController<pb.CommandResponse>? _responseController;

  /// Buffer for collecting command output
  StringBuffer? _outputBuffer;

  /// Timer for flushing buffered output
  Timer? _flushTimer;

  /// Sends a response to the client with buffered output.
  ///
  /// [sessionId] is the unique identifier for the client session.
  /// [text] is the text to send.
  /// [isPrompt] indicates if this is an interactive prompt.
  void _sendResponse(String sessionId, String text, {bool isPrompt = false}) {
    if (_responseController == null || _responseController!.isClosed) return;

    _outputBuffer ??= StringBuffer();
    _outputBuffer!.writeln(text);

    // Cancel existing timer if any
    _flushTimer?.cancel();

    // Set a timer to flush the buffer after a short delay
    _flushTimer = Timer(const Duration(milliseconds: 50), () {
      if (_outputBuffer != null &&
          _outputBuffer!.isNotEmpty &&
          !(_responseController?.isClosed ?? true)) {
        final response = pb.CommandResponse(
          sessionId: sessionId,
          outputData: _outputBuffer.toString().trimRight(),
          isPrompt: isPrompt,
          timestamp: Int64(DateTime.now().millisecondsSinceEpoch),
        );
        _responseController?.add(response);
        _outputBuffer!.clear();
      }
    });
  }

  /// Internal logging utility that adds session context to log messages.
  ///
  /// [level] determines the severity of the log message.
  /// [message] is the actual log message.
  /// [sessionId] is optional and adds session context to the log if provided.
  void _log(Level level, String message, {String? sessionId}) {
    final sessionInfo = sessionId != null ? '[Session:$sessionId]' : '';
    switch (level) {
      case Level.error:
        _logger.err('$sessionInfo $message');
      case Level.warning:
        _logger.warn('$sessionInfo $message');
      case Level.info:
        _logger.info('$sessionInfo $message');
      case Level.verbose:
        _logger.detail('$sessionInfo $message');
      case Level.debug:
        _logger.detail('$sessionInfo $message');
      case Level.critical:
        _logger.err('$sessionInfo $message');
      case Level.quiet:
        // Do nothing in quiet mode
        break;
    }
  }

  void _logToFile(Map<String, dynamic> data) {
    if (logFile == null) return;

    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      ...data,
    };

    logFile!.writeAsStringSync(
      '${jsonEncode(logEntry)}\n',
      mode: FileMode.append,
    );
  }

  /// Implements the bidirectional streaming RPC method defined in the protobuf.
  ///
  /// This method handles the main communication between client and server:
  /// - Validates client authentication if a secret is set
  /// - Processes incoming commands
  /// - Manages process lifecycle
  /// - Streams responses back to the client
  ///
  /// The method yields a stream of [pb.CommandResponse] messages.
  @override
  Stream<pb.CommandResponse> streamCommand(
    $grpc.ServiceCall call,
    Stream<pb.CommandRequest> request,
  ) async* {
    final clientAddress = call.clientMetadata?['x-forwarded-for'] ?? 'unknown';
    final clientPort = call.clientMetadata?['port'] ?? 'unknown';
    final sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';

    _log(
      Level.info,
      'New client connection from $clientAddress:$clientPort (Session: $sessionId)',
    );

    // Clean up any existing resources for this session
    await _responseController?.close();
    _responseController = StreamController<pb.CommandResponse>.broadcast();
    _outputBuffer?.clear();
    _outputBuffer = StringBuffer();
    _flushTimer?.cancel();

    try {
      // Validate client authentication if secret is set
      final metadata = call.clientMetadata ?? {};
      final clientSecret = metadata['secret']?.toString();

      if (secret != null && secret!.isNotEmpty) {
        if (clientSecret != secret) {
          _log(Level.error, 'Authentication failed for client $clientAddress');
          throw const $grpc.GrpcError.unauthenticated('Invalid secret');
        }
      }

      // Send initial connection success response
      final initialResponse = pb.CommandResponse(
        sessionId: 'initial',
        outputData:
            'Successfully connected to gRPC server on localhost:$clientPort',
        timestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      );
      yield initialResponse;

      // Create a completer to signal when we should close the stream
      final streamCloser = Completer<void>();

      // Process requests in a separate async operation
      unawaited(
        _processRequests(request, sessionId).whenComplete(() {
          _log(Level.info, 'Request stream completed for session $sessionId');
          if (!streamCloser.isCompleted) {
            streamCloser.complete();
          }
        }),
      );

      // Keep yielding responses until explicitly closed
      try {
        await for (final response in _responseController!.stream) {
          if (response.outputData.isNotEmpty) {
            yield response;
          }
        }
      } catch (e) {
        _log(Level.error, 'Error in response stream: $e');
        rethrow;
      }

      // Wait for the stream to be explicitly closed
      await streamCloser.future;
    } catch (e) {
      _log(Level.error, 'Stream error: $e');
      rethrow;
    } finally {
      // Clean up resources when the stream ends
      _log(
        Level.info,
        'Cleaning up connection resources for session $sessionId',
      );
      if (_currentProcess != null) {
        _log(Level.info, 'Terminating current process for session $sessionId');
        _currentProcess!.kill();
        _currentProcess = null;
      }
      await _responseController?.close();
      _flushTimer?.cancel();
      _outputBuffer?.clear();
      _outputBuffer = null;
    }
  }

  Future<void> _processRequests(
    Stream<pb.CommandRequest> requests,
    String sessionId,
  ) async {
    try {
      await for (final request in requests) {
        final input = request.inputData;
        final isInteractiveAnswer = request.isInteractiveAnswer;

        _log(Level.info, 'Received request: $input', sessionId: sessionId);

        // Log command received
        if (input.startsWith('START:') && !isInteractiveAnswer) {
          final commandToRun = input.substring('START:'.length).trim();
          _logToFile({
            'event': 'command_received',
            'session_id': sessionId,
            'command': commandToRun,
            'type': 'command',
          });

          // Terminate existing process if one is running
          if (_currentProcess != null) {
            _log(
              Level.warning,
              'Terminating existing process',
              sessionId: sessionId,
            );
            _currentProcess!.kill();
            _currentProcess = null;
          }

          try {
            _currentProcess = await Process.start(
              'bash',
              ['-c', commandToRun],
            );

            _logToFile({
              'event': 'command_started',
              'session_id': sessionId,
              'command': commandToRun,
              'pid': _currentProcess!.pid,
            });

            // Handle process stdout
            _currentProcess!.stdout
                .transform(const SystemEncoding().decoder)
                .transform(const LineSplitter())
                .listen(
              (line) {
                final isPrompt = line.contains('?(y/n)');
                if (isPrompt) {
                  _logToFile({
                    'event': 'interactive_prompt',
                    'session_id': sessionId,
                    'prompt': line,
                  });
                }
                _sendResponse(sessionId, line, isPrompt: isPrompt);
                _log(Level.verbose, 'STDOUT: $line', sessionId: sessionId);
              },
              cancelOnError: false,
            );

            // Handle process stderr
            _currentProcess!.stderr
                .transform(const SystemEncoding().decoder)
                .transform(const LineSplitter())
                .listen(
              (line) {
                _logToFile({
                  'event': 'command_error',
                  'session_id': sessionId,
                  'error': line,
                });
                _sendResponse(sessionId, '[ERR] $line');
                _log(Level.error, 'STDERR: $line', sessionId: sessionId);
              },
              cancelOnError: false,
            );

            // Handle process completion
            unawaited(
              _currentProcess!.exitCode.then((exitCode) {
                _logToFile({
                  'event': 'command_completed',
                  'session_id': sessionId,
                  'exit_code': exitCode,
                  'status': exitCode == 0 ? 'success' : 'error',
                });
                _log(
                  Level.info,
                  'Process completed with exit code: $exitCode',
                  sessionId: sessionId,
                );
                _sendResponse(
                  sessionId,
                  'Command completed with exit code: $exitCode',
                );
                _currentProcess = null;
              }),
            );
          } catch (e) {
            _logToFile({
              'event': 'command_failed',
              'session_id': sessionId,
              'error': e.toString(),
            });
            _log(
              Level.error,
              'Failed to start process: $e',
              sessionId: sessionId,
            );
            _sendResponse(sessionId, 'Failed to start process: $e');
          }
        } else if (isInteractiveAnswer && _currentProcess != null) {
          _logToFile({
            'event': 'interactive_input',
            'session_id': sessionId,
            'input': input,
          });
          _log(
            Level.verbose,
            'Sending interactive input to process',
            sessionId: sessionId,
          );
          _currentProcess!.stdin.writeln(input);
        } else {
          _log(
            Level.warning,
            'Unknown command or no process running',
            sessionId: sessionId,
          );
          _sendResponse(sessionId, 'Unknown command or no process running.');
        }
      }
    } catch (e) {
      _logToFile({
        'event': 'stream_error',
        'session_id': sessionId,
        'error': e.toString(),
      });
      _log(Level.error, 'Error in request stream: $e', sessionId: sessionId);
      rethrow;
    }
  }
}
