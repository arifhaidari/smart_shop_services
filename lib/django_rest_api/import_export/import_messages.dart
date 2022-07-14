class ImportMessages {
  bool error;
  String message;

  ImportMessages({
    this.error,
    this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'error': error,
      'message': message,
    };
  }
}
