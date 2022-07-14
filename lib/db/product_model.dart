class Product {
  int id;
  String name;
  String alias;
  double purchase;
  double price;
  String picture;
  String barcode;
  bool enable_product;
  int quantity;
  double weight;
  bool has_variant;

  Product({
    this.id,
    this.name,
    this.alias,
    this.purchase,
    this.price,
    this.picture,
    this.barcode,
    this.enable_product,
    this.quantity,
    this.weight,
    this.has_variant,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'alias': alias,
      'purchase': purchase,
      'price': price,
      'picture': picture,
      'barcode': barcode,
      'enable_product': enable_product,
      'quantity': quantity,
      'weight': weight,
      'has_variant': has_variant,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'name': name,
      'alias': alias,
      'purchase': purchase,
      'price': price,
      'picture': picture,
      'barcode': barcode,
      'enable_product': enable_product,
      'quantity': quantity,
      'weight': weight,
      'has_variant': has_variant,
    };
  }

  Product.fromDb(Map map)
      : id = map["id"],
        name = map["name"],
        alias = map["alias"],
        purchase = map["purchase"],
        price = map["price"],
        picture = map["picture"],
        barcode = map["barcode"],
        enable_product = map["enable_product"] == 1 ? true : false,
        quantity = map["quantity"],
        weight = map["weight"],
        has_variant = map["has_variant"] == 1 ? true : false;

  factory Product.fromJson(Map<String, dynamic> item) {
    return Product(
      id: item['product_pk'],
      name: item['name'],
      alias: item['alias'],
      purchase: item['purchase'],
      price: item['price'],
      picture: item['picture'],
      barcode: item['barcode'],
      enable_product: item['enable_product'],
      quantity: item['quantity'],
      weight: item['weight'],
      has_variant: item['has_variant'],
    );
  }
}
