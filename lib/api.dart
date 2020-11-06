import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'models.dart';

class Api {
  final googleSignIn;
  String accessToken;

  Api(this.googleSignIn);

  Future<String> refreshAccessToken() async {
    try {
      print("accessToken Refresh");
      final googleSignInAccount = await googleSignIn.signInSilently();
      final googleSignInAuthentication = await googleSignInAccount.authentication;
      accessToken = googleSignInAuthentication.accessToken;
      print(accessToken);
      return accessToken; // New refreshed accessToken
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> getHeaders() async {
    if (accessToken == null) {
      await refreshAccessToken();
    }

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $accessToken",
    };

    return headers;
  }

  Future<TasksList> getLists() async {
    Map<String, String> headers = await getHeaders();

    Response response = await get('https://tasks.googleapis.com/tasks/v1/users/@me/lists?maxResults=100', headers: headers);
    print(response.body);

    TasksList tasksList = TasksList.fromJson(jsonDecode(response.body));

    return tasksList;
  }

  Future<String> createList(String title) async {
    Map<String, String> headers = await getHeaders();
    var body = {
      //"kind": "tasks#taskList",
      //"id": "main",
      "title": title,
    };
    Response response = await post('https://tasks.googleapis.com/tasks/v1/users/@me/lists', headers: headers, body: jsonEncode(body));

    String listId = jsonDecode(response.body)['id'];

    print(listId);
    print(listId);
    print(listId);

    return listId;
  }

  Future<String> getMainListId(String listTitle) async {
    TasksList tasksList = await getLists();

    String mainListId;

    for (Items item in tasksList.items) {
      if (item.title == listTitle) {
        mainListId = item.id;
        break;
      }
    }

    if (mainListId == null) {
      mainListId = await createList(listTitle);
    }

    return mainListId;
  }

  Future<ListDetails> getTasks(String listId) async {
    Map<String, String> headers = await getHeaders();

    if (listId?.toLowerCase() == 'main') {
      listId = '@default';
    }

    Response response = await get('https://tasks.googleapis.com/tasks/v1/lists/$listId/tasks?showHidden=True&maxResults=100', headers: headers);
    print(response.body);

    ListDetails listDetails = ListDetails.fromJson(jsonDecode(response.body));

    return listDetails;
  }

  Future createTask(String listId, String title) async {
    Map<String, String> headers = await getHeaders();

    var body = jsonEncode({
      "title": title,
    });

    if (listId?.toLowerCase() == 'main') {
      listId = '@default';
    }

    Response response = await post('https://tasks.googleapis.com/tasks/v1/lists/$listId/tasks', headers: headers, body: body);
    print(response.body);
  }

  Future completeTask(selfLink) async {
    Map<String, String> headers = await getHeaders();

    var body = jsonEncode({
      "status": "completed",
    });

    Response response = await patch(selfLink, headers: headers, body: body);
    print(response.body);
  }

  Future uncompleteTask(selfLink) async {
    Map<String, String> headers = await getHeaders();

    var body = jsonEncode({
      "status": "needsAction",
    });

    Response response = await patch(selfLink, headers: headers, body: body);
    print(response.body);
  }

  Future deleteTask(selfLink) async {
    Map<String, String> headers = await getHeaders();

    Response response = await delete(selfLink, headers: headers);
    print(response.body);
  }
}
