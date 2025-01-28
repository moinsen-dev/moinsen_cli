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
    required CommandRequest request,
    required ProcessManager processManager,
    required CliLoggingService logger,
  }) async {
    logger.log(
      Level.info,
      'Executing shell command: ${request.inputData}',
      sessionId: sessionId,
    );

    processManager.terminateCurrentProcess(sessionId);
    await processManager.executeCommand(
      sessionId: sessionId,
      input: input,
      request: request,
      streamingMode: request.streamingMode,
    );
  }
}
