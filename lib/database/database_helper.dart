import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/reminder_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reminders.db');
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

  Future _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE reminders (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      note TEXT NOT NULL,
      dateTime INTEGER NOT NULL,
      textColor INTEGER NOT NULL,
      backgroundColor INTEGER NOT NULL,
      sticker TEXT NOT NULL,
      isCompleted INTEGER NOT NULL,
      reminderType TEXT NOT NULL,  
      songPath TEXT  
    )
  ''');
}


  Future<String> insertReminder(ReminderModel reminder) async {
    final db = await database;
    await db.insert('reminders', reminder.toMap());
    return reminder.id;
  }

  Future<List<ReminderModel>> getAllReminders() async {
    final db = await database;
    final result = await db.query('reminders', orderBy: 'dateTime ASC');
    return result.map((map) => ReminderModel.fromMap(map)).toList();
  }

  Future<int> updateReminder(ReminderModel reminder) async {
    final db = await database;
    return await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> deleteReminder(String id) async {
    final db = await database;
    return await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}