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
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        color: cardColor,
        child: Stack(
          children: [
            Column(
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
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: isAr ? 'اكتب المهمة هنا' : 'What do you want to do?',
                          hintStyle: TextStyle(color: textColor),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
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
                        onPressed: () async {
                          setState(() {
                            loading = true;
                          });
                          await widget.onSubmitted(controller: textEditingController);
                          setState(() {
                            loading = false;
                          });
                        },
                        child: Text(isAr ? 'حفظ' : 'Save')),
                  ),
                )
              ],
            ),
            if (loading)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    color: Colors.grey[700],
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
