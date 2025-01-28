import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/generated/command.pb.dart';
import 'package:moinsen_cli/src/services/cli_logging_service.dart';
import 'package:moinsen_cli/src/services/command/handlers/command_handler.dart';
import 'package:moinsen_cli/src/services/command/process_manager.dart';

/// Handles all file-related operations
class FileCommandHandler implements CommandHandler {
  @override
  Future<void> execute({
    required String sessionId,
    required String input,
    required CommandRequest request,
    required ProcessManager processManager,
    required CliLoggingService logger,
  }) async {
    final request = CommandRequest.fromJson(input);
    final targetPath = request.path;
    final content = request.content;

    switch (request.commandType) {
      case CommandType.READ_FILE:
        await _readFile(targetPath, logger, sessionId);
      case CommandType.WRITE_FILE:
        await _writeFile(targetPath, content, logger, sessionId);
      case CommandType.DELETE_FILE:
        await _deleteFile(targetPath, logger, sessionId);
      case CommandType.CREATE_FILE:
        await _createFile(targetPath, content, logger, sessionId);
      case CommandType.CREATE_DIR:
        await _createDirectory(targetPath, logger, sessionId);
      case CommandType.DELETE_DIR:
        await _deleteDirectory(targetPath, logger, sessionId);
      case CommandType.COMMAND_TYPE_UNSPECIFIED:
        throw UnimplementedError('Unspecified command type not supported');
      case CommandType.COMMAND:
      case CommandType.INIT:
      case CommandType.LIST:
      case CommandType.CD:
      case CommandType.EXIT:
      case CommandType.SEARCH:
        throw UnimplementedError(
          '${request.commandType} not implemented in FileCommandHandler',
        );
    }
  }

  Future<void> _readFile(
    String filePath,
    CliLoggingService logger,
    String sessionId,
  ) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw FileSystemException('File not found', filePath);
      }
      file.readAsStringSync();
      logger.log(
        Level.info,
        'File read successfully: $filePath',
        sessionId: sessionId,
      );
    } catch (e) {
      logger.log(Level.error, 'Error reading file: $e', sessionId: sessionId);
      rethrow;
    }
  }

  Future<void> _writeFile(
    String filePath,
    String content,
    CliLoggingService logger,
    String sessionId,
  ) async {
    try {
      final file = File(filePath);
      file.writeAsStringSync(content);
      logger.log(
        Level.info,
        'File written successfully: $filePath',
        sessionId: sessionId,
      );
    } catch (e) {
      logger.log(Level.error, 'Error writing file: $e', sessionId: sessionId);
      rethrow;
    }
  }

  Future<void> _deleteFile(
    String filePath,
    CliLoggingService logger,
    String sessionId,
  ) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw FileSystemException('File not found', filePath);
      }
      file.deleteSync();
      logger.log(
        Level.info,
        'File deleted successfully: $filePath',
        sessionId: sessionId,
      );
    } catch (e) {
      logger.log(Level.error, 'Error deleting file: $e', sessionId: sessionId);
      rethrow;
    }
  }

  Future<void> _createFile(
    String filePath,
    String content,
    CliLoggingService logger,
    String sessionId,
  ) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        throw FileSystemException('File already exists', filePath);
      }
      file.createSync(recursive: true);
      if (content.isNotEmpty) {
        file.writeAsStringSync(content);
      }
      logger.log(
        Level.info,
        'File created successfully: $filePath',
        sessionId: sessionId,
      );
    } catch (e) {
      logger.log(Level.error, 'Error creating file: $e', sessionId: sessionId);
      rethrow;
    }
  }

  Future<void> _createDirectory(
    String dirPath,
    CliLoggingService logger,
    String sessionId,
  ) async {
    try {
      final directory = Directory(dirPath);
      if (directory.existsSync()) {
        throw FileSystemException('Directory already exists', dirPath);
      }
      directory.createSync(recursive: true);
      logger.log(
        Level.info,
        'Directory created successfully: $dirPath',
        sessionId: sessionId,
      );
    } catch (e) {
      logger.log(
        Level.error,
        'Error creating directory: $e',
        sessionId: sessionId,
      );
      rethrow;
    }
  }

  Future<void> _deleteDirectory(
    String dirPath,
    CliLoggingService logger,
    String sessionId,
  ) async {
    try {
      final directory = Directory(dirPath);
      if (!directory.existsSync()) {
        throw FileSystemException('Directory not found', dirPath);
      }
      directory.deleteSync(recursive: true);
      logger.log(
        Level.info,
        'Directory deleted successfully: $dirPath',
        sessionId: sessionId,
      );
    } catch (e) {
      logger.log(
        Level.error,
        'Error deleting directory: $e',
        sessionId: sessionId,
      );
      rethrow;
    }
  }
}
