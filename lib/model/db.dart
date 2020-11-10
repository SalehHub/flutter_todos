import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/model.dart';

const kTodosStatusActive = 'needsAction';
const kTodosStatusDone = 'completed';

const kDatabaseName = 'myTodos.db';
const kDatabaseVersion = 1;
const kSQLCreateStatement = '''
CREATE TABLE "todos" (
	 "id" TEXT NOT NULL PRIMARY KEY,
	 "title" TEXT NOT NULL,
	 "created" TEXT,
	 "updated" TEXT,
	 "listId" TEXT NOT NULL,
	 "position" TEXT,
	 "userId" TEXT NOT NULL,
	 "status" TEXT DEFAULT $kTodosStatusActive
);
''';

const kTableTodos = 'todos';

class DB {
  DB._();
  static final DB sharedInstance = DB._();

  Database _database;
  Future<Database> get database async {
    return _database ?? await initDB();
  }

  Future<Database> initDB() async {
    Directory docsDirectory = await getApplicationDocumentsDirectory();
    String path = join(docsDirectory.path, kDatabaseName);

    return await openDatabase(path, version: kDatabaseVersion, onCreate: (Database db, int version) async {
      await db.execute(kSQLCreateStatement);
    });
  }

  Future createTodo(Todo todo) async {
    final db = await database;
    await db.insert(kTableTodos, todo.toMap());
  }

  Future updateTodo(Todo todo) async {
    final db = await database;
    await db.update(kTableTodos, todo.toMap(), where: 'id=?', whereArgs: [todo.id]);
  }

  Future deleteTodo(Todo todo) async {
    final db = await database;
    await db.delete(kTableTodos, where: 'id=?', whereArgs: [todo.id]);
  }

  Future deleteAllDoneTodos(String listId, {String status = kTodosStatusDone}) async {
    final db = await database;
    await db.delete(kTableTodos, where: 'status=? and listId=?', whereArgs: [status, listId]);
  }

  Future deleteAllTodos(
    String listId,
  ) async {
    final db = await database;
    await db.delete(kTableTodos, where: 'listId=?', whereArgs: [listId]);
  }

  Future<List<Todo>> retrieveTodos(String listId, {String status = kTodosStatusActive}) async {
    if (listId == null) {
      listId = '@default';
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(kTableTodos,
        where: 'status=? and listId=?', whereArgs: [status, listId], orderBy: 'position ASC');

    // Convert List<Map<String, dynamic>> to List<Todo_object>
    List<Todo> todos = List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        created: DateTime.tryParse(maps[i]['created']),
        updated: DateTime.tryParse(maps[i]['updated']),
        status: maps[i]['status'],
        listId: maps[i]['listId'],
        position: maps[i]['position'],
        userId: maps[i]['userId'],
      );
    });
    todos.sort();
    return todos;
  }
}
