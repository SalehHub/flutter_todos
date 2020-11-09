import 'dart:async';

import '../model/db.dart';
import '../model/model.dart' as Model;
import '../models.dart';
import 'api_interface.dart';

class FireStoreApi implements ApiInterface {
  final fireStore;

  FireStoreApi(this.fireStore);

  Future<TasksList> getLists() async {
    print("unimplemented");
    return null;
  }

  Future<String> getMainListId(String listId, String listTitle) {
    return Future.value(listId.hashCode.toString());
  }

  Future<List<Model.Todo>> getTasks(String listId, String userId) async {
    String path = 'tasks/$userId/$listId';
    //print(path);
    var data = await fireStore.collection(path).get();
    var docs = data.docs;
    List<Model.Todo> todos = [];

    if (docs != null) {
      for (var doc in docs) {
        //print(doc.data()['created']);
        //print(doc.data()['created'].runtimeType);
        todos.add(
          Model.Todo(
            id: doc.id,
            title: doc.data()['title'],
            status: doc.data()['status'],
            listId: doc.data()['listId'],
            userId: userId,
            created: DateTime.fromMicrosecondsSinceEpoch(doc.data()['created']),
          ),
        );
      }
    }

    return todos;
  }

  Future<Model.Todo> createTask(Model.Todo todo) async {
    final reference = fireStore.doc('tasks/${todo.userId}').collection(todo.listId).doc();
    await reference.set({
      'status': kTodosStatusActive,
      'title': todo.title,
      'listId': todo.listId,
      'created': DateTime.now().microsecondsSinceEpoch,
    });

    return Model.Todo(
      id: reference.id,
      title: todo.title,
      status: kTodosStatusActive,
      listId: todo.listId,
      userId: todo.userId,
      created: DateTime.now(),
    );
  }

  Future completeTask(Model.Todo todo) async {
    String path = 'tasks/${todo.userId}/${todo.listId}/${todo.id}';
    await fireStore.doc(path).update({'status': kTodosStatusDone});
  }

  Future unCompleteTask(Model.Todo todo) async {
    String path = 'tasks/${todo.userId}/${todo.listId}/${todo.id}';
    await fireStore.doc(path).update({'status': kTodosStatusActive});
  }

  Future deleteTask(Model.Todo todo) async {
    String path = 'tasks/${todo.userId}/${todo.listId}/${todo.id}';
    await fireStore.doc(path).delete();
  }
}
