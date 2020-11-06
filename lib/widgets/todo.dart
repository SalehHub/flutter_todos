import 'package:flutter/material.dart';
import '../widgets/shared.dart';
import '../model/model.dart' as Model;
import '../utils/colors.dart';

import '../main.dart';

const int NoTask = -1;
const int animationMilliseconds = 500;

class Todo extends StatefulWidget {
  final Function onTap;
  final Function onDeleteTask;
  final List<Model.Todo> todos;
  final bool loading;

  Todo({@required this.todos, this.onTap, this.onDeleteTask, this.loading});

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  int taskPosition = NoTask;
  bool showCompletedTaskAnimation = false;
  List<Widget> todosWidget = [];

  bool loading = false;

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
                        isAr ? 'استخدم مربع النص بالأعلى للبدأ بإضافة المهام' : 'Use the above text box to start adding new tasks',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                for (int i = 0; i < (widget?.todos?.length ?? 0); ++i)
                  getTaskItem(
                    widget.todos[i].title,
                    index: i,
                    onTap: () async {
                      setState(() {
                        loading = true;
                        taskPosition = i;
                        showCompletedTaskAnimation = true;
                      });
                      await widget.onTap(pos: i, selfLink: widget.todos[i].selfLink);
                      setState(() {
                        loading = false;
                        taskPosition = NoTask;
                        showCompletedTaskAnimation = false;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
        if (loading)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                color: Colors.grey[800],
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        SharedWidget.getCardHeader(context: context, text: isAr ? 'المهام' : 'TO DO', customFontSize: 16),
      ],
    );
  }

  Widget getTaskItem(String text, {@required int index, @required Function onTap}) {
    return Container(
        child: Column(
      children: <Widget>[
        Dismissible(
          key: Key(text + '$index'),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            widget.onDeleteTask(todo: widget.todos[index], selfLink: widget.todos[index].selfLink);
          },
          background: SharedWidget.getOnDismissDeleteBackground(),
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 0),
                    width: 7,
                    decoration: BoxDecoration(
                      color: TodosColor.sharedInstance.leadingTaskColor(index),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10, top: 15, right: 20, bottom: 15),
                      child: Text(text, style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 0.5, child: Container(color: Colors.grey)),
        SizedBox(height: 0),
      ],
    ));
  }
}
