import 'package:moinsen_cli/src/generated/command.pb.dart';
import 'package:moinsen_cli/src/services/command/handlers/cd_command_handler.dart';
import 'package:moinsen_cli/src/services/command/handlers/command_handler.dart';
import 'package:moinsen_cli/src/services/command/handlers/exit_command_handler.dart';
import 'package:moinsen_cli/src/services/command/handlers/file_command_handler.dart';
import 'package:moinsen_cli/src/services/command/handlers/init_command_handler.dart';
import 'package:moinsen_cli/src/services/command/handlers/list_command_handler.dart';
import 'package:moinsen_cli/src/services/command/handlers/search_command_handler.dart';
import 'package:moinsen_cli/src/services/command/handlers/shell_command_handler.dart';

/// Factory class for creating command handlers based on command type
class CommandHandlerFactory {
  static final Map<CommandType, CommandHandler> _handlers = {
    CommandType.COMMAND: ShellCommandHandler(),
    CommandType.INIT: InitCommandHandler(),
    CommandType.LIST: ListCommandHandler(),
    CommandType.CD: CdCommandHandler(),
    CommandType.EXIT: ExitCommandHandler(),
    CommandType.READ_FILE: FileCommandHandler(),
    CommandType.WRITE_FILE: FileCommandHandler(),
    CommandType.DELETE_FILE: FileCommandHandler(),
    CommandType.CREATE_FILE: FileCommandHandler(),
    CommandType.CREATE_DIR: FileCommandHandler(),
    CommandType.DELETE_DIR: FileCommandHandler(),
    CommandType.SEARCH: SearchCommandHandler(),
  };

  /// Returns the appropriate command handler for the given command type
  static CommandHandler getHandler(CommandType type) {
    final handler = _handlers[type];
    if (handler == null) {
      throw UnimplementedError(
        'No handler implemented for command type: $type',
      );
    }
    return handler;
  }
}
