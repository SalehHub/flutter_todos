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

  void addTodo(Todo todo) async {
    await DB.sharedInstance.createTodo(todo);
  }

  void markTodoAsDone(Todo todo) async {
    todo.status = kTodosStatusDone;
    todo.updated = DateTime.now();
    await DB.sharedInstance.updateTodo(todo);
  }

  void markDoneAsTodo(Todo todo) async {
    todo.status = kTodosStatusActive;
    todo.updated = DateTime.now();
    await DB.sharedInstance.updateTodo(todo);
  }

  void deleteTodo(Todo todo) async {
    await DB.sharedInstance.deleteTodo(todo);
  }

  void deleteAllDoneTodos() async {
    await DB.sharedInstance.deleteAllTodos();
  }
}
