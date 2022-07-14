class Logs {
  int id;
  String operation; // edit, delete, add
  String detail;
  int model_id;
  String model; // product, expense,
  String timestamp;

  Logs({
    this.id,
    this.operation,
    this.detail,
    this.model_id,
    this.model,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'operation': operation,
      'detail': detail,
      'model_id': model_id,
      'model': model,
      'timestamp': timestamp
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'operation': operation,
      'detail': detail,
      'model_id': model_id,
      'model': model,
      'timestamp': timestamp
    };
  }

  Logs.fromDb(Map map)
      : id = map["id"],
        operation = map["operation"],
        detail = map["detail"],
        model_id = map["model_id"],
        model = map["model"],
        timestamp = map['timestamp'];

  factory Logs.fromJson(Map<String, dynamic> item) {
    return Logs(
      id: item['log_pk'],
      operation: item['operation'],
      detail: item['detail'],
      model_id: item['model_id'],
      model: item['model'],
      timestamp: item['timestamp'],
    );
  }
}
