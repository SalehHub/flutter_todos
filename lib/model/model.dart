enum TodoStatus { active, done }

class Todo {
  int id;
  String title;
  String selfLink;
  DateTime created;
  DateTime updated;
  int status;
  String listId;

  Todo({this.id, this.title, this.selfLink, this.created, this.updated, this.status, this.listId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      //'selfLink': selfLink,
      'created': created.toString(),
      'updated': updated.toString(),
      'status': status,
      'listId': listId,
    };
  }

  Map<String, dynamic> toMapAutoID() {
    return {
      'title': title,
      //'selfLink': selfLink,
      'created': created.toString(),
      'updated': updated.toString(),
      'status': TodoStatus.active.index,
      'listId': listId,
    };
  }
}
