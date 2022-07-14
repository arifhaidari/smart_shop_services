class BackupHistory {
  int id;
  String model;
  int model_id;
  String operation; // delete, update, add

  BackupHistory({
    this.id,
    this.model,
    this.model_id,
    this.operation,
  });

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'model_id': model_id,
      'operation': operation,
    };
  }

  BackupHistory.fromDb(Map map)
      : id = map["id"],
        model = map["model"],
        model_id = map["model_id"],
        operation = map['operation'];
}
