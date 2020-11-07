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
	 "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	 "title" TEXT NOT NULL,
	 "created" text NOT NULL,
	 "updated" TEXT NOT NULL,
	 "selfLink" TEXT UNIQUE,
	 "listId" TEXT NOT NULL,
	 "position" TEXT,
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
    await db.insert(kTableTodos, todo.toMapAutoID());
  }

  Future updateTodo(Todo todo) async {
    final db = await database;
    await db.update(kTableTodos, todo.toMap(), where: 'id=?', whereArgs: [todo.id]);
  }

  Future updateTodoUsingSelfLink(Todo todo) async {
    final db = await database;
    await db.update(kTableTodos, todo.toMapAutoID(), where: 'selfLink=?', whereArgs: [todo.selfLink]);
  }

  Future deleteTodo(Todo todo) async {
    final db = await database;
    await db.delete(kTableTodos, where: 'id=?', whereArgs: [todo.id]);
  }

  Future deleteTodoUsingSelfLink(Todo todo) async {
    final db = await database;
    await db.delete(kTableTodos, where: 'selfLink=?', whereArgs: [todo.selfLink]);
  }

  Future deleteAllTodos({String status = kTodosStatusDone}) async {
    final db = await database;
    await db.delete(kTableTodos, where: 'status=?', whereArgs: [status]);
  }

  Future<List<Todo>> retrieveTodos(String listId, {String status = kTodosStatusActive}) async {
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
        selfLink: maps[i]['selfLink'],
        position: maps[i]['position'],
      );
    });
    todos.sort();
    return todos;
  }
}
