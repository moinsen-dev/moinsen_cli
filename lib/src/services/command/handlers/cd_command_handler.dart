import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/generated/command.pb.dart';
import 'package:moinsen_cli/src/services/cli_logging_service.dart';
import 'package:moinsen_cli/src/services/command/handlers/command_handler.dart';
import 'package:moinsen_cli/src/services/command/process_manager.dart';

/// Handles directory change operations
class CdCommandHandler implements CommandHandler {
  @override
  Future<void> execute({
    required String sessionId,
    required String input,
    required ProcessManager processManager,
    required CliLoggingService logger,
  }) async {
    try {
      final request = CommandRequest.fromJson(input);
      final targetPath = request.path;

      if (targetPath.isEmpty) {
        // Change to home directory if no path specified
        final home =
            Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
        if (home == null) {
          throw const FileSystemException('Could not determine home directory');
        }
        Directory.current = home;
        logger.log(
          Level.info,
          'Changed to home directory: $home',
          sessionId: sessionId,
        );
        return;
      }

      final directory = Directory(targetPath);
      if (!directory.existsSync()) {
        throw FileSystemException('Directory not found', targetPath);
      }

      Directory.current = directory.path;
      logger.log(
        Level.info,
        'Changed directory to: ${directory.path}',
        sessionId: sessionId,
      );
    } catch (e) {
      logger.log(
        Level.error,
        'Error changing directory: $e',
        sessionId: sessionId,
      );
      rethrow;
    }
  }
}
