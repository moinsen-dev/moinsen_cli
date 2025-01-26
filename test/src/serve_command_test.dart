import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moinsen_cli/src/command_runner.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

void main() {
  group('serve', () {
    late Logger logger;
    late MoinsenCliCommandRunner commandRunner;

    setUp(() {
      logger = _MockLogger();
      commandRunner = MoinsenCliCommandRunner(
        logger: logger,
      );
    });

    test('completes successfully', () async {
      final result = await commandRunner.run(['serve']);
      expect(result, equals(ExitCode.success.code));
    });

    test('outputs error on incorrect usage', () async {
      final result = await commandRunner.run(['serve', '--invalid-flag']);
      expect(result, equals(ExitCode.usage.code));
    });

    test('handles server startup failure gracefully', () async {
      // TODO(udi): Add test for server startup failure scenario
      // This will depend on the actual implementation of the serve command
    });
  });
}
