import 'dart:math';

import 'package:flutter/foundation.dart';

class Todo implements Comparable {
  @override
  int compareTo(other) {
    if (position != null && other?.position != null) {
      return int.tryParse(position) > int.tryParse(other.position) ? 1 : -1;
    } else {
      if (created != null && other?.created != null) {
        return created.microsecondsSinceEpoch < other.created.microsecondsSinceEpoch ? 1 : -1;
      }
    }
    return -1;
  }

  String id;
  String title;
  DateTime created;
  DateTime updated;
  String status;
  String listId;
  String position;
  String userId;
  String listTitle;

  Todo({
    @required this.id,
    @required this.title,
    this.created,
    this.updated,
    this.status,
    this.position,
    @required this.listId,
    @required this.listTitle,
    @required this.userId,
  });

  Map<String, dynamic> toMap() {
    var randomID = Random().nextInt(1000).toString() +
        DateTime.now().microsecondsSinceEpoch.toString() +
        listId.hashCode.toString() +
        title.hashCode.toString();
    return {
      'id': id ?? randomID,
      'title': title,
      'created': created.toString(),
      'updated': updated.toString(),
      'status': status,
      'position': position,
      'listId': listId,
      'listTitle': listTitle,
      'userId': userId ?? 'guest',
    };
  }

  // Map<String, dynamic> toMapAutoID() {
  //   return {
  //     'title': title,
  //     'selfLink': selfLink,
  //     'created': created.toString(),
  //     'updated': updated.toString(),
  //     'status': status,
  //     'position': position,
  //     'listId': listId,
  //   };
  // }
}
