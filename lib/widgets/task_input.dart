import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/colors.dart';

class TaskInput extends StatefulWidget {
  final Function onSubmitted;

  TaskInput({@required Function this.onSubmitted});

  @override
  _TaskInputState createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        color: Colors.grey[700],
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 5),
                  width: 40,
                  child: Icon(Icons.add, color: Color(TodosColor.kPrimaryColorCode), size: 30),
                ),
                Expanded(
                  child: TextFormField(
                    maxLines: null,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        hintText: isAr ? 'اكتب المهمة هنا' : 'What do you want to do?',
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none),
                    textInputAction: TextInputAction.newline,
                    controller: textEditingController,
                  ),
                ),
                Container(margin: EdgeInsets.only(top: 5), width: 20, child: SizedBox()),
              ],
            ),
            Align(
              alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    color: Color(TodosColor.kPrimaryColorCode),
                    textColor: Colors.white,
                    onPressed: () {
                      widget.onSubmitted(controller: textEditingController);
                    },
                    child: Text(isAr ? 'حفظ' : 'Save')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
