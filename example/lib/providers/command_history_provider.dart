import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/command_history.dart';

final commandHistoryProvider =
    AsyncNotifierProvider<CommandHistoryNotifier, List<CommandHistory>>(() {
  return CommandHistoryNotifier();
});

class CommandHistoryNotifier extends AsyncNotifier<List<CommandHistory>> {
  @override
  Future<List<CommandHistory>> build() async {
    return await CommandHistoryDatabase.instance.readAll();
  }

  Future<void> addCommand(String command) async {
    final history = CommandHistory(
      command: command,
      timestamp: DateTime.now(),
    );
    await CommandHistoryDatabase.instance.create(history);
    ref.invalidateSelf();
  }

  Future<void> toggleFavorite(int id) async {
    await CommandHistoryDatabase.instance.toggleFavorite(id);
    ref.invalidateSelf();
  }

  Future<void> deleteCommand(int id) async {
    await CommandHistoryDatabase.instance.delete(id);
    ref.invalidateSelf();
  }

  Future<void> clearHistory() async {
    await CommandHistoryDatabase.instance.deleteAll();
    ref.invalidateSelf();
  }
}
