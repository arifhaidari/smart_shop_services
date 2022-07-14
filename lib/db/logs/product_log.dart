class ProductLog {
  int id;
  String name;
  double purchase;
  double price;
  String barcode;
  bool enable_product;
  int quantity;
  double weight;
  int all_log_id;
  bool has_variant;

  ProductLog({
    this.id,
    this.name,
    this.purchase,
    this.price,
    this.barcode,
    this.enable_product,
    this.quantity,
    this.weight,
    this.all_log_id,
    this.has_variant,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'purchase': purchase,
      'price': price,
      'barcode': barcode,
      'enable_product': enable_product,
      'quantity': quantity,
      'weight': weight,
      'all_log_id': all_log_id,
      'has_variant': has_variant,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'name': name,
      'purchase': purchase,
      'price': price,
      'barcode': barcode,
      'enable_product': enable_product,
      'quantity': quantity,
      'weight': weight,
      'all_log_id': all_log_id,
      'has_variant': has_variant,
    };
  }

  ProductLog.fromDb(Map map)
      : id = map["id"],
        name = map["name"],
        purchase = map["purchase"],
        price = map["price"],
        barcode = map["barcode"],
        enable_product = map["enable_product"] == 1 ? true : false,
        quantity = map["quantity"],
        weight = map["weight"],
        all_log_id = map["all_log_id"],
        has_variant = map["has_variant"] == 1 ? true : false;

  factory ProductLog.fromJson(Map<String, dynamic> item) {
    return ProductLog(
      id: item['product_log_pk'],
      name: item['name'],
      purchase: item['purchase'],
      price: item['price'],
      barcode: item['barcode'],
      enable_product: item['enable_product'],
      quantity: item['quantity'],
      weight: item['weight'],
      all_log_id: item['all_log_id'],
      has_variant: item['has_variant'],
    );
  }
}
