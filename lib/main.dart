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

    todos = await DBWrapper.sharedInstance.getTodos(listId);
    dones = await DBWrapper.sharedInstance.getDones(listId);

    if (todos?.isNotEmpty == true || dones?.isNotEmpty == true) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }

    await getTasks(listId);
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future getTasks(String listId) async {
    ListDetails listDetails = await api.getTasks(listId);
    tasks = listDetails.tasks;

    List<Model.Todo> allTodos = tasks
        ?.map((e) => Model.Todo(
              updated: DateTime.parse(e.updated),
              created: DateTime.parse(e.updated),
              listId: listId,
              title: e.title,
              status: e.status,
              selfLink: e.selfLink,
              position: e.position,
            ))
        ?.toList();

    if (allTodos != null) {
      for (Model.Todo td in allTodos) {
        try {
          await DBWrapper.sharedInstance.addTodo(td);
        } catch (e) {}
      }

      for (Model.Todo td in allTodos) {
        try {
          await DB.sharedInstance.updateTodoUsingSelfLink(td);
        } catch (e) {}
      }
    }
    updateTasksState(listId);
  }

  Future<void> updateTasksStateSqlite(String listId) async {
    todos = await DBWrapper.sharedInstance.getTodos(listId);
    todos?.sort();
    dones = await DBWrapper.sharedInstance.getDones(listId);
    dones?.sort();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> updateTasksStateApi(String listId) async {
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

  Future<void> updateTasksState(String listId) async {
    updateTasksStateSqlite(listId);

    //updateTasksStateApi(listId);
  }

  Future getLists() async {
    tasksList = await api.getLists();
    tasksList.items.map((e) => print(e.title));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        elevation: 0,
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            getLists();
          },
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
                        );
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

  Future<void> addTaskInTodo({@required TextEditingController controller}) async {
    final inputText = controller.text.trim();

    if (inputText.length > 0) {
      Task task = await api.createTask(listId, inputText);

      Model.Todo todo = Model.Todo(
        title: inputText,
        created: DateTime.now(),
        updated: DateTime.now(),
        status: kTodosStatusActive,
        listId: listId,
        selfLink: task.selfLink,
        position: '-1',
      );

      await DBWrapper.sharedInstance.addTodo(todo);
      //tasks.insert(0, task);
      updateTasksState(listId);
      //await getTasks(listId);
    }

    Utils.hideKeyboard(context);
    controller.text = '';
  }

  Future<void> markTodoAsDone(Model.Todo todo) async {
    DBWrapper.sharedInstance.markTodoAsDone(todo);

    api.completeTask(todo.selfLink);

    // Task task = tasks?.firstWhere((element) => element.selfLink == todo.selfLink);
    // task?.status = kTodosStatusDone;
    // int index = tasks?.indexWhere((element) => element.selfLink == todo.selfLink);
    // tasks?.removeWhere((element) => element.selfLink == todo.selfLink);
    // tasks?.insert(index, task);

    updateTasksState(listId);
  }

  Future<void> markDoneAsTodo(Model.Todo todo) async {
    DBWrapper.sharedInstance.markDoneAsTodo(todo);
    api.uncompleteTask(todo.selfLink);

    // Task task = tasks?.firstWhere((element) => element.selfLink == todo.selfLink);
    // task?.status = kTodosStatusActive;
    // int index = tasks?.indexWhere((element) => element.selfLink == todo.selfLink);
    // tasks?.removeWhere((element) => element.selfLink == todo.selfLink);
    // tasks?.insert(index, task);

    updateTasksState(listId);
  }

  Future<void> deleteTask(Model.Todo todo) async {
    DBWrapper.sharedInstance.deleteTodo(todo);
    api.deleteTask(todo.selfLink);

    // tasks?.removeWhere((element) => element.selfLink == todo.selfLink);

    updateTasksState(listId);
  }
}
