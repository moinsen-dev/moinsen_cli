import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/generated/command.pb.dart';
import 'package:moinsen_cli/src/services/cli_logging_service.dart';
import 'package:moinsen_cli/src/services/command/command_service_impl.dart';
import 'package:moinsen_cli/src/services/command/response_handler.dart';
import 'package:path/path.dart' as p;

/// Manages command execution and response handling for all command types.
class ProcessManager {
  /// Creates a new instance of [ProcessManager].
  ProcessManager({
    required CliLoggingService logger,
    required ResponseHandler responseHandler,
    required CommandServiceImpl commandService,
  })  : _logger = logger,
        _responseHandler = responseHandler,
        _commandService = commandService;

  /// Logger for process-related events.
  final CliLoggingService _logger;

  /// Handler for sending responses back to the client.
  final ResponseHandler _responseHandler;

  /// Command service instance
  final CommandServiceImpl _commandService;

  /// Currently running process.
  Process? _currentProcess;

  /// Whether there is a process currently running.
  bool get hasRunningProcess => _currentProcess != null;

  /// Gets the command service instance
  CommandServiceImpl get commandService => _commandService;

  /// Executes a command based on its type and handles the response
  Future<void> executeCommand({
    required String sessionId,
    required String input,
    required CommandRequest request,
    bool streamingMode = false,
  }) async {
    try {
      _logger.log(
        Level.info,
        'Executing ${request.commandType} command',
        sessionId: sessionId,
      );

      switch (request.commandType) {
        case CommandType.COMMAND:
          await _executeShellCommand(
            sessionId: sessionId,
            command: request.inputData,
            streamingMode: streamingMode,
          );
        case CommandType.LIST:
          await _executeListCommand(
            sessionId: sessionId,
            path: request.path,
          );
        // Add other command types here
        default:
          sendErrorResponse(
            sessionId: sessionId,
            error: 'Unsupported command type: ${request.commandType}',
            commandType: request.commandType,
          );
      }
    } catch (e) {
      sendErrorResponse(
        sessionId: sessionId,
        error: 'Error executing command: $e',
        commandType: request.commandType,
      );
    }
  }

  /// Executes a shell command
  Future<void> _executeShellCommand({
    required String sessionId,
    required String command,
    bool streamingMode = false,
  }) async {
    try {
      final parts = command.split(' ');
      final executable = parts[0];
      final arguments = parts.length > 1 ? parts.sublist(1) : <String>[];

      _currentProcess = await Process.start(
        executable,
        arguments,
        runInShell: true,
      );

      final completer = Completer<void>();
      final buffer = StringBuffer();

      _currentProcess!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (output) {
          _logger.log(Level.verbose, 'Process output: $output');
          if (streamingMode) {
            sendStreamingResponse(
              sessionId: sessionId,
              output: output,
              commandType: CommandType.COMMAND,
            );
          } else {
            buffer.writeln(output);
          }
        },
        onError: (Object error) {
          _logger.log(Level.error, 'Process stdout error: $error');
          sendErrorResponse(
            sessionId: sessionId,
            error: error.toString(),
            commandType: CommandType.COMMAND,
          );
          if (!completer.isCompleted) completer.complete();
        },
        onDone: () {
          if (!streamingMode && buffer.isNotEmpty) {
            sendResponse(
              sessionId: sessionId,
              output: buffer.toString(),
              commandType: CommandType.COMMAND,
            );
          }
          if (streamingMode) {
            sendFinalResponse(sessionId: sessionId);
          }
          if (!completer.isCompleted) completer.complete();
        },
      );

      _currentProcess!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (error) {
          _logger.log(Level.error, 'Process error: $error');
          sendErrorResponse(
            sessionId: sessionId,
            error: error,
            commandType: CommandType.COMMAND,
          );
        },
        onError: (Object error) {
          _logger.log(Level.error, 'Process stderr error: $error');
          sendErrorResponse(
            sessionId: sessionId,
            error: error.toString(),
            commandType: CommandType.COMMAND,
          );
          if (!completer.isCompleted) completer.complete();
        },
      );

