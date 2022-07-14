class ShoppingCartProductModel {
  int id;
  int product_quantity;
  double product_subtotal; //discount is already didcute it from product
  double product_discount;
  double product_purchase_price_total;
  bool has_variant_option;
  int product_id; //FK
  int shopping_cart_id; //FK

  ///Looks like we need another table as well for ShoppingProductOption to store the options with it's price
  /// but in here we need one more column and that is has_variant = true/false

  ShoppingCartProductModel({
    this.id,
    this.product_quantity,
    this.product_subtotal,
    this.product_discount,
    this.product_purchase_price_total,
    this.has_variant_option,
    this.product_id, // FK
    this.shopping_cart_id, //FK
  });

  Map<String, dynamic> toMap() {
    return {
      'product_quantity': product_quantity,
      'product_subtotal': product_subtotal,
      'product_discount': product_discount,
      'product_purchase_price_total': product_purchase_price_total,
      'has_variant_option': has_variant_option,
      'product_id': product_id,
      'shopping_cart_id': shopping_cart_id,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'product_quantity': product_quantity,
      'product_subtotal': product_subtotal,
      'product_discount': product_discount,
      'product_purchase_price_total': product_purchase_price_total,
      'has_variant_option': has_variant_option,
      'product_id': product_id,
      'shopping_cart_id': shopping_cart_id,
    };
  }

  ShoppingCartProductModel.fromDb(Map map)
      : id = map["id"],
        product_quantity = map["product_quantity"],
        product_subtotal = map["product_subtotal"],
        product_discount = map["product_discount"],
        product_purchase_price_total = map["product_purchase_price_total"],
        has_variant_option = map["is_chhas_variant_optionecked"] == 1 ? true : false,
        product_id = map["product_id"],
        shopping_cart_id = map["shopping_cart_id"];

  factory ShoppingCartProductModel.fromJson(Map<String, dynamic> item) {
    return ShoppingCartProductModel(
      id: item['shopping_cart_product_pk'],
      product_quantity: item['product_quantity'],
      product_subtotal: item['product_subtotal'],
      product_discount: item['product_discount'],
      product_purchase_price_total: item['product_purchase_price_total'],
      has_variant_option: item['has_variant_option'],
      product_id: item['product_id'],
      shopping_cart_id: item['shopping_cart_id'],
    );
  }
}
