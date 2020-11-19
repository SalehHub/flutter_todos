import 'package:flutter_todos/models.dart';

import '../model/db.dart';
import '../model/model.dart';
import 'db.dart';

class DBWrapper {
  static final DBWrapper sharedInstance = DBWrapper._();

  DBWrapper._();

  Future<List<Todo>> getTodos(String listId) async {
    List list = await DB.sharedInstance.retrieveTodos(listId, status: kTodosStatusActive);
    return list;
  }

  Future<List<ListData>> getLists() async {
    List<ListData> list = await DB.sharedInstance.getLists();
    return list;
  }

  Future<List<Todo>> getDones(String listId) async {
    List list = await DB.sharedInstance.retrieveTodos(listId, status: kTodosStatusDone);
    return list;
  }

  Future addTodo(Todo todo) async {
    await DB.sharedInstance.createTodo(todo);
  }

  Future createList(ListData list) async {
    await DB.sharedInstance.createList(list);
  }

  Future deleteAllLists() async {
    await DB.sharedInstance.deleteAllLists();
  }

  Future updateList(ListData list) async {
    await DB.sharedInstance.updateList(list);
  }

  Future markTodoAsDone(Todo todo) async {
    todo.status = kTodosStatusDone;
    todo.updated = DateTime.now();
    await DB.sharedInstance.updateTodo(todo);
  }

  Future markDoneAsTodo(Todo todo) async {
    todo.status = kTodosStatusActive;
    todo.updated = DateTime.now();
    await DB.sharedInstance.updateTodo(todo);
  }

  Future deleteTodo(Todo todo) async {
    await DB.sharedInstance.deleteTodo(todo);
  }

  Future deleteAllDoneTodos(String listId) async {
    await DB.sharedInstance.deleteAllDoneTodos(listId);
  }

  Future deleteAllTodos(String listId) async {
    await DB.sharedInstance.deleteAllTodos(listId);
  }

  Future deleteList(String userId, String listId) async {
    await DB.sharedInstance.deleteList(userId, listId);
  }
}
