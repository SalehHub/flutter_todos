import '../model/model.dart' as Model;

abstract class ApiInterface {
  Future<dynamic> getLists(String userId);

  Future<String> getMainListId(String userId, String listId, String listTitle);

  Future<List<Model.Todo>> getTasks(String listId, String userId);

  Future<bool> deleteList(String userId, String listId);

  Future<String> createList(String userId, String listId, String listTitle);

  Future<String> updateList(String userId, String listId, String newListTitle);

  Future<Model.Todo> createTask(Model.Todo todo);

  Future completeTask(Model.Todo todo);

  Future unCompleteTask(Model.Todo todo);

  Future deleteTask(Model.Todo todo);
}
