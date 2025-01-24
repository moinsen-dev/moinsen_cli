import 'dart:io';
import 'dart:math';

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
    argParser
      ..addOption(
        'port',
        abbr: 'p',
        help: 'Port to listen on',
        defaultsTo: '50051',
      )
      ..addFlag(
        'secret',
        help: 'Enable secure server access with an auto-generated secret key',
        negatable: false,
      )
      ..addOption(
        'secret-key',
        help: 'Provide a specific secret key for server access',
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
    final useSecret = argResults?['secret'] as bool;
    var secretKey = argResults?['secret-key'] as String?;

    if (useSecret || secretKey != null) {
      if (secretKey == null) {
        // Generate a random secret
        // if --secret is provided without a specific key
        const chars =
            'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        final random = Random.secure();
        secretKey = List.generate(
          32,
          (index) => chars[random.nextInt(chars.length)],
        ).join();
        _logger.info('Generated secret: $secretKey');
      }
    } else {
      _logger
        ..warn(
          'Warning: Server running without secret key. This is not secure!',
        )
        ..info(
          'Use --secret to generate a secure key or --secret-key to provide '
          'your own.',
        );
    }

    _logger.info('Starting server on port $port...');

    final server = Server.create(
      services: [
        CommandServiceImpl(secret: secretKey),
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
