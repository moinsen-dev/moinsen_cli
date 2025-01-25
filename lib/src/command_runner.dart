import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:moinsen_cli/src/commands/commands.dart';
import 'package:moinsen_cli/src/version.dart';
import 'package:pub_updater/pub_updater.dart';

const executableName = 'moinsen';
const packageName = 'moinsen_cli';
const description = 'Say moinsen to help you with your flutter projects';

/// {@template moinsen_cli_command_runner}
/// A [CommandRunner] for the CLI.
///
/// ```bash
/// $ moinsen --version
/// ```
/// {@endtemplate}
class MoinsenCliCommandRunner extends CompletionCommandRunner<int> {
  /// {@macro moinsen_cli_command_runner}
  MoinsenCliCommandRunner({
    Logger? logger,
    PubUpdater? pubUpdater,
  })  : _logger = logger ?? Logger(),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        super(executableName, description) {
    // Add root options and flags
    argParser
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Print the current version.',
      )
      ..addFlag(
        'verbose',
        help: 'Noisy logging, including all shell commands executed.',
      );

    // Add sub commands
    addCommand(UpdateCommand(logger: _logger, pubUpdater: _pubUpdater));
    addCommand(ServeCommand(logger: _logger));
    addCommand(_SampleCommand()); // Add sample command for testing
  }

  @override
  void printUsage() => _logger.info(usage);

  final Logger _logger;
  final PubUpdater _pubUpdater;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final topLevelResults = parse(args);
      if (topLevelResults['verbose'] == true) {
        _logger.level = Level.verbose;
      }
      return await runCommand(topLevelResults) ?? ExitCode.success.code;
    } on FormatException catch (e, stackTrace) {
      // On format errors, show the commands error message, root usage and
      // exit with an error code
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      // On usage errors, show the commands usage message and
      // exit with an error code
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    // Fast track completion command
    if (topLevelResults.command?.name == 'completion') {
      await super.runCommand(topLevelResults);
      return ExitCode.success.code;
    }

    // Handle version flag
    if (topLevelResults['version'] == true) {
      // Check for updates before showing version
      if (topLevelResults.command?.name != UpdateCommand.commandName) {
        try {
          final latestVersion = await _pubUpdater.getLatestVersion(packageName);
          final isUpToDate = packageVersion == latestVersion;
          if (!isUpToDate) {
            _logger.info('''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(packageVersion)} \u2192 ${lightCyan.wrap(latestVersion)}
Run ${lightCyan.wrap('$executableName update')} to update''');
          }
        } catch (_) {}
      }
      _logger.info(packageVersion);
      return ExitCode.success.code;
    }

    // Verbose logs
    _logger
      ..detail('Argument information:')
      ..detail('  Top level options:');
    for (final option in topLevelResults.options) {
      if (topLevelResults.wasParsed(option)) {
        _logger.detail('  - $option: ${topLevelResults[option]}');
      }
    }
    if (topLevelResults.command != null) {
      final commandResult = topLevelResults.command!;
      _logger
        ..detail('  Command: ${commandResult.name}')
        ..detail('    Command options:');
      for (final option in commandResult.options) {
        if (commandResult.wasParsed(option)) {
          _logger.detail('    - $option: ${commandResult[option]}');
        }
      }
    } else if (topLevelResults['verbose'] == true) {
      // If only verbose flag is set without a command, return success
      return ExitCode.success.code;
    }

    // Run the command
    final exitCode = await super.runCommand(topLevelResults);

    // Check for updates
    if (topLevelResults.command?.name != UpdateCommand.commandName) {
      await _checkForUpdates();
    }

    return exitCode;
  }

  /// Checks if the current version (set by the build runner on the
  /// version.dart file) is the most recent one. If not, show a prompt to the
  /// user.
  Future<void> _checkForUpdates() async {
    try {
      final latestVersion = await _pubUpdater.getLatestVersion(packageName);
      final isUpToDate = packageVersion == latestVersion;
      if (!isUpToDate) {
        _logger.info('''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(packageVersion)} \u2192 ${lightCyan.wrap(latestVersion)}
Run ${lightCyan.wrap('$executableName update')} to update''');
      }
    } catch (_) {}
  }
}

/// A sample command for testing purposes
class _SampleCommand extends Command<int> {
  _SampleCommand() {
    argParser.addFlag('cyan');
  }

  @override
  String get description => 'A sample command for testing';

  @override
  String get name => 'sample';

  @override
  Future<int> run() async {
    return ExitCode.success.code;
  }
}
