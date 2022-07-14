class SessionModel {
  int id;
  double opening_balance;
  String opening_time;
  String closing_time;
  String session_comment;
  bool close_status;
  bool drawer_status;

  SessionModel({
    this.id,
    this.opening_balance,
    this.opening_time,
    this.closing_time,
    this.session_comment,
    this.close_status,
    this.drawer_status,
  });

  Map<String, dynamic> toMap() {
    return {
      'opening_balance': opening_balance,
      'opening_time': opening_time,
      'closing_time': closing_time,
      'session_comment': session_comment,
      'close_status': close_status,
      'drawer_status': drawer_status,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'opening_balance': opening_balance,
      'opening_time': opening_time,
      'closing_time': closing_time,
      'session_comment': session_comment,
      'close_status': close_status,
      'drawer_status': drawer_status,
    };
  }

  SessionModel.fromDb(Map map)
      : id = map["id"],
        opening_balance = map["opening_balance"],
        opening_time = map["opening_time"],
        closing_time = map["closing_time"],
        session_comment = map["session_comment"],
        close_status = map["close_status"] == 1 ? true : false,
        drawer_status = map["drawer_status"] == 1 ? true : false;

  factory SessionModel.fromJson(Map<String, dynamic> item) {
    return SessionModel(
      id: item['session_pk'],
      opening_balance: item['opening_balance'],
      opening_time: item['opening_time'].toString(),
      closing_time: item['closing_time'].toString(),
      session_comment: item['session_comment'],
      close_status: item['close_status'],
      drawer_status: item['drawer_status'],
    );
  }
}
