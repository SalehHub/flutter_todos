import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todos/api/api_interface.dart';
import 'package:flutter_todos/api/empty_api.dart';
import 'package:flutter_todos/list_details_page.dart';
import 'package:provider/provider.dart';

import 'api/fire_store_api.dart';
import 'api/google_tasks_api.dart';
import 'list_page.dart';
import 'model/db_wrapper.dart';
import 'models.dart';

bool isAr = false;
String userId;
Color cardColor;
Color textColor;
ApiInterface api;

String getListTitle(String listTitle) {
  if (listTitle == "@default") {
    return isAr ? "القائمة العامة" : "Default";
  }
  return listTitle;
}

class AppState extends ChangeNotifier {
  List<ListData> listData = [];

  updateListData(List<ListData> _listData) {
    listData = _listData;
    listData.removeWhere((e) => e.listId == '@default');
    notifyListeners();
  }
}

AppState appState = AppState();

class TodosPage extends StatefulWidget {
  final String title;
  final bool isAr;
  final String listId;
  final String listTitle;
  final googleSignIn;
  final FirebaseFirestore fireStore;
  final String userId;
  final bool userFireStore;
  final bool userGoogleTasks;
  final Color cardColor;
  final Color textColor;

  const TodosPage({
    Key key,
    this.title,
    this.isAr: false,
    this.listId,
    this.googleSignIn,
    this.fireStore,
    this.userId,
    this.listTitle,
    this.userFireStore: true,
    this.userGoogleTasks: false,
    this.cardColor: Colors.black38,
    this.textColor: Colors.white,
  }) : super(key: key);

  @override
  _TodosPageState createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MainPage(
        title: widget.title,
        isAr: widget.isAr,
        listId: widget.listId,
        googleSignIn: widget.googleSignIn,
        fireStore: widget.fireStore,
        userId: widget.userId,
        listTitle: widget.listTitle,
        userFireStore: widget.userFireStore,
        userGoogleTasks: widget.userGoogleTasks,
        cardColor: widget.cardColor,
        textColor: widget.textColor,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final String title;
  final bool isAr;
  final String listId;
  final String listTitle;
  final googleSignIn;
  final FirebaseFirestore fireStore;
  final String userId;
  final bool userFireStore;
  final bool userGoogleTasks;
  final Color cardColor;
  final Color textColor;

  const MainPage({
    Key key,
    this.title,
    this.isAr: false,
    this.listId,
    this.googleSignIn,
    this.fireStore,
    this.userId,
    this.listTitle,
    this.userFireStore: true,
    this.userGoogleTasks: false,
    this.cardColor: Colors.black38,
    this.textColor: Colors.white,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool loading = true;
  String listId = '@default';
  String listTitle = '@default';
  @override
  void initState() {
    userId = widget.userId;
    cardColor = widget.cardColor;
    textColor = widget.textColor;
    isAr = widget.isAr ?? false;
    listId = widget.listId ?? '@default';
    listTitle = widget.listTitle ?? '@default';

    if (userId == null) {
      api = EmptyApi();
    } else if (widget.userFireStore == true) {
      assert(widget.fireStore != null);
      api = FireStoreApi(widget.fireStore);
    } else {
      assert(widget.googleSignIn != null);
      api = GoogleTasksApi(widget.googleSignIn);
    }
    getMainListId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading == true) {
      return Scaffold(
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          elevation: 0,
          centerTitle: true,
          title: Text((isAr ? 'مدير المهام' : 'Todo List')),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (listId?.toLowerCase() == '@default') {
      return TodoListPage();
    } else {
      print(listId);
      return ListDetailsPage(listId: listId, listTitle: listTitle);
    }
  }

  Future getMainListId() async {
    if (listId?.toLowerCase() != '@default') {
      listId = await api.getMainListId(userId, listId, listId);
    }
    await getLists();

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future getLists() async {
    List<ListData> _listData = await DBWrapper.sharedInstance.getLists();
    Provider.of<AppState>(context, listen: false).updateListData(_listData);

    _listData = await api.getLists(userId);

    if (_listData != null && _listData.isEmpty == false) {
      await DBWrapper.sharedInstance.deleteAllLists();
      _listData?.forEach((element) async {
        try {
          await DBWrapper.sharedInstance.createList(element);
        } catch (e) {
          try {
            await DBWrapper.sharedInstance.updateList(element);
          } catch (e) {}
        }
      });
    }

    Provider.of<AppState>(context, listen: false).updateListData(_listData);
  }
}
