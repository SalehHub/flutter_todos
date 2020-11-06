import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../model/model.dart' as Model;
import '../widgets/shared.dart';
import 'task_item.dart';

const int NoTask = -1;
const int animationMilliseconds = 500;

class Todo extends StatefulWidget {
  final Function onTap;
  final Function onDeleteTask;
  final List<Model.Todo> todos;

  Todo({@required this.todos, this.onTap, this.onDeleteTask});

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  int taskPosition = NoTask;
  bool showCompletedTaskAnimation = false;
  List<Widget> todosWidget = [];

  @override
  void initState() {
    //loading = widget.loading;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          color: Colors.grey[800],
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 50),
                if (widget.todos == null || widget?.todos?.length == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Center(
                      child: Text(
                        isAr
                            ? 'استخدم مربع النص بالأعلى للبدأ بإضافة المهام'
                            : 'Use the above text box to start adding new tasks',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                for (int i = 0; i < (widget?.todos?.length ?? 0); ++i)
                  TaskItem(
                    todo: widget.todos[i],
                    index: i,
                    onDeleteTask: widget.onDeleteTask,
                    onTap: () async {
                      setState(() {
                        taskPosition = i;
                        showCompletedTaskAnimation = true;
                      });
                      await widget.onTap(pos: i, selfLink: widget.todos[i].selfLink);
                      setState(() {
                        taskPosition = NoTask;
                        showCompletedTaskAnimation = false;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
        SharedWidget.getCardHeader(context: context, text: isAr ? 'المهام' : 'TO DO', customFontSize: 16),
      ],
    );
  }
}
