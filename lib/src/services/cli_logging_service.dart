import 'dart:convert';
import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// A service for CLI-related logging events.
class CliLoggingService {
  /// Creates a new instance of [CliLoggingService].
  CliLoggingService({
    required this.logDir,
    Logger? logger,
  }) : _logger = logger ?? Logger() {
    _initializeLogDirectory();
  }

  /// The directory where log files are stored.
  final String logDir;

  final Logger _logger;

  void _initializeLogDirectory() {
    final dir = Directory(logDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// Logs a message with the specified level and optional session ID.
  void log(Level level, String message, {String? sessionId}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = {
      'timestamp': timestamp,
      'level': level.name,
      'message': message,
      if (sessionId != null) 'session_id': sessionId,
    };

    // Write to console
    switch (level) {
      case Level.error:
        _logger.err(message);
      case Level.warning:
        _logger.warn(message);
      case Level.info:
        _logger.info(message);
      case Level.verbose:
        _logger.detail(message);
      case Level.debug:
        _logger.detail(message);
      case Level.quiet:
        break;
      case Level.critical:
        _logger.alert(message);
    }

    // Write to file if session ID is provided
    if (sessionId != null) {
      final logFile = File(path.join(logDir, '$sessionId.log'));
      logFile.writeAsStringSync(
        '${jsonEncode(logMessage)}\n',
        mode: FileMode.append,
      );
    }
  }
}
