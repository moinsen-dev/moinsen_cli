import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/generated/command.pb.dart';
import 'package:moinsen_cli/src/services/cli_logging_service.dart';
import 'package:moinsen_cli/src/services/command/handlers/command_handler.dart';
import 'package:moinsen_cli/src/services/command/process_manager.dart';
import 'package:path/path.dart' as path;

/// Handles file and directory search operations
class SearchCommandHandler implements CommandHandler {
  @override
  Future<void> execute({
    required String sessionId,
    required String input,
    required ProcessManager processManager,
    required CliLoggingService logger,
  }) async {
    try {
      final request = CommandRequest.fromJson(input);
      final searchQuery = request.searchQuery.toLowerCase();
      final startPath = request.path.isEmpty ? '.' : request.path;

      if (searchQuery.isEmpty) {
        throw const FormatException('Search query cannot be empty');
      }

      final results = <FileInfo>[];
      await _searchDirectory(
        Directory(startPath),
        searchQuery,
        results,
        logger,
        sessionId,
      );

      logger.log(
        Level.info,
        'Found ${results.length} matches for query: $searchQuery',
        sessionId: sessionId,
      );
    } catch (e) {
      logger.log(
        Level.error,
        'Error during search: $e',
        sessionId: sessionId,
      );
      rethrow;
    }
  }

  Future<void> _searchDirectory(
    Directory directory,
    String query,
    List<FileInfo> results,
    CliLoggingService logger,
    String sessionId,
  ) async {
    try {
      await for (final entity in directory.list(recursive: true)) {
        final basename = path.basename(entity.path).toLowerCase();
        if (basename.contains(query)) {
          final stat = await entity.stat();
          results.add(
            FileInfo(
              name: entity.path,
              isDirectory: entity is Directory,
              size: Int64(stat.size),
              modifiedTime: Int64(stat.modified.millisecondsSinceEpoch),
            ),
          );
        }
      }
    } on FileSystemException catch (e) {
      // Log but continue if we can't access a directory
      logger.log(
        Level.warning,
        'Could not access ${directory.path}: $e',
        sessionId: sessionId,
      );
    }
  }
}