      await completer.future;
    } catch (e) {
      _logger.log(Level.error, 'Error executing shell command: $e');
      sendErrorResponse(
        sessionId: sessionId,
        error: e.toString(),
        commandType: CommandType.COMMAND,
      );
    }
  }

  /// Executes a list command
  Future<void> _executeListCommand({
    required String sessionId,
    required String path,
  }) async {
    try {
      final targetPath = path.isEmpty ? '.' : path;
      final directory = Directory(targetPath);

      if (!directory.existsSync()) {
        sendErrorResponse(
          sessionId: sessionId,
          error: 'Directory not found: $targetPath',
          commandType: CommandType.LIST,
        );
        return;
      }

      final fileList = <FileInfo>[];
      await _listDirectoryRecursively(directory, fileList);

      _logger.log(
        Level.info,
        'Listed ${fileList.length} items in directory: $targetPath',
        sessionId: sessionId,
      );

      // Create a formatted string representation for output
      final formattedOutput = fileList.map((file) {
        final type = file.isDirectory ? 'd' : '-';
        final size = file.size.toString().padLeft(10);
        final date =
            DateTime.fromMillisecondsSinceEpoch(file.modifiedTime.toInt())
                .toString()
                .padRight(26);
        // Use relative path from the target directory
        final relativePath = p.relative(file.name, from: targetPath);
        return '$type ${relativePath.padRight(50)} $size $date';
      }).join('\n');

      // Send both the formatted output and the file list
      final response = CommandResponse()
        ..sessionId = sessionId
        ..success = true
        ..commandType = CommandType.LIST
        ..currentFolder = Directory.current.path
        ..fileList.addAll(fileList)
        ..outputData = formattedOutput
        ..isComplete = true;

      _responseHandler.addCommandResponse(response);
    } catch (e) {
      sendErrorResponse(
        sessionId: sessionId,
        error: 'Error listing directory: $e',
        commandType: CommandType.LIST,
      );
    }
  }

  /// Recursively lists all files and directories
  Future<void> _listDirectoryRecursively(
    Directory directory,
    List<FileInfo> fileList,
  ) async {
    try {
      await for (final entity in directory.list(followLinks: false)) {
        final stat = await entity.stat();
        final isDir = entity is Directory;

        fileList.add(
          FileInfo(
            name: entity.path, // Store full path
            isDirectory: isDir,
            size: Int64(stat.size),
            modifiedTime: Int64(stat.modified.millisecondsSinceEpoch),
          ),
        );

        // Recursively process subdirectories
        if (isDir) {
          await _listDirectoryRecursively(entity, fileList);
        }
      }
    } catch (e) {
      _logger.log(
        Level.error,
        'Error listing directory ${directory.path}: $e',
      );
      // Continue with other directories even if one fails
    }
  }

  /// Sends a standard response
  void sendResponse({
    required String sessionId,
    required String output,
    required CommandType commandType,
  }) {
    final response = CommandResponse()
      ..sessionId = sessionId
      ..outputData = output
      ..success = true
      ..commandType = commandType
      ..currentFolder = Directory.current.path
      ..isComplete = true;

    _responseHandler.addCommandResponse(response);
  }

  /// Sends a streaming response
  void sendStreamingResponse({
    required String sessionId,
    required String output,
    required CommandType commandType,
  }) {
    final response = CommandResponse()
      ..sessionId = sessionId
      ..outputData = output
      ..success = true
      ..commandType = commandType
      ..currentFolder = Directory.current.path
      ..isPartial = true
      ..isComplete = false;

    _responseHandler.addCommandResponse(response);
  }

  /// Sends an error response
  void sendErrorResponse({
    required String sessionId,
    required String error,
    required CommandType commandType,
  }) {
    final response = CommandResponse()
      ..sessionId = sessionId
      ..success = false
      ..commandType = commandType
      ..errorMessage = error
      ..currentFolder = Directory.current.path
      ..isComplete = true;

    _responseHandler.addCommandResponse(response);
  }

  /// Sends a final response for streaming mode
  void sendFinalResponse({required String sessionId}) {
    final response = CommandResponse()
      ..sessionId = sessionId
      ..success = true
      ..isPartial = false
      ..isComplete = true;

    _responseHandler.addCommandResponse(response);
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
      _logger.log(
        Level.info,
        'Process terminated',
        sessionId: sessionId,
      );
    }
  }
}
