class ExpenseModel {
  int id;
  String expense_type;
  String reason;
  double amount;
  String timestamp;
  int session_id;

  ExpenseModel({
    this.id,
    this.expense_type,
    this.reason,
    this.amount,
    this.timestamp,
    this.session_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'expense_type': expense_type,
      'reason': reason,
      'amount': amount,
      'timestamp': timestamp,
      'session_id': session_id,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'expense_type': expense_type,
      'reason': reason,
      'amount': amount,
      'timestamp': timestamp,
      'session_id': session_id,
    };
  }

  ExpenseModel.fromDb(Map map)
      : id = map["id"],
        expense_type = map["expense_type"],
        reason = map["reason"],
        amount = map["amount"],
        timestamp = map["timestamp"],
        session_id = map["session_id"];

  factory ExpenseModel.fromJson(Map<String, dynamic> item) {
    return ExpenseModel(
      id: item['expense_pk'],
      expense_type: item['expense_type'],
      reason: item['reason'],
      amount: item['amount'],
      timestamp: item['timestamp'].toString(),
      session_id: item['session_id'],
    );
  }
}
