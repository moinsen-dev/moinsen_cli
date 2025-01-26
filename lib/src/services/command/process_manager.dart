import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/services/cli_logging_service.dart';
import 'package:moinsen_cli/src/services/command/response_handler.dart';

/// Manages the execution of processes and their input/output streams.
class ProcessManager {
  /// Creates a new instance of [ProcessManager].
  ProcessManager({
    required this.logger,
    required this.responseHandler,
  });

  /// Logger for process-related events.
  final CliLoggingService logger;

  /// Handler for sending responses back to the client.
  final ResponseHandler responseHandler;

  /// Currently running process.
  Process? _currentProcess;

  /// Whether there is a process currently running.
  bool get hasRunningProcess => _currentProcess != null;

  /// Executes a command in a new process.
  Future<void> executeCommand(
    String sessionId,
    String command, {
    bool streamingMode = false,
  }) async {
    try {
      logger.log(
        Level.info,
        'Executing command: $command',
        sessionId: sessionId,
      );

      // Split the command into executable and arguments
      final parts = command.split(' ');
      final executable = parts[0];
      final arguments = parts.length > 1 ? parts.sublist(1) : <String>[];

      // Start the process
      _currentProcess = await Process.start(
        executable,
        arguments,
        runInShell: true,
      );

      final completer = Completer<void>();
      final buffer = StringBuffer();

      // Handle stdout
      _currentProcess!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (output) {
          logger.log(Level.verbose, 'Process output: $output');
          if (streamingMode) {
            responseHandler.addResponse(
              output,
              sessionId,
              isStreaming: true,
            );
          } else {
            buffer.writeln(output);
          }
        },
        onError: (Object error) {
          logger.log(Level.error, 'Process stdout error: $error');
          responseHandler.addErrorResponse(error.toString(), sessionId);
          if (!completer.isCompleted) completer.complete();
        },
        onDone: () {
          if (!streamingMode && buffer.isNotEmpty) {
            responseHandler.addResponse(buffer.toString(), sessionId);
          }
          if (streamingMode) {
            responseHandler.addFinalResponse(sessionId);
          }
          if (!completer.isCompleted) completer.complete();
        },
      );

      // Handle stderr
      _currentProcess!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (error) {
          logger.log(Level.error, 'Process error: $error');
          responseHandler.addErrorResponse(error, sessionId);
        },
        onError: (Object error) {
          logger.log(Level.error, 'Process stderr error: $error');
          responseHandler.addErrorResponse(error.toString(), sessionId);
          if (!completer.isCompleted) completer.complete();
        },
      );

      await completer.future;
    } catch (e) {
      logger.log(Level.error, 'Error executing command: $e');
      responseHandler.addErrorResponse(e.toString(), sessionId);
    }
  }

  /// Sends input to the currently running process.
  void sendInput(String input) {
    if (_currentProcess != null) {
      _currentProcess!.stdin.writeln(input);
    }
  }

  /// Terminates the currently running process.
  void terminateCurrentProcess(String sessionId) {
    if (_currentProcess != null) {
      _currentProcess!.kill();
      _currentProcess = null;
      logger.log(
        Level.info,
        'Process terminated',
        sessionId: sessionId,
      );
    }
  }
}
