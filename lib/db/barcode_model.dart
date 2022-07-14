class BarcodeModel {
  int id;
  String name;
  int product_id;
  String barcode_text;

  BarcodeModel({
    this.id,
    this.name,
    this.product_id,
    this.barcode_text,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'product_id': product_id,
      'barcode_text': barcode_text,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'name': name,
      'product_id': product_id,
      'barcode_text': barcode_text,
    };
  }

  BarcodeModel.fromDb(Map map)
      : id = map["id"],
        name = map["name"],
        product_id = map["product_id"],
        barcode_text = map["barcode_text"];

  factory BarcodeModel.fromJson(Map<String, dynamic> item) {
    return BarcodeModel(
      id: item['barcode_pk'],
      name: item['name'],
      product_id: item['product_id'],
      barcode_text: item['barcode_text'],
    );
  }
}
