import 'dart:io';

import 'package:flutter_todos/models.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/model.dart';

const kTodosStatusActive = 'needsAction';
const kTodosStatusDone = 'completed';

const kDatabaseName = 'myTodos1.db';
const kDatabaseVersion = 1;
const kSQLCreateStatement1 = '''
CREATE TABLE "todos" (
	 "id" TEXT NOT NULL PRIMARY KEY,
	 "title" TEXT NOT NULL,
	 "created" TEXT NOT NULL,
	 "updated" TEXT,
	 "listId" TEXT NOT NULL,
	 "listTitle" TEXT NOT NULL,
	 "position" TEXT,
	 "userId" TEXT NOT NULL,
	 "status" TEXT DEFAULT $kTodosStatusActive
)
''';
const kSQLCreateStatement2 = '''
CREATE TABLE "lists" (
	 "listId" TEXT NOT NULL unique,
	 "listTitle" TEXT NOT NULL,
	 "date" TEXT NOT NULL
)
''';

const kTableTodos = 'todos';
const kTableLists = 'lists';

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
      await db.execute(kSQLCreateStatement1);
      await db.execute(kSQLCreateStatement2);
    });
  }

  Future createTodo(Todo todo) async {
    final db = await database;
    await db.insert(kTableTodos, todo.toMap());
  }

  Future createList(ListData list) async {
    final db = await database;
    await db.insert(kTableLists, list.toMap());
  }

  Future updateTodo(Todo todo) async {
    final db = await database;
    await db.update(kTableTodos, todo.toMap(), where: 'id=?', whereArgs: [todo.id]);
  }

  Future updateList(ListData list) async {
    final db = await database;
    await db.update(kTableLists, list.toMap(), where: 'listId=?', whereArgs: [list.listId]);
  }

  Future deleteTodo(Todo todo) async {
    final db = await database;
    await db.delete(kTableTodos, where: 'id=?', whereArgs: [todo.id]);
  }

  Future deleteAllLists() async {
    final db = await database;
    await db.delete(kTableLists);
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
        where: 'status=? and listId=?', whereArgs: [status, listId], orderBy: 'created ASC');

    List<Todo> todos = List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        created: DateTime.tryParse(maps[i]['created']),
        updated: DateTime.tryParse(maps[i]['updated']),
        status: maps[i]['status'],
        listId: maps[i]['listId'],
        listTitle: maps[i]['listTitle'],
        position: maps[i]['position'],
        userId: maps[i]['userId'],
      );
    });
    todos.sort();
    return todos;
  }

  Future<List<ListData>> getLists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(kTableLists, orderBy: 'date ASC');

    List<ListData> todos = List.generate(maps.length, (i) {
      return ListData(
        maps[i]['listId'],
        maps[i]['listTitle'],
        DateTime.tryParse(maps[i]['date']),
      );
    });
    todos.sort();
    return todos;
  }

  Future deleteList(String userId, String listId) async {
    final db = await database;
    await db.delete(kTableLists, where: 'listId=?', whereArgs: [listId]);
  }
}
