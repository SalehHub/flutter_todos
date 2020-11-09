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

  Future<List<Todo>> getDones(String listId) async {
    List list = await DB.sharedInstance.retrieveTodos(listId, status: kTodosStatusDone);
    return list;
  }

  Future addTodo(Todo todo) async {
    await DB.sharedInstance.createTodo(todo);
  }

  Future markTodoAsDone(Todo todo) async {
    todo.status = kTodosStatusDone;
    todo.updated = DateTime.now();
    await DB.sharedInstance.updateTodo(todo);
    //await DB.sharedInstance.updateTodoUsingSelfLink(todo);
  }

  Future markDoneAsTodo(Todo todo) async {
    todo.status = kTodosStatusActive;
    todo.updated = DateTime.now();
    await DB.sharedInstance.updateTodo(todo);
    //await DB.sharedInstance.updateTodoUsingSelfLink(todo);
  }

  Future deleteTodo(Todo todo) async {
    await DB.sharedInstance.deleteTodo(todo);
    //await DB.sharedInstance.deleteTodoUsingSelfLink(todo);
  }

  Future deleteAllDoneTodos(String listId) async {
    await DB.sharedInstance.deleteAllDoneTodos(listId);
  }

  Future deleteAllTodos(String listId) async {
    await DB.sharedInstance.deleteAllTodos(listId);
  }
}
