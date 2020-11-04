// import 'package:flutter/material.dart';
// import 'package:flutter_todos/model/db_wrapper.dart';
// import 'package:flutter_todos/utils/utils.dart';

// import '../main.dart';

// class Popup extends StatelessWidget {
//   Function getTodosAndDones;

//   Popup({this.getTodosAndDones});

//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<int>(
//         elevation: 4,
//         icon: Icon(Icons.more_vert),
//         onSelected: (value) {
//           print('Selected value: $value');
//           if (value == kMoreOptionsKeys.clearAll.index) {
//             Utils.showCustomDialog(
//               context,
//               title: isAr ? 'هل أنت متأكد؟' : 'Are you sure?',
//               msg: isAr ? 'سيتم حذف جميع المهام المنجزة بشكل نهائي' : 'All done todos will be deleted permanently',
//               confirmBtnTitle: isAr ? 'نعم' : 'Yes',
//               noBtnTitle: isAr ? 'الغاء' : 'Close',
//               onConfirm: () {
//                 DBWrapper.sharedInstance.deleteAllDoneTodos();
//                 getTodosAndDones();
//               },
//             );
//           }
//         },
//         itemBuilder: (context) {
//           List list = List<PopupMenuEntry<int>>();

//           for (int i = 0; i < kMoreOptionsMap.length; ++i) {
//             list.add(PopupMenuItem(value: i, child: Text(isAr ? kArMoreOptionsMap[i] : kMoreOptionsMap[i])));

//             if (i == 0) {
//               list.add(PopupMenuDivider(
//                 height: 5,
//               ));
//             }
//           }

//           return list;
//         });
//   }
// }
