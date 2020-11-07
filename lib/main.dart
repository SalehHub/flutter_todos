import 'package:flutter/material.dart';

import 'api.dart';
import 'model/db.dart';
import 'model/db_wrapper.dart';
import 'model/model.dart' as Model;
import 'models.dart';
import 'utils/utils.dart';
import 'widgets/done.dart';
import 'widgets/task_input.dart';
import 'widgets/todo.dart';

bool isAr = false;
String listId = 'main';
Set idTokens = {};

class TodosPage extends StatefulWidget {
  final String title;
  final bool isAr;
  final String listId;
  final googleSignIn;

  const TodosPage({Key key, this.title, this.isAr: false, this.listId, this.googleSignIn}) : super(key: key);

  @override
  _TodosPageState createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  String welcomeMsg;
  List<Model.Todo> todos;
  List<Model.Todo> dones;

  TasksList tasksList;
  ListDetails listDetails;
  List<Task> tasks;
  Api api;

  bool loading = true;

  @override
  void initState() {
    isAr = widget.isAr ?? false;
    listId = widget.listId ?? 'main';
    welcomeMsg = widget.title ?? (isAr ? 'مدير المهام' : 'Todo List');

    api = Api(widget.googleSignIn);

    getMainListId();

    super.initState();
  }

  Future getMainListId() async {
    if (listId?.toLowerCase() != 'main') {
      listId = await api.getMainListId(listId);
    }

    await getTasks(listId);
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future getTasks(String listId) async {
    listDetails = await api.getTasks(listId);
    tasks = listDetails.tasks;
    //
    List<Model.Todo> allTodos = tasks
        ?.map((e) => Model.Todo(
            updated: DateTime.parse(e.updated),
            created: DateTime.parse(e.updated),
            listId: listId,
            title: e.title,
            status: e.status,
            selfLink: e.selfLink))
        ?.toList();

    for (Model.Todo td in allTodos) {
      DBWrapper.sharedInstance.addTodo(td);
    }

    updateTasksState(listId);

    // listDetails?.tasks?.forEach((e) {
    //   print(e.title);
    //   print(e.position);
    //   print(e.parent);
    //   print(e.selfLink);
    // });
    //print('______________________');

    // listDetails?.needsAction?.forEach((e) {
    //   print(e.title);
    //   print(e.status);
    //   print(e.isCompleted);
    // });
    //
    // print('______________________');
    // listDetails?.completed?.forEach((e) {
    //   print(e.title);
    //   print(e.position);
    //   print(e.isCompleted);
    // });
  }

  Future<void> updateTasksState(String listId) async {
    //sqlite
    //todos = await DBWrapper.sharedInstance.getTodos(listId);
    //dones = await DBWrapper.sharedInstance.getDones(listId);

    try {
      todos = tasks
          ?.where((element) => element.isCompleted == false)
          ?.map((e) => Model.Todo(listId: listId, title: e.title, selfLink: e.selfLink))
          ?.toList();
      dones = tasks
          ?.where((element) => element.isCompleted == true)
          ?.map((e) => Model.Todo(listId: listId, title: e.title, selfLink: e.selfLink))
          ?.toList();
    } catch (e) {}

    if (mounted) {
      setState(() {});
    }
  }

  Future getLists() async {
    tasksList = await api.getLists();
    tasksList.items.map((e) => print(e.title));
    if (mounted) {
      setState(() {});
    }

    //Response response = await get('https://tasks.googleapis.com//tasks/v1/users/@me/lists/MXh4eWlDa0x3aTNJU0NlRg', headers: headers);
    // Response response = await post(
    //   'https://tasks.googleapis.com/tasks/v1/users/@me/lists',
    //   headers: headers,
    //   body: jsonEncode({
    //     "kind": "tasks#taskList",
    //     "id": "main",
    //     "title": "Main",
    //   }),
    // );

    //print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        elevation: 0,
        //actions: [Popup(getTasks: getTasks)],
        centerTitle: true,
        title: GestureDetector(
            onTap: () {
              getLists();
            },
            child: Text(welcomeMsg)),
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
                          child: TaskInput(onSubmitted: addTaskInTodo),
                        );
                      case 1:
                        return Stack(
                          children: [
                            Todo(
                              todos: todos,
                              onTap: markTodoAsDone,
                              onDeleteTask: deleteTask,
                            ),
                            if (loading)
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 45.0, bottom: 20, left: 10, right: 10),
                                  child: Container(
                                    color: Colors.grey[800],
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                                ),
                              ),
                          ],
                        ); // Active todos
                      case 2:
                        return SizedBox(height: 30);
                      default:
                        return Stack(
                          children: [
                            Done(
                              dones: dones,
                              onTap: markDoneAsTodo,
                              onDeleteTask: deleteTask,
                            ),
                            if (loading)
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 45.0, bottom: 20, left: 10, right: 10),
                                  child: Container(
                                    color: Colors.grey[600],
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                                ),
                              ),
                          ],
                        ); // Done todos
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

  Future<void> addTaskInTodo({@required TextEditingController controller}) async {
    final inputText = controller.text.trim();

    if (inputText.length > 0) {
      Task task = await api.createTask(listId, inputText);

      // Add todos
      Model.Todo todo = Model.Todo(
        title: inputText,
        created: DateTime.now(),
        updated: DateTime.now(),
        status: kTodosStatusActive,
        listId: listId,
        selfLink: task.selfLink,
      );

      DBWrapper.sharedInstance.addTodo(todo);

      tasks.insert(0, task);
      updateTasksState(listId);
      //await getTasks(listId);
    }

    Utils.hideKeyboard(context);
    controller.text = '';
  }

  Future<void> markTodoAsDone({@required int pos, @required String selfLink}) async {
    DBWrapper.sharedInstance.markTodoAsDone(todos[pos]);

    api.completeTask(selfLink);

    Task task = tasks?.firstWhere((element) => element.selfLink == selfLink);
    task?.status = 'completed';
    int index = tasks?.indexWhere((element) => element.selfLink == selfLink);
    tasks?.removeWhere((element) => element.selfLink == selfLink);
    tasks?.insert(index, task);

    updateTasksState(listId);

    //await getTasks(listId);
  }

  Future<void> markDoneAsTodo({@required int pos, @required String selfLink}) async {
    DBWrapper.sharedInstance.markDoneAsTodo(dones[pos]);
    api.uncompleteTask(selfLink);

    Task task = tasks?.firstWhere((element) => element.selfLink == selfLink);
    task?.status = 'needsAction';
    int index = tasks?.indexWhere((element) => element.selfLink == selfLink);
    tasks?.removeWhere((element) => element.selfLink == selfLink);
    tasks?.insert(index, task);

    updateTasksState(listId);

    //await getTasks(listId);
  }

  Future<void> deleteTask({@required Model.Todo todo, @required String selfLink}) async {
    DBWrapper.sharedInstance.deleteTodo(todo);
    api.deleteTask(selfLink);

    tasks.removeWhere((element) => element.selfLink == selfLink);
    updateTasksState(listId);
    //await getTasks(listId);
  }
}
