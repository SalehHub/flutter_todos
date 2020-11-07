class Todo implements Comparable {
  @override
  int compareTo(other) {
    if (position != null && other.position != null) {
      return int.tryParse(position) > int.tryParse(other.position) ? 1 : -1;
    }
    return -1;
  }

  int id;
  String title;
  String selfLink;
  DateTime created;
  DateTime updated;
  String status;
  String listId;
  String position;

  Todo({this.id, this.title, this.selfLink, this.created, this.updated, this.status, this.position, this.listId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'selfLink': selfLink,
      'created': created.toString(),
      'updated': updated.toString(),
      'status': status,
      'position': position,
      'listId': listId,
    };
  }

  Map<String, dynamic> toMapAutoID() {
    return {
      'title': title,
      'selfLink': selfLink,
      'created': created.toString(),
      'updated': updated.toString(),
      'status': status,
      'position': position,
      'listId': listId,
    };
  }
}
