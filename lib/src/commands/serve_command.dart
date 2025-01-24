import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:grpc/grpc.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/services/command_service_impl.dart';

/// {@template serve_command}
/// A command that starts the gRPC server
/// ```bash
/// # Start the server
/// $ moinsen serve
/// ```
/// {@endtemplate}
class ServeCommand extends Command<int> {
  /// {@macro serve_command}
  ServeCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser.addOption(
      'port',
      abbr: 'p',
      help: 'Port to listen on',
      defaultsTo: '50051',
    );
  }

  final Logger _logger;

  @override
  String get description => 'Start the gRPC server';

  @override
  String get name => 'serve';

  @override
  Future<int> run() async {
    final port = int.parse(argResults?['port'] as String);

    _logger.info('Starting server on port $port...');

    final server = Server.create(
      services: [
        CommandServiceImpl(),
      ],
    );

    try {
      await server.serve(port: port);
      _logger.success('Server listening on port ${server.port}');

      // Keep the command running
      await ProcessSignal.sigint.watch().first;
      await server.shutdown();
      return ExitCode.success.code;
    } catch (e) {
      _logger.err('Failed to start server: $e');
      return ExitCode.software.code;
    }
  }
}
