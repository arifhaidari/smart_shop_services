class LogActivation {
  int id;
  bool log_activate;
  bool backup_activation;

  LogActivation({
    this.id,
    this.log_activate,
    this.backup_activation,
  });

  Map<String, dynamic> toMap() {
    return {
      'log_activate': log_activate,
      'backup_activation': backup_activation,
    };
  }

  LogActivation.fromDb(Map map)
      : id = map["id"],
        backup_activation = map['backup_activation'] == 1 ? true : false,
        log_activate = map["log_activate"] == 1 ? true : false;
}
