class TasksList {
  String kind;
  String etag;
  String nextPageToken;
  List<Items> items;

  TasksList({this.kind, this.etag, this.nextPageToken, this.items});

  TasksList.fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    etag = json['etag'];
    nextPageToken = json['nextPageToken'];
    if (json['items'] != null) {
      items = new List<Items>();
      json['items'].forEach((v) {
        items.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kind'] = this.kind;
    data['etag'] = this.etag;
    data['v'] = this.nextPageToken;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  String kind;
  String id;
  String etag;
  String title;
  String updated;
  String selfLink;

  Items({this.kind, this.id, this.etag, this.title, this.updated, this.selfLink});

  Items.fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    id = json['id'];
    etag = json['etag'];
    title = json['title'];
    updated = json['updated'];
    selfLink = json['selfLink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kind'] = this.kind;
    data['id'] = this.id;
    data['etag'] = this.etag;
    data['title'] = this.title;
    data['updated'] = this.updated;
    data['selfLink'] = this.selfLink;
    return data;
  }
}

/////////////////////////////////////////////////////////////////////////////
class ListDetails {
  String kind;
  String etag;
  String nextPageToken;
  List<Task> items;
  List<Task> get tasks {
    items?.sort();
    return items;
  }

  List<Task> get needsAction => items?.where((e) => e.isCompleted == false)?.toList();
  List<Task> get completed => items?.where((e) => e.isCompleted == true)?.toList();

  ListDetails({this.kind, this.etag, this.nextPageToken, this.items});

  ListDetails.fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    etag = json['etag'];
    nextPageToken = json['nextPageToken'];
    if (json['items'] != null) {
      items = new List<Task>();
      json['items'].forEach((v) {
        items.add(new Task.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kind'] = this.kind;
    data['etag'] = this.etag;
    data['nextPageToken'] = this.nextPageToken;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Task implements Comparable {
  @override
  int compareTo(other) {
    return int.tryParse(position) > int.tryParse(other.position) ? 1 : -1;
  }

  String kind;
  String id;
  String etag;
  String title;
  String updated;
  String selfLink;
  String parent;
  String position;
  String notes;
  String status;

  Task.fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    id = json['id'];
    etag = json['etag'];
    title = json['title'];
    updated = json['updated'];
    selfLink = json['selfLink'];
    parent = json['parent'];
    position = json['position'];
    notes = json['notes'];
    status = json['status'];
  }

  bool get isCompleted => status == 'completed';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kind'] = this.kind;
    data['id'] = this.id;
    data['etag'] = this.etag;
    data['title'] = this.title;
    data['updated'] = this.updated;
    data['selfLink'] = this.selfLink;
    data['parent'] = this.parent;
    data['position'] = this.position;
    data['notes'] = this.notes;
    data['status'] = this.status;
    return data;
  }
}
