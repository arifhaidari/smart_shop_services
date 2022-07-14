import 'package:flutter/material.dart';

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'title': title,
  //     'body': body,
  //     'payload': payload,
  //   };
  // }

  // ReceivedNotification.fromDb(Map map)
  //     : id = map["id"],
  //       title = map["title"],
  //       body = map["body"],
  //       payload = map["payload"];
}
