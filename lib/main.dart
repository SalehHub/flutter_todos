import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';
import 'widgets/task_input.dart';
import 'widgets/todo.dart';
import 'widgets/done.dart';
import 'model/model.dart' as Model;
import 'model/db_wrapper.dart';
import 'utils/utils.dart';

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
  ListDetails listDetails;
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

    await getTodosAndDones(listId);

    setState(() {
      loading = false;
    });
  }

  Future getTasks(String listId) async {
    print(listId);
    print(listId);
    print(listId);
    print(listId);
    listDetails = await api.getTasks(listId);

    listDetails?.tasks?.forEach((e) {
      print(e.title);
      print(e.position);
      print(e.parent);
      print(e.selfLink);
    });

    todos = listDetails?.needsAction?.map((e) => Model.Todo(listId: listId, title: e.title, selfLink: e.selfLink))?.toList();
    dones = listDetails?.completed?.map((e) => Model.Todo(listId: listId, title: e.title, selfLink: e.selfLink))?.toList();
    setState(() {});

    print('______________________');

    listDetails?.needsAction?.forEach((e) {
      print(e.title);
      print(e.status);
      print(e.isCompleted);
    });

    print('______________________');
    listDetails?.completed?.forEach((e) {
      print(e.title);
      print(e.position);
      print(e.isCompleted);
    });
  }

  Future getLists() async {
    tasksList = await api.getLists();
    tasksList.items.map((e) => print(e.title));

    setState(() {});

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
        //actions: [Popup(getTodosAndDones: getTodosAndDones)],
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
                        return Todo(
                          todos: todos,
                          onTap: markTodoAsDone,
                          onDeleteTask: deleteTask,
                          loading: loading,
                        ); // Active todos
                      case 2:
                        return SizedBox(height: 30);
                      default:
                        return Done(
                          dones: dones,
                          onTap: markDoneAsTodo,
                          onDeleteTask: deleteTask,
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

  Future<void> getTodosAndDones(String listId) async {
    final _todos = await DBWrapper.sharedInstance.getTodos(listId);
    final _dones = await DBWrapper.sharedInstance.getDones(listId);
    // setState(() {
    //   todos = _todos;
    //   dones = _dones;
    // });

    await getTasks(listId);
  }

  Future<void> addTaskInTodo({@required TextEditingController controller}) async {
    final inputText = controller.text.trim();

    if (inputText.length > 0) {
      // Add todos
      Model.Todo todo = Model.Todo(
        title: inputText,
        created: DateTime.now(),
        updated: DateTime.now(),
        status: Model.TodoStatus.active.index,
        listId: listId,
      );

      DBWrapper.sharedInstance.addTodo(todo);

      await api.createTask(listId, inputText);

      getTodosAndDones(listId);
    }

    Utils.hideKeyboard(context);
    controller.text = '';
  }

  Future<void> markTodoAsDone({@required int pos, @required String selfLink}) async {
    DBWrapper.sharedInstance.markTodoAsDone(todos[pos]);
    await api.completeTask(selfLink);
    await getTodosAndDones(listId);
  }

  Future<void> markDoneAsTodo({@required int pos, @required String selfLink}) async {
    DBWrapper.sharedInstance.markDoneAsTodo(dones[pos]);
    await api.uncompleteTask(selfLink);
    await getTodosAndDones(listId);
  }

  Future<void> deleteTask({@required Model.Todo todo, @required String selfLink}) async {
    DBWrapper.sharedInstance.deleteTodo(todo);
    await api.deleteTask(selfLink);
    await getTodosAndDones(listId);
  }
}
