import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_todos/list_details_page.dart';
import 'package:flutter_todos/utils/colors.dart';
import 'package:flutter_todos/utils/utils.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'model/db_wrapper.dart';
import 'models.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key key}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool creating = false;
  bool updating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        elevation: 0,
        centerTitle: true,
        title: Text((isAr ? 'مدير المهام' : 'Todo List')),
        actions: [
          creating
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(width: 25, height: 25, child: Center(child: CircularProgressIndicator())),
                  ),
                )
              : IconButton(icon: Icon(Icons.add), onPressed: () => showCreateListDialog(context)),
        ],
      ),
      body: Container(
        child: Consumer<AppState>(
          builder: (BuildContext context, AppState appState, Widget child) => ListView(children: [
            buildListCard(ListData('@default', '@default', DateTime.now())),
            ...(appState.listData.map(buildListCard).toList()),
          ]),
        ),
      ),
    );
  }

  void showCreateListDialog(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    final dialog = AlertDialog(
      backgroundColor: cardColor,
      title: Text(
        isAr ? 'إنشاء قائمة مهام جديدة' : 'Create a List',
      ),
      content: TextField(
        controller: textEditingController,
        maxLength: 50,
        maxLengthEnforced: true,
        decoration: InputDecoration(labelText: isAr ? "اسم القائمة" : "List name"),
      ),
      actions: <Widget>[
        RaisedButton(
          color: Color(TodosColor.kPrimaryColorCode),
          onPressed: () async {
            String name = textEditingController?.text?.trim();
            await createList(name);
          },
          child: Text(isAr ? 'إنشاء' : 'Create', style: TextStyle(color: Colors.white)),
        ),
        RaisedButton(
          color: Color(TodosColor.kSecondaryColorCode),
          onPressed: () => Navigator.pop(context),
          child: Text(isAr ? 'الغاء' : 'Cancel', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
    showDialog(context: context, builder: (x) => dialog);
  }

  void showUpdateListDialog(BuildContext context, ListData list) {
    TextEditingController textEditingController = TextEditingController(text: list.listTitle);
    final dialog = AlertDialog(
      backgroundColor: cardColor,
      title: Text(
        isAr ? 'تحديث قائمة المهام' : 'Update Todo List',
      ),
      content: TextField(
        controller: textEditingController,
        maxLength: 50,
        maxLengthEnforced: true,
        decoration: InputDecoration(labelText: isAr ? "اسم القائمة الجديد" : "New List name"),
      ),
      actions: <Widget>[
        RaisedButton(
          color: Color(TodosColor.kPrimaryColorCode),
          onPressed: () async {
            String name = textEditingController?.text?.trim();
            await updateList(name, list);
          },
          child: Text(isAr ? 'تحديث' : 'Update', style: TextStyle(color: Colors.white)),
        ),
        RaisedButton(
          color: Color(TodosColor.kSecondaryColorCode),
          onPressed: () => Navigator.pop(context),
          child: Text(isAr ? 'الغاء' : 'Cancel', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
    showDialog(context: context, builder: (x) => dialog);
  }

  Widget buildListCard(ListData e) {
    return Slidable(
      enabled: e.listId != '@default',
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: IconSlideAction(
              caption: isAr ? 'حذف' : 'DELETE',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () async => await deleteList(e),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: IconSlideAction(
              caption: isAr ? 'تعديل' : 'Edit',
              color: Colors.grey.shade400,
              icon: Icons.edit,
              onTap: () async => showUpdateListDialog(context, e),
            ),
          ),
        ),
      ],
      child: Card(
        color: cardColor,
        margin: EdgeInsets.all(5),
        child: Builder(
          builder: (context) => InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () {
              print(e);
              print(e);
              print(e);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (c) => ChangeNotifierProvider<AppState>.value(
                    value: appState,
                    builder: (context, child) => ListDetailsPage(listId: e.listId, listTitle: e.listTitle),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              child: ListTile(leading: Icon(Icons.view_list), title: Text(getListTitle(e.listTitle))),
            ),
          ),
        ),
      ),
    );
  }

  Future createList(String name) async {
    if (name != null && name.length > 0 && name.length < 51) {
      Navigator.pop(context, true);
      if (mounted) {
        setState(() => creating = true);
      }

      var _listId = name.hashCode.toString();
      await DBWrapper.sharedInstance.createList(ListData(_listId, name, DateTime.now()));
      await getListFromSqlite();

      await api.createList(userId, _listId, name);
      await getListFromFireStore();

      if (mounted) {
        setState(() => creating = false);
      }
    }
  }

  Future updateList(String name, ListData list) async {
    if (name != null && name.length > 0 && name.length < 51) {
      Navigator.pop(context, true);

      if (mounted) {
        setState(() => updating = true);
      }

      list.listTitle = name;
      await DBWrapper.sharedInstance.updateList(list);
      await getListFromSqlite();

      api.updateList(userId, list.listId, name).then((value) async {
        await getListFromFireStore();
        if (mounted) {
          setState(() => updating = false);
        }
      });
    }
  }

  Future deleteList(ListData e) async {
    bool result = await Utils.showCustomDialog(context);

    print(result);

    if (result == true) {
      await DBWrapper.sharedInstance.deleteList(userId, e.listId);
      await getListFromSqlite();

      await api.deleteList(userId, e.listId);
      getListFromFireStore();
    }
  }

  Future getListFromSqlite() async {
    List<ListData> _listData = await DBWrapper.sharedInstance.getLists();
    Provider.of<AppState>(context, listen: false).updateListData(_listData);
  }

  Future getListFromFireStore() async {
    //List<ListData> _listData = await api.getLists(userId);
    //Provider.of<AppState>(context, listen: false).updateListData(_listData);
  }
}
