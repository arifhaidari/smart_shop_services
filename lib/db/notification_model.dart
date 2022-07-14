class NotificationModel {
  int id;
  String subject; //invoice_number
  String timestamp;
  String detail_id;
  String note_type;
  bool seen_status;

  /// what seen status does is very amazing .... when
  ///  a notification generate for the first time it is false and that makes the bell icon red
  /// that some notifications are unread so when the user open the list the seen_status
  /// will become true and the bell icon will become white as well.

  /// the notifcaiton will be like place holder that it has some parameters that whenever something wrong happens somewhere
  /// it will notify the exact problem with sending arguments to the Notification class

  NotificationModel({
    this.id,
    this.subject,
    this.timestamp,
    this.detail_id,
    this.note_type,
    this.seen_status,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'timestamp': timestamp,
      'detail_id': detail_id,
      'note_type': note_type,
      'seen_status': seen_status,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'subject': subject,
      'timestamp': timestamp,
      'detail_id': detail_id,
      'note_type': note_type,
      'seen_status': seen_status,
    };
  }

  NotificationModel.fromDb(Map map)
      : id = map["id"],
        subject = map["subject"],
        timestamp = map["timestamp"],
        detail_id = map["detail_id"],
        note_type = map["note_type"],
        seen_status = map["seen_status"] == 1 ? true : false;

  factory NotificationModel.fromJson(Map<String, dynamic> item) {
    return NotificationModel(
      id: item['notification_pk'],
      subject: item['subject'],
      timestamp: item['timestamp'].toString(),
      detail_id: item['detail_id'],
      note_type: item['note_type'],
      seen_status: item['seen_status'],
    );
  }
}
