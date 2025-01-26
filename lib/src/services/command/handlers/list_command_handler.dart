import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/generated/command.pb.dart';
import 'package:moinsen_cli/src/services/cli_logging_service.dart';
import 'package:moinsen_cli/src/services/command/handlers/command_handler.dart';
import 'package:moinsen_cli/src/services/command/process_manager.dart';
import 'package:path/path.dart' as path;

/// Handles directory listing operations
class ListCommandHandler implements CommandHandler {
  @override
  Future<void> execute({
    required String sessionId,
    required String input,
    required ProcessManager processManager,
    required CliLoggingService logger,
  }) async {
    try {
      final request = CommandRequest.fromJson(input);
      final targetPath = request.path.isEmpty ? '.' : request.path;

      final directory = Directory(targetPath);
      if (!directory.existsSync()) {
        throw FileSystemException('Directory not found', targetPath);
      }

      final fileList = <FileInfo>[];
      await for (final entity in directory.list()) {
        final stat = await entity.stat();
        fileList.add(
          FileInfo(
            name: path.basename(entity.path),
            isDirectory: entity is Directory,
            size: Int64(stat.size),
            modifiedTime: Int64(stat.modified.millisecondsSinceEpoch),
          ),
        );
      }

      logger.log(
        Level.info,
        'Listed ${fileList.length} items in directory: $targetPath',
        sessionId: sessionId,
      );
    } catch (e) {
      logger.log(
        Level.error,
        'Error listing directory: $e',
        sessionId: sessionId,
      );
      rethrow;
    }
  }
}
