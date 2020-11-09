import '../model/model.dart' as Model;
import '../models.dart';

abstract class ApiInterface {
  Future<TasksList> getLists();

  Future<String> getMainListId(String listId, String listTitle);

  Future<List<Model.Todo>> getTasks(String listId, String userId);

  Future<Model.Todo> createTask(Model.Todo todo);

  Future completeTask(Model.Todo todo);

  Future unCompleteTask(Model.Todo todo);

  Future deleteTask(Model.Todo todo);
}
