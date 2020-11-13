import 'package:flutter/material.dart';
import 'package:flutter_todos/api/api_interface.dart';
import 'package:flutter_todos/api/empty_api.dart';

import 'api/fire_store_api.dart';
import 'api/google_tasks_api.dart';
import 'model/db.dart';
import 'model/db_wrapper.dart';
import 'model/model.dart' as Model;
import 'utils/utils.dart';
import 'widgets/done.dart';
import 'widgets/task_input.dart';
import 'widgets/todo.dart';

bool isAr = false;
String listId = '@default';
Color cardColor;
Color textColor;

class TodosPage extends StatefulWidget {
  final String title;
  final bool isAr;
  final String listId;
  final googleSignIn;
  final fireStore;
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
    this.userFireStore: true,
    this.userGoogleTasks: false,
    this.cardColor: Colors.black38,
    this.textColor: Colors.white,
  }) : super(key: key);

  @override
  _TodosPageState createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  String welcomeMsg;
  List<Model.Todo> todos;
  List<Model.Todo> dones;

  ApiInterface api;

  bool loading = true;
  String userId;

  @override
  void initState() {
    userId = widget.userId;
    cardColor = widget.cardColor;
    textColor = widget.textColor;
    isAr = widget.isAr ?? false;
    listId = widget.listId ?? '@default';
    welcomeMsg = widget.title ?? (isAr ? 'مدير المهام' : 'Todo List');

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
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        elevation: 0,
        centerTitle: true,
        title: GestureDetector(
          onTap: () {},
          child: Text(welcomeMsg),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            Utils.hideKeyboard(context);
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    switch (index) {
                      case 0:
                        return Container(
                          margin: EdgeInsets.only(top: 20, bottom: 20),
                          child: TaskInput(onSubmitted: createTask),
                        );
                      case 1:
                        return Stack(
                          children: [
                            Todo(
                              todos: todos,
                              onTap: completeTask,
                              onDeleteTask: deleteTask,
                            ),
                            if (loading)
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 45.0, bottom: 20, left: 10, right: 10),
                                  child: Container(color: cardColor, child: Center(child: CircularProgressIndicator())),
                                ),
                              ),
                          ],
                        );
                      case 2:
                        return SizedBox(height: 30);
                      default:
                        return Stack(
                          children: [
                            Done(
                              dones: dones,
                              onTap: unCompleteTask,
                              onDeleteTask: deleteTask,
                            ),
                            if (loading)
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 45.0, bottom: 20, left: 10, right: 10),
                                  child: Container(color: cardColor, child: Center(child: CircularProgressIndicator())),
                                ),
                              ),
                          ],
                        );
                    }
                  },
                  childCount: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getMainListId() async {
    if (listId?.toLowerCase() != '@default') {
      listId = await api.getMainListId(listId, listId);
    }

    todos = await DBWrapper.sharedInstance.getTodos(listId);
    dones = await DBWrapper.sharedInstance.getDones(listId);

    if (todos?.isNotEmpty == true || dones?.isNotEmpty == true) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }

    //await getTasks(listId);
    await getTasksFromApi(listId);
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future updateSqliteData(List<Model.Todo> tasks) async {
    if (tasks?.isNotEmpty == true) {
      await DBWrapper.sharedInstance.deleteAllTodos(listId);
    }
    if (tasks != null) {
      for (Model.Todo td in tasks) {
        try {
          await DBWrapper.sharedInstance.addTodo(td);
        } catch (e) {}
      }
    }
  }

  Future<void> getTasksFromSqlite(String listId) async {
    todos = await DBWrapper.sharedInstance.getTodos(listId);
    todos?.sort();
    dones = await DBWrapper.sharedInstance.getDones(listId);
    dones?.sort();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getTasksFromApi(String listId) async {
    List<Model.Todo> tasks = await api.getTasks(listId, userId);
    await updateSqliteData(tasks);

    if (tasks == null || tasks.isEmpty == true) {
      await getTasksFromSqlite(listId);
    } else {
      todos = tasks?.where((element) => element.status == kTodosStatusActive)?.toList();
      todos?.sort();

      dones = tasks?.where((element) => element.status == kTodosStatusDone)?.toList();
      todos?.sort();

      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> getTasks(String listId) async {
    //await getTasksFromApi(listId);
    await getTasksFromSqlite(listId);
  }

  Future<void> createTask({@required TextEditingController controller}) async {
    final title = controller.text.trim();
    if (title.length > 0) {
      Model.Todo newTodo = Model.Todo(
        id: null,
        userId: userId,
        title: title,
        listId: listId,
        status: kTodosStatusActive,
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      Model.Todo todo = await api.createTask(newTodo);

      await DBWrapper.sharedInstance.addTodo(todo);
      getTasks(listId);
    }

    Utils.hideKeyboard(context);
    controller.text = '';
  }

  Future<void> completeTask(Model.Todo todo) async {
    await DBWrapper.sharedInstance.markTodoAsDone(todo);
    api.completeTask(todo);
    getTasks(listId);
  }

  Future<void> unCompleteTask(Model.Todo todo) async {
    await DBWrapper.sharedInstance.markDoneAsTodo(todo);
    api.unCompleteTask(todo);
    getTasks(listId);
  }

  Future<void> deleteTask(Model.Todo todo) async {
    await DBWrapper.sharedInstance.deleteTodo(todo);
    api.deleteTask(todo);
    getTasks(listId);
  }
}
