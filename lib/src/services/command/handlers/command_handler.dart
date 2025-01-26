import 'package:moinsen_cli/src/services/cli_logging_service.dart';
import 'package:moinsen_cli/src/services/command/process_manager.dart';

/// Base interface for all command handlers
abstract class CommandHandler {
  /// Executes the command with the given parameters
  Future<void> execute({
    required String sessionId,
    required String input,
    required ProcessManager processManager,
    required CliLoggingService logger,
  });
}
