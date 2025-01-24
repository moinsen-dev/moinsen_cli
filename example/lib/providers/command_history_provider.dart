import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import '../models/command_history.dart';
import '../repositories/command_history_repository.dart';
import '../services/command_history_service.dart';

final commandHistoryProvider =
    AsyncNotifierProvider<CommandHistoryNotifier, List<CommandHistory>>(() {
  return CommandHistoryNotifier();
});

class CommandHistoryNotifier extends AsyncNotifier<List<CommandHistory>> {
  late final CommandHistoryService _service;

  @override
  Future<List<CommandHistory>> build() async {
    // Initialize the service with the database
    final dbValue = ref.read(databaseProvider);
    final db = dbValue.value;
    if (db == null) {
      throw Exception('Database not initialized');
    }
    final repository = CommandHistoryRepository(db);
    _service = CommandHistoryService(repository);
    return await _service.getAllCommands();
  }

  Future<void> toggleFavorite(int id) async {
    await _service.toggleFavorite(id);
    // Refresh the state
    state = AsyncValue.data(await _service.getAllCommands());
  }

  Future<void> addCommand(String command) async {
    await _service.addCommand(command);
    // Refresh the state
    state = AsyncValue.data(await _service.getAllCommands());
  }

  Future<void> deleteCommand(int id) async {
    await _service.deleteCommand(id);
    // Refresh the state
    state = AsyncValue.data(await _service.getAllCommands());
  }

  Future<void> clearHistory() async {
    await _service.clearHistory();
    // Refresh the state
    state = AsyncValue.data(await _service.getAllCommands());
  }
}
