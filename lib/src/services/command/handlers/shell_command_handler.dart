import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/generated/command.pb.dart';
import 'package:moinsen_cli/src/services/cli_logging_service.dart';
import 'package:moinsen_cli/src/services/command/handlers/command_handler.dart';
import 'package:moinsen_cli/src/services/command/process_manager.dart';

/// Handles execution of shell commands
class ShellCommandHandler implements CommandHandler {
  @override
  Future<void> execute({
    required String sessionId,
    required String input,
    required ProcessManager processManager,
    required CliLoggingService logger,
  }) async {
    logger.log(
      Level.info,
      'Executing shell command: $input',
      sessionId: sessionId,
    );

    var streamingMode = false;
    var commandInput = input;

    try {
      // Try to parse as JSON first
      final request = CommandRequest.fromJson(input);
      streamingMode = request.streamingMode;
      commandInput = request.inputData;
    } catch (e) {
      // If parsing fails, treat input as raw command string
      logger.log(
        Level.verbose,
        'Using raw command input',
        sessionId: sessionId,
      );
    }

    processManager.terminateCurrentProcess(sessionId);
    await processManager.executeCommand(
      sessionId,
      commandInput,
      streamingMode: streamingMode,
    );
  }
}
