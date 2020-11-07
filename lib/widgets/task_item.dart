import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../main.dart';
import '../model/model.dart' as Model;
import '../utils/colors.dart';

class TaskItem extends StatefulWidget {
  const TaskItem(
      {Key key,
      @required this.todo,
      @required this.index,
      @required this.onDeleteTask,
      @required this.onTap,
      this.isDone: false})
      : super(key: key);

  final Model.Todo todo;
  final int index;
  final Function onDeleteTask;
  final Function onTap;
  final bool isDone;

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      children: [
        Column(
          children: <Widget>[
            Slidable(
              actionPane: SlidableScrollActionPane(),
              actionExtentRatio: 0.25,
              actions: <Widget>[
                IconSlideAction(
                  caption: isAr ? 'حذف' : 'DELETE',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () async {
                    setState(() {
                      loading = true;
                    });
                    await widget.onDeleteTask(widget.todo);
                    setState(() {
                      loading = false;
                    });
                  },
                ),
              ],
              child: InkWell(
                onTap: () async {
                  setState(() {
                    loading = true;
                  });
                  await widget.onTap();
                  setState(() {
                    loading = false;
                  });
                },
                child: IntrinsicHeight(
                  child: Row(
                    children: <Widget>[
                      if (!widget.isDone)
                        Container(
                          margin: EdgeInsets.only(top: 0),
                          width: 5,
                          decoration: BoxDecoration(color: TodosColor.sharedInstance.leadingTaskColor(widget.index)),
                        ),
                      if (widget.isDone)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(Icons.check),
                        ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 5, top: 15, right: 5, bottom: 15),
                          child: Text(widget.todo.title, style: TextStyle(color: Colors.white)),
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
        ),
        if (loading)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                color: widget.isDone ? Colors.grey[600] : Colors.grey[800],
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
      ],
    ));
  }
}
