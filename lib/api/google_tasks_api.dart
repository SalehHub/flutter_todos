import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../model/model.dart' as Model;
import '../models.dart';
import 'api_interface.dart';

class GoogleTasksApi implements ApiInterface {
  final googleSignIn;
  String accessToken;

  GoogleTasksApi(this.googleSignIn);

  Future<String> _refreshAccessToken() async {
    try {
      //final googleSignInAccount = await googleSignIn.signIn();
      final googleSignInAccount = await googleSignIn.signInSilently(suppressErrors: false);
      final googleSignInAuthentication = await googleSignInAccount.authentication;
      accessToken = googleSignInAuthentication.accessToken;
      return accessToken; // New refreshed accessToken
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    if (accessToken == null) {
      await _refreshAccessToken();
    }
    //print(accessToken);

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $accessToken",
    };

    return headers;
  }

  Future<TasksList> getLists(String userId) async {
    Map<String, String> headers = await _getHeaders();

    Response response = await get(
      'https://tasks.googleapis.com/tasks/v1/users/@me/lists?maxResults=100',
      headers: headers,
    );
    //print(response.body);

    TasksList tasksList = TasksList.fromJson(jsonDecode(response.body));

    return tasksList;
  }

  Future<bool> deleteList(String userId, String listId) => null;

  Future<String> createList(String userId, String listId, String title) async {
    Map<String, String> headers = await _getHeaders();
    var body = {"title": title};
    Response response = await post(
      'https://tasks.googleapis.com/tasks/v1/users/@me/lists',
      headers: headers,
      body: jsonEncode(body),
    );
    String _listId = jsonDecode(response.body)['id'];
    return _listId;
  }

  Future<String> updateList(String userId, String listId, String newListTitle) => null;

  Future<String> getMainListId(String userId, String listId, String listTitle) async {
    TasksList tasksList = await getLists(null);

    String mainListId;

    if (tasksList?.items != null) {
      for (Items item in tasksList?.items) {
        if (item.title == listTitle) {
          mainListId = item.id;
          break;
        }
      }
    }
    if (mainListId == null) {
      mainListId = await createList(userId, listId, listTitle);
    }

    return mainListId;
  }

  Future<List<Model.Todo>> getTasks(String listId, String userId) async {
    Map<String, String> headers = await _getHeaders();

    Response response = await get(
      'https://tasks.googleapis.com/tasks/v1/lists/$listId/tasks?showHidden=True&maxResults=100',
      headers: headers,
    );
    //print(response.body);

    ListDetails listDetails = ListDetails.fromJson(jsonDecode(response.body));

    List<Task> tasks = listDetails.tasks;

    List<Model.Todo> allTodos = tasks
        ?.map(
          (e) => Model.Todo(
            id: e.id,
            updated: DateTime.parse(e.updated),
            created: DateTime.parse(e.updated),
            listId: listId,
            title: e.title,
            status: e.status,
            position: e.position,
            userId: userId,
          ),
        )
        ?.toList();

    return allTodos;
  }

  Future<Model.Todo> createTask(Model.Todo todo) async {
    Map<String, String> headers = await _getHeaders();
    var body = jsonEncode({"title": todo.title});
    Response response = await post(
      'https://tasks.googleapis.com/tasks/v1/lists/${todo.listId}/tasks',
      headers: headers,
      body: body,
    );
    //print(response.body);
    Task task = Task.fromJson(jsonDecode(response.body));
    return Model.Todo(
      id: task.id,
      title: task.title,
      status: task.status,
      position: '-1',
      userId: todo.userId,
      listId: todo.listId,
      listTitle: todo.listTitle,
      created: DateTime.tryParse(task.updated),
      updated: DateTime.tryParse(task.updated),
    );
  }

  Future completeTask(Model.Todo todo) async {
    Map<String, String> headers = await _getHeaders();
    var body = jsonEncode({"status": "completed"});
    String url = 'https://www.googleapis.com/tasks/v1/lists/${todo.listId}/tasks/${todo.id}';
    Response response = await patch(url, headers: headers, body: body);
    //print(response.body);
  }

  Future unCompleteTask(Model.Todo todo) async {
    Map<String, String> headers = await _getHeaders();
    var body = jsonEncode({"status": "needsAction"});
    String url = 'https://www.googleapis.com/tasks/v1/lists/${todo.listId}/tasks/${todo.id}';
    Response response = await patch(url, headers: headers, body: body);
    //print(response.body);
  }

  Future deleteTask(Model.Todo todo) async {
    Map<String, String> headers = await _getHeaders();
    String url = 'https://www.googleapis.com/tasks/v1/lists/${todo.listId}/tasks/${todo.id}';
    Response response = await delete(url, headers: headers);
    //print(response.body);
  }
}
