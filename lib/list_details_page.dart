import 'package:flutter/material.dart';
import 'package:flutter_todos/models.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'model/db.dart';
import 'model/db_wrapper.dart';
import 'model/model.dart' as Model;
import 'utils/utils.dart';
import 'widgets/done.dart';
import 'widgets/task_input.dart';
import 'widgets/todo.dart';

class ListDetailsPage extends StatefulWidget {
  final String listTitle;
  final String listId;
  const ListDetailsPage({Key key, @required this.listId, @required this.listTitle}) : super(key: key);

  @override
  _ListDetailsPageState createState() => _ListDetailsPageState();
}

class _ListDetailsPageState extends State<ListDetailsPage> {
  List<Model.Todo> todos;
  List<Model.Todo> dones;
  bool loading = true;

  @override
  void initState() {
    getTodos();
    super.initState();
  }

  Future getTodos() async {
    await getTasksFromSqlite(widget.listId);

    print(todos);
    print(dones);

    if (todos?.isNotEmpty == true || dones?.isNotEmpty == true) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }

    //await getTasks(listId);
    await getTasksFromApi(widget.listId);
    if (mounted) {
      setState(() {
        loading = false;
      });
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
              //List<ListData> listData = Provider.of<AppState>(context, listen: false).listData;
            },
            child: Text(getListTitle(widget.listTitle), style: TextStyle(fontSize: 15))),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Utils.hideKeyboard(context),
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
                            TodoWidget(todos: todos, onTap: completeTask, onDeleteTask: deleteTask),
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
                            DoneWidget(dones: dones, onTap: unCompleteTask, onDeleteTask: deleteTask),
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

  Future updateSqliteData(List<Model.Todo> tasks) async {
    if (tasks?.isNotEmpty == true) {
      await DBWrapper.sharedInstance.deleteAllTodos(widget.listId);
    }
    if (tasks != null) {
      for (Model.Todo td in tasks) {
        try {
          await DBWrapper.sharedInstance.addTodo(td);
        } catch (e) {
          print(e);
        }
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
        listId: widget.listId,
        listTitle: widget.listTitle,
        status: kTodosStatusActive,
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      Model.Todo todo = await api.createTask(newTodo);

      await DBWrapper.sharedInstance.addTodo(todo);
      getTasks(widget.listId);

      //create list if it is not exist
      List<ListData> listData = Provider.of<AppState>(context, listen: false).listData;
      int exist = listData?.indexWhere((element) => element.listId == widget.listId);
      if (widget.listId != '@default' && (exist == null || exist == -1)) {
        print('create a list:$exist');
        await DBWrapper.sharedInstance.createList(ListData(
          widget.listId,
          widget.listTitle,
          DateTime.now(),
        ));

        //refresh
        List<ListData> _listData = await DBWrapper.sharedInstance.getLists();
        Provider.of<AppState>(context, listen: false).updateListData(_listData);

        print(widget.listId);
        print(widget.listId);
        print(widget.listId);
        await api.createList(userId, widget.listId, widget.listTitle);
      }
    }

    Utils.hideKeyboard(context);
    controller.text = '';
  }

  Future<void> completeTask(Model.Todo todo) async {
    await DBWrapper.sharedInstance.markTodoAsDone(todo);
    api.completeTask(todo);
    getTasks(widget.listId);
  }

  Future<void> unCompleteTask(Model.Todo todo) async {
    await DBWrapper.sharedInstance.markDoneAsTodo(todo);
    api.unCompleteTask(todo);
    getTasks(widget.listId);
  }

  Future<void> deleteTask(Model.Todo todo) async {
    await DBWrapper.sharedInstance.deleteTodo(todo);
    api.deleteTask(todo);
    getTasks(widget.listId);
  }
}
