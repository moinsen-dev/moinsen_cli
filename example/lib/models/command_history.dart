import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CommandHistory {
  final int? id;
  final String command;
  final DateTime timestamp;

  CommandHistory({
    this.id,
    required this.command,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'command': command,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CommandHistory.fromMap(Map<String, dynamic> map) {
    return CommandHistory(
      id: map['id'] as int,
      command: map['command'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class CommandHistoryDatabase {
  static final CommandHistoryDatabase instance = CommandHistoryDatabase._init();
  static Database? _database;

  CommandHistoryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('command_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE command_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        command TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<CommandHistory> create(CommandHistory history) async {
    final db = await instance.database;
    final id = await db.insert('command_history', history.toMap());
    return history.id == null
        ? CommandHistory(
            id: id,
            command: history.command,
            timestamp: history.timestamp,
          )
        : history;
  }

  Future<List<CommandHistory>> readAll() async {
    final db = await instance.database;
    final result = await db.query(
      'command_history',
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => CommandHistory.fromMap(map)).toList();
  }

  Future<void> delete(int id) async {
    final db = await instance.database;
    await db.delete(
      'command_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await instance.database;
    await db.delete('command_history');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
