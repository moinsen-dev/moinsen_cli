import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/services/cli_logging_service.dart';
import 'package:moinsen_cli/src/services/command/handlers/command_handler.dart';
import 'package:moinsen_cli/src/services/command/process_manager.dart';

/// Handles initialization operations
class InitCommandHandler implements CommandHandler {
  @override
  Future<void> execute({
    required String sessionId,
    required String input,
    required ProcessManager processManager,
    required CliLoggingService logger,
  }) async {
    try {
      // Set current directory as root
      final currentDir = Directory.current;

      logger.log(
        Level.info,
        'Initialized root directory: ${currentDir.path}',
        sessionId: sessionId,
      );

      // You might want to add additional initialization logic here
      // such as setting up workspace configuration, etc.
    } catch (e) {
      logger.log(
        Level.error,
        'Error during initialization: $e',
        sessionId: sessionId,
      );
      rethrow;
    }
  }
}
