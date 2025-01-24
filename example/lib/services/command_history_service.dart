import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/command_history.dart';
import '../repositories/command_history_repository.dart';

part 'command_history_service.g.dart';

@Riverpod(keepAlive: true)
Future<CommandHistoryService> commandHistoryService(
    CommandHistoryServiceRef ref) async {
  final repository = await ref.watch(commandHistoryRepositoryProvider.future);
  return CommandHistoryService(repository);
}

class CommandHistoryService {
  final CommandHistoryRepository _repository;

  CommandHistoryService(this._repository);

  Future<List<CommandHistory>> getAllCommands() async {
    return _repository.readAll();
  }

  Future<CommandHistory> addCommand(String command) async {
    final history = CommandHistory(
      command: command,
      timestamp: DateTime.now(),
    );
    return _repository.create(history);
  }

  Future<void> toggleFavorite(int id) async {
    await _repository.toggleFavorite(id);
  }

  Future<void> deleteCommand(int id) async {
    await _repository.delete(id);
  }

  Future<void> clearHistory() async {
    await _repository.deleteAll();
  }

  // ... other business logic methods
}
