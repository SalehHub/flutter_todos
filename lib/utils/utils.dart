import 'package:flutter/material.dart';
import 'package:flutter_todos/utils/colors.dart';

enum kMoreOptionsKeys {
  clearAll,
}

Map<int, String> kMoreOptionsMap = {
  kMoreOptionsKeys.clearAll.index: 'Clear Done',
};

Map<int, String> kArMoreOptionsMap = {
  kMoreOptionsKeys.clearAll.index: 'حذف كل المهام المنجزة',
};

class Utils {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  static void showCustomDialog(BuildContext context,
      {String title, String msg, String noBtnTitle: 'Close', Function onConfirm, String confirmBtnTitle: 'Yes'}) {
    final dialog = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: <Widget>[
        if (onConfirm != null)
          RaisedButton(
            color: Color(TodosColor.kPrimaryColorCode),
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: Text(
              confirmBtnTitle,
              style: TextStyle(color: Colors.white),
            ),
          ),
        RaisedButton(
          color: Color(TodosColor.kSecondaryColorCode),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(noBtnTitle, style: TextStyle(color: Colors.white)),
        ),
      ],
    );
    showDialog(context: context, builder: (x) => dialog);
  }
}
