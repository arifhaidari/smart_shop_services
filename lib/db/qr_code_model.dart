class QrcodeModel {
  int id;
  String name;
  String qr_data;

  QrcodeModel({
    this.id,
    this.name,
    this.qr_data,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'qr_data': qr_data,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'name': name,
      'qr_data': qr_data,
    };
  }

  QrcodeModel.fromDb(Map map)
      : id = map["id"],
        name = map["name"],
        qr_data = map["qr_data"];

  factory QrcodeModel.fromJson(Map<String, dynamic> item) {
    return QrcodeModel(
      id: item['qr_code_pk'],
      name: item['name'],
      qr_data: item['qr_data'],
    );
  }
}
