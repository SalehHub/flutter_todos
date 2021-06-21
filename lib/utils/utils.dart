import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/colors.dart';

const AlwaysStoppedAnimation<Color> darkerGrayValueColor = AlwaysStoppedAnimation<Color>(Color(0xff414141));
const AlwaysStoppedAnimation<Color> whiteValueColor = AlwaysStoppedAnimation<Color>(Colors.white);

bool isDark(context) => Theme.of(context).brightness == Brightness.dark;

Widget themedCircularProgressIndicator(bool isDark) {
  return Center(child: CircularProgressIndicator(valueColor: isDark ? whiteValueColor : darkerGrayValueColor));
}

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

  static Future<bool> showCustomDialog(BuildContext context) {
    final dialog = AlertDialog(
      backgroundColor: cardColor,
      title: Text(isAr ? 'هل أنت متأكد؟' : 'Are you sure?'),
      content: Text(
        isAr ? 'سيتم حذف جميع بيانات هذه القائمة!' : 'This will delete this todo list nd all of its items!',
      ),
      actions: <Widget>[
        RaisedButton(
          color: Color(TodosColor.kPrimaryColorCode),
          onPressed: () => Navigator.pop(context, true),
          child: Text(isAr ? 'نعم' : 'Yes', style: TextStyle(color: Colors.white)),
        ),
        RaisedButton(
          color: Color(TodosColor.kSecondaryColorCode),
          onPressed: () => Navigator.pop(context, false),
          child: Text(isAr ? 'الغاء' : 'Cancel', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
    return showDialog(context: context, builder: (x) => dialog);
  }
}
