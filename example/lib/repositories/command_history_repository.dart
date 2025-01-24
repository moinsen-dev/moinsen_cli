import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../database/database_provider.dart';
import '../models/command_history.dart';

part 'command_history_repository.g.dart';

@Riverpod(keepAlive: true)
Future<CommandHistoryRepository> commandHistoryRepository(
    CommandHistoryRepositoryRef ref) async {
  final db = await ref.watch(databaseProvider.future);
  return CommandHistoryRepository(db);
}

class CommandHistoryRepository {
  final Database _db;

  CommandHistoryRepository(this._db);

  Future<CommandHistory> create(CommandHistory history) async {
    final stmt = _db.prepare(
      'INSERT INTO command_history (command, timestamp, is_favorite) VALUES (?, ?, ?)',
    );

    try {
      stmt.execute([
        history.command,
        history.timestamp.toIso8601String(),
        history.isFavorite ? 1 : 0,
      ]);

      final id = _db.lastInsertRowId;
      return history.copyWith(id: id);
    } finally {
      stmt.dispose();
    }
  }

  Future<List<CommandHistory>> readAll() async {
    final result = _db.select(
      'SELECT * FROM command_history ORDER BY timestamp DESC',
    );
    return result.map((row) => CommandHistory.fromRow(row)).toList();
  }

  Future<void> toggleFavorite(int id) async {
    final stmt = _db.prepare('''
      UPDATE command_history
      SET is_favorite = ((is_favorite | 1) - (is_favorite & 1))
      WHERE id = ?
    ''');
    stmt.execute([id]);
    stmt.dispose();
  }

  Future<void> delete(int id) async {
    final stmt = _db.prepare('DELETE FROM command_history WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  Future<void> deleteAll() async {
    _db.execute('DELETE FROM command_history');
  }
}
