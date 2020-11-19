import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/db.dart';
import '../model/model.dart' as Model;
import '../models.dart';
import 'api_interface.dart';

class FireStoreApi implements ApiInterface {
  final FirebaseFirestore fireStore;

  FireStoreApi(this.fireStore);

  Future<List<ListData>> getLists(String userId) async {
    final user = await fireStore.doc('tasks/$userId').get();
    Map<String, dynamic> data = user.data();
    List<ListData> listData = [];
    data?.forEach((key, value) {
      Timestamp date = value['date'];
      listData.add(ListData(key, value['title'], date.toDate()));
    });
    listData.sort();
    return listData;
  }

  Future<String> getMainListId(String userId, String listId, String listTitle) {
    return Future.value(listId.hashCode.toString());
  }

  Future<bool> deleteList(String userId, String listId) async {
    try {
      final String userPath = 'tasks/$userId';
      await fireStore.doc(userPath).update({listId: FieldValue.delete()});

      final String listPath = '$userPath/$listId';
      final QuerySnapshot query = await fireStore.collection(listPath).snapshots().first;
      query.docs.forEach((element) async {
        await element.reference.delete();
      });
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Future<String> createList(String userId, String listId, String listTitle) async {
    final user = fireStore.doc('tasks/$userId');
    var data = {
      listId: {'title': listTitle, 'date': FieldValue.serverTimestamp()}
    };
    await user.set(data, SetOptions(merge: true));
    return listId;
  }

  Future<String> updateList(String userId, String listId, String newListTitle) async {
    final user = fireStore.doc('tasks/$userId');
    var data = {
      listId: {'title': newListTitle}
    };
    await user.set(data, SetOptions(merge: true));
    return listId;
  }

  Future<List<Model.Todo>> getTasks(String listId, String userId) async {
    String path = 'tasks/$userId/$listId';
    //print(path);
    var data = await fireStore.collection(path).orderBy('created', descending: true).get();
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
            listTitle: doc.data()['listTitle'],
            userId: userId,
            created: DateTime.fromMicrosecondsSinceEpoch(doc.data()['created']),
          ),
        );
      }
    }

    return todos;
  }

  Future<Model.Todo> createTask(Model.Todo todo) async {
    final user = fireStore.doc('tasks/${todo.userId}');
    final reference = user.collection(todo.listId).doc();
    await reference.set({
      'status': kTodosStatusActive,
      'title': todo.title,
      'listId': todo.listId,
      'listTitle': todo.listTitle,
      'created': DateTime.now().microsecondsSinceEpoch,
    });

    return Model.Todo(
      id: reference.id,
      title: todo.title,
      status: kTodosStatusActive,
      listId: todo.listId,
      listTitle: todo.listTitle,
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
