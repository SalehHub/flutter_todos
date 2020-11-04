import 'package:flutter/material.dart';
import '../utils/colors.dart';

import '../main.dart';

class SharedWidget {
  static Widget getCardHeader(
      {@required BuildContext context,
      @required String text,
      Color textColor = Colors.white,
      int backgroundColorCode = TodosColor.kPrimaryColorCode,
      double customFontSize}) {
    customFontSize ??= Theme.of(context).textTheme.headline6.fontSize;

    return Container(
      width: 85,
      alignment: AlignmentDirectional.center,
      margin: EdgeInsets.only(left: 32,right:32),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Color(backgroundColorCode),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: customFontSize,
        ),
      ),
    );
  }

  static Widget getOnDismissDeleteBackground() {
    return Container(
      alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
      color: Colors.red[300],
      padding: EdgeInsets.all(17),
      child: Text(
        isAr ? 'حذف' : 'DELETE',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
