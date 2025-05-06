// services/task_service.dart

// ignore_for_file: unnecessary_import

import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../model/task.dart';

class TaskService {
  static Database? _db;
  final _store = intMapStoreFactory.store('tasks');

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await _getDbPath('tasks.db');

    final dbFactory = kIsWeb ? databaseFactoryMemory : databaseFactoryIo;

    return await dbFactory.openDatabase(dbPath);
  }

  Future<String> _getDbPath(String dbName) async {
    if (kIsWeb) return dbName;
    final dir = await getApplicationDocumentsDirectory();
    return join(dir.path, dbName);
  }

  Future<int> addTask(Task task) async {
    final db = await database;
    return await _store.add(db, task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final snapshots = await _store.find(db);
    return snapshots.map((record) {
      final map = Map<String, dynamic>.from(record.value);
      map['id'] = record.key;
      return Task.fromMap(map);
    }).toList();
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await _store.record(task.id!).update(db, task.toMap());
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await _store.record(id).delete(db);
  }

  Future<void> updateTaskCompletion(int id, bool completed) async {
    final db = await database;
    await _store.record(id).update(db, {'completed': completed ? 1 : 0});
  }
}
