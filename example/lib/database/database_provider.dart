import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Database> database(DatabaseRef ref) async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  return DatabaseProvider.instance.initDatabase(documentsDirectory.path);
}

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._init();
  static Database? _database;
  static const int _currentVersion = 2;

  DatabaseProvider._init();

  Future<Database> initDatabase(String documentsPath) async {
    if (_database != null) return _database!;

    final path = join(documentsPath, 'command_history.db');

    // Migration logic
    final dbFile = File(path);
    if (await dbFile.exists()) {
      final db = sqlite3.open(path);
      try {
        final version =
            db.select('PRAGMA user_version').first.columnAt(0) as int;
        if (version < _currentVersion) {
          db.dispose();
          await dbFile.delete();
        } else {
          _database = db;
          return db;
        }
      } catch (e) {
        db.dispose();
        await dbFile.delete();
      }
    }

    final db = sqlite3.open(path);
    db.execute('''
      CREATE TABLE IF NOT EXISTS command_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        command TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    db.execute('PRAGMA user_version = $_currentVersion');
    _database = db;
    return db;
  }

  void dispose() {
    _database?.dispose();
    _database = null;
  }
}
