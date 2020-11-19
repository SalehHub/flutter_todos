import 'package:flutter/material.dart';

import '../main.dart';
import '../model/model.dart' as Model;
import '../utils/colors.dart';
import 'shared.dart';
import 'task_item.dart';

class DoneWidget extends StatefulWidget {
  final Function onTap;
  final Function onDeleteTask;
  final List<Model.Todo> dones;

  DoneWidget({@required this.dones, this.onTap, this.onDeleteTask});

  @override
  _DoneWidgetState createState() => _DoneWidgetState();
}

class _DoneWidgetState extends State<DoneWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 50),
                if (widget.dones == null || widget?.dones?.length == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Center(
                      child: Text(isAr ? 'لايوجد مهام منجزة' : 'No done tasks', style: TextStyle(color: textColor)),
                    ),
                  ),
                if (widget.dones != null && (widget?.dones?.length ?? 0) > 0)
                  for (int i = (widget?.dones?.length ?? 0) - 1; i >= 0; --i)
                    TaskItem(
                      isDone: true,
                      isLast: (i == 0),
                      todo: widget.dones[i],
                      index: i,
                      onDeleteTask: widget.onDeleteTask,
                      onTap: () async {
                        await widget.onTap(widget.dones[i]);
                      },
                    ),
              ],
            ),
          ),
        ),
        SharedWidget.getCardHeader(
            context: context,
            text: isAr ? 'المنجزة' : 'DONE',
            backgroundColorCode: TodosColor.kSecondaryColorCode,
            customFontSize: 16),
      ],
    );
  }
}
