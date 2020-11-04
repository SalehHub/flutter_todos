import 'package:flutter/material.dart';
import 'package:flutter_todos/widgets/task_input.dart';
import 'package:flutter_todos/widgets/todo.dart';
import 'package:flutter_todos/widgets/done.dart';
import 'package:flutter_todos/model/model.dart' as Model;
import 'package:flutter_todos/model/db_wrapper.dart';
import 'package:flutter_todos/utils/utils.dart';
import 'package:flutter_todos/widgets/popup.dart';

bool isAr = false;
int category;

class HomeScreen extends StatefulWidget {
  final String title;
  final bool isAr;
  final int category;

  const HomeScreen({Key key, @required this.title, this.isAr: false, @required this.category}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String welcomeMsg;
  List<Model.Todo> todos;
  List<Model.Todo> dones;
  //String _selection;

  @override
  void initState() {
    isAr = widget.isAr;
    category = widget.category;
    super.initState();
    getTodosAndDones(widget.category);
    welcomeMsg = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        //actions: [Popup(getTodosAndDones: getTodosAndDones)],
        centerTitle: true,
        title: Text(welcomeMsg),
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

  void getTodosAndDones(int id) async {
    final _todos = await DBWrapper.sharedInstance.getTodos(id);
    final _dones = await DBWrapper.sharedInstance.getDones(id);

    setState(() {
      todos = _todos;
      dones = _dones;
    });
  }

  void addTaskInTodo({@required TextEditingController controller}) {
    final inputText = controller.text.trim();

    if (inputText.length > 0) {
      // Add todos
      Model.Todo todo = Model.Todo(
        title: inputText,
        created: DateTime.now(),
        updated: DateTime.now(),
        status: Model.TodoStatus.active.index,
        category: category,
      );

      DBWrapper.sharedInstance.addTodo(todo);
      getTodosAndDones(widget.category);
    }

    Utils.hideKeyboard(context);
    controller.text = '';
  }

  void markTodoAsDone({@required int pos}) {
    DBWrapper.sharedInstance.markTodoAsDone(todos[pos]);
    getTodosAndDones(widget.category);
  }

  void markDoneAsTodo({@required int pos}) {
    DBWrapper.sharedInstance.markDoneAsTodo(dones[pos]);
    getTodosAndDones(widget.category);
  }

  void deleteTask({@required Model.Todo todo}) {
    DBWrapper.sharedInstance.deleteTodo(todo);
    getTodosAndDones(widget.category);
  }
}
