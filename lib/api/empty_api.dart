import 'package:flutter_todos/api/api_interface.dart';

import '../model/model.dart' as Model;
import '../models.dart';

class EmptyApi implements ApiInterface {
  Future<TasksList> getLists(String userId) => null;

  Future<String> getMainListId(String userId, String listId, String listTitle) {
    return Future.value(listId.hashCode.toString());
  }

  Future<List<Model.Todo>> getTasks(String listId, String userId) => null;

  Future<bool> deleteList(String userId, String listId) => null;

  Future<String> createList(String userId, String listId, String listTitle) => null;

  Future<String> updateList(String userId, String listId, String newListTitle) => null;

  Future<Model.Todo> createTask(Model.Todo todo) => Future.value(todo);

  Future completeTask(Model.Todo todo) => null;

  Future unCompleteTask(Model.Todo todo) => null;

  Future deleteTask(Model.Todo todo) => null;
}
