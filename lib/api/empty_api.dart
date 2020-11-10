import 'package:flutter_todos/api/api_interface.dart';

import '../model/model.dart' as Model;
import '../models.dart';

class EmptyApi implements ApiInterface {
  Future<TasksList> getLists() => null;

  Future<String> getMainListId(String listId, String listTitle) => null;

  Future<List<Model.Todo>> getTasks(String listId, String userId) => null;

  Future<Model.Todo> createTask(Model.Todo todo) => Future.value(todo);

  Future completeTask(Model.Todo todo) => null;

  Future unCompleteTask(Model.Todo todo) => null;

  Future deleteTask(Model.Todo todo) => null;
}
