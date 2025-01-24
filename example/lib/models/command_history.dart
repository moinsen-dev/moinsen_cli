import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class CommandHistory {
  final int? id;
  final String command;
  final DateTime timestamp;
  final bool isFavorite;

  CommandHistory({
    this.id,
    required this.command,
    required this.timestamp,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'command': command,
      'timestamp': timestamp.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory CommandHistory.fromRow(Row row) {
    return CommandHistory(
      id: row['id'] as int,
      command: row['command'] as String,
      timestamp: DateTime.parse(row['timestamp'] as String),
      isFavorite: (row['is_favorite'] as int?) == 1,
    );
  }

  CommandHistory copyWith({
    int? id,
    String? command,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return CommandHistory(
      id: id ?? this.id,
      command: command ?? this.command,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class CommandHistoryDatabase {
  static final CommandHistoryDatabase instance = CommandHistoryDatabase._init();
  static Database? _database;
  static const int _currentVersion = 2;

  CommandHistoryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'command_history.db');

    // Check if we need to migrate
    final dbFile = File(path);
    if (await dbFile.exists()) {
      final db = sqlite3.open(path);
      try {
        // Try to get the version
        final version = db
            .select(
              'PRAGMA user_version',
            )
            .first
            .columnAt(0) as int;

        if (version < _currentVersion) {
          // Close the database before deleting
          db.dispose();
          // Delete the old database
          await dbFile.delete();
        } else {
          return db;
        }
      } catch (e) {
        // If there's an error reading the version, assume it's an old version
        db.dispose();
        await dbFile.delete();
      }
    }

    // Create new database
    final db = sqlite3.open(path);

    // Create the table with the current schema
    db.execute('''
      CREATE TABLE IF NOT EXISTS command_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        command TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Set the version
    db.execute('PRAGMA user_version = $_currentVersion');

    return db;
  }

  Future<CommandHistory> create(CommandHistory history) async {
    final db = await database;
    final stmt = db.prepare(
      'INSERT INTO command_history (command, timestamp, is_favorite) VALUES (?, ?, ?)',
    );

    stmt.execute([
      history.command,
      history.timestamp.toIso8601String(),
      history.isFavorite ? 1 : 0,
    ]);

    final id = db.lastInsertRowId;
    stmt.dispose();

    return history.copyWith(id: id);
  }

  Future<List<CommandHistory>> readAll() async {
    final db = await database;
    final result = db.select(
      'SELECT * FROM command_history ORDER BY timestamp DESC',
    );
    return result.map((row) => CommandHistory.fromRow(row)).toList();
  }

  Future<void> toggleFavorite(int id) async {
    final db = await database;
    final stmt = db.prepare('''
      UPDATE command_history
      SET is_favorite = ((is_favorite | 1) - (is_favorite & 1))
      WHERE id = ?
    ''');
    stmt.execute([id]);
    stmt.dispose();
  }

  Future<void> delete(int id) async {
    final db = await database;
    final stmt = db.prepare('DELETE FROM command_history WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  Future<void> deleteAll() async {
    final db = await database;
    db.execute('DELETE FROM command_history');
  }

  void close() {
    _database?.dispose();
    _database = null;
  }
}
