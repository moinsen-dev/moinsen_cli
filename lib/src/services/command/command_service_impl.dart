import 'dart:async';
import 'dart:io';

import 'package:fixnum/fixnum.dart' show Int64;
import 'package:grpc/grpc.dart' as $grpc;
import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/generated/command.pb.dart';
import 'package:moinsen_cli/src/generated/command.pbgrpc.dart' as pbgrpc;
import 'package:moinsen_cli/src/services/cli_logging_service.dart';
import 'package:moinsen_cli/src/services/command/handlers/command_handler_factory.dart';
import 'package:moinsen_cli/src/services/command/process_manager.dart';
import 'package:moinsen_cli/src/services/command/response_handler.dart';
import 'package:path/path.dart' as path;

/// Implementation of the gRPC command service.
///
/// This service handles bidirectional streaming of commands and responses between
/// the client and server. It extends [pbgrpc.CommandServiceBase] which is generated
/// from the protobuf definitions.
class CommandServiceImpl extends pbgrpc.CommandServiceBase {
  /// Creates a new instance of [CommandServiceImpl].
  ///
  /// The [secret] parameter is optional and can be used to secure the service.
  /// If provided, clients must include this secret in their metadata.
  ///
  /// The [logger] parameter is optional and defaults to a new [CliLoggingService] instance
  /// if not provided.
  CommandServiceImpl({
    this.secret,
    Logger? logger,
  }) : _logger = CliLoggingService(
          logDir: path.join(
            Directory.systemTemp.path,
            'moinsen_cli',
            'logs',
          ),
          logger: logger,
        );

  /// Optional secret key for authentication.
  final String? secret;

  /// Logger instance for service-wide logging.
  final CliLoggingService _logger;

  /// Implements the bidirectional streaming RPC method defined in the protobuf.
  @override
  Stream<CommandResponse> streamCommand(
    $grpc.ServiceCall call,
    Stream<CommandRequest> request,
  ) async* {
    final clientAddress = call.clientMetadata?['x-forwarded-for'] ?? 'unknown';
    final clientPort = call.clientMetadata?['port'] ?? 'unknown';
    final sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';

    _logger.log(
      Level.info,
      'New client connection from $clientAddress:$clientPort',
      sessionId: sessionId,
    );

    final responseHandler = ResponseHandler();
    responseHandler.initialize();

    final processManager = ProcessManager(
      logger: _logger,
      responseHandler: responseHandler,
    );

    try {
      // Validate client authentication if secret is set
      final metadata = call.clientMetadata ?? {};
      final clientSecret = metadata['secret']?.toString();

      if (secret != null && secret!.isNotEmpty) {
        if (clientSecret != secret) {
          _logger.log(
            Level.error,
            'Authentication failed for client $clientAddress',
            sessionId: sessionId,
          );
          throw const $grpc.GrpcError.unauthenticated('Invalid secret');
        }
      }

      // Send initial connection success response
      final initialResponse = CommandResponse(
        sessionId: 'initial',
        outputData:
            'Successfully connected to gRPC server on localhost:$clientPort',
        timestamp: Int64(DateTime.now().millisecondsSinceEpoch),
        commandType: CommandType.COMMAND_TYPE_UNSPECIFIED,
        success: true,
      );
      yield initialResponse;

      // Create a completer to signal when we should close the stream
      final streamCloser = Completer<void>();

      // Process requests in a separate async operation
      unawaited(
        _processRequests(request, sessionId, processManager, _logger)
            .whenComplete(() {
          _logger.log(
            Level.info,
            'Request stream completed',
            sessionId: sessionId,
          );
          if (!streamCloser.isCompleted) {
            streamCloser.complete();
          }
        }),
      );

      // Keep yielding responses until explicitly closed
      try {
        await for (final response in responseHandler.responseStream!) {
          if (response.outputData.isNotEmpty) {
            yield response;
          }
        }
      } catch (e) {
        _logger.log(
          Level.error,
          'Error in response stream: $e',
          sessionId: sessionId,
        );
        rethrow;
      }

      // Wait for the stream to be explicitly closed
      await streamCloser.future;
    } catch (e) {
      _logger.log(Level.error, 'Stream error: $e', sessionId: sessionId);
      rethrow;
    } finally {
      // Clean up resources when the stream ends
      _logger.log(
        Level.info,
        'Cleaning up connection resources',
        sessionId: sessionId,
      );
      processManager.terminateCurrentProcess(sessionId);
      await responseHandler.dispose();
    }
  }
}

Future<void> _processRequests(
  Stream<CommandRequest> requests,
  String sessionId,
  ProcessManager processManager,
  CliLoggingService logger,
) async {
  try {
    await for (final request in requests) {
      final input = request.inputData;
      final isInteractiveAnswer = request.isInteractiveAnswer;
      final commandType = request.commandType;

      logger.log(
        Level.info,
        'Received request: $input (Type: $commandType)',
        sessionId: sessionId,
      );

      if (isInteractiveAnswer && processManager.hasRunningProcess) {
        logger.log(
          Level.info,
          'Interactive input received',
          sessionId: sessionId,
        );
        processManager.sendInput(input);
        continue;
      }

      if (commandType == CommandType.COMMAND_TYPE_UNSPECIFIED) {
        logger.log(
          Level.warning,
          'Unknown command type specified',
          sessionId: sessionId,
        );
        continue;
      }

      try {
        final handler = CommandHandlerFactory.getHandler(commandType);
        await handler.execute(
          sessionId: sessionId,
          input: input,
          processManager: processManager,
          logger: logger,
        );
      } catch (e) {
        logger.log(
          Level.error,
          'Error executing command: $e',
          sessionId: sessionId,
        );
      }
    }
  } catch (e) {
    logger.log(
      Level.error,
      'Error in request stream: $e',
      sessionId: sessionId,
    );
    rethrow;
  }
}
