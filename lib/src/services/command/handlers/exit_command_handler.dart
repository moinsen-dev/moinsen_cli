import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/generated/command.pb.dart';
import 'package:moinsen_cli/src/services/cli_logging_service.dart';
import 'package:moinsen_cli/src/services/command/handlers/command_handler.dart';
import 'package:moinsen_cli/src/services/command/process_manager.dart';

/// Handles exit command operations
class ExitCommandHandler implements CommandHandler {
  @override
  Future<void> execute({
    required String sessionId,
    required CommandRequest request,
    required String input,
    required ProcessManager processManager,
    required CliLoggingService logger,
  }) async {
    try {
      processManager.terminateCurrentProcess(sessionId);
      logger.log(
        Level.info,
        'Session terminated: $sessionId',
        sessionId: sessionId,
      );
    } catch (e) {
      logger.log(
        Level.error,
        'Error during exit: $e',
        sessionId: sessionId,
      );
      rethrow;
    }
  }
}
