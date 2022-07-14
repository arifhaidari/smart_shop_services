class SelectedProductVariantModel {
  int id;
  String option_name;
  double price;
  int product_variant_option_id;
  int option_id;
  int variant_id;
  int product_id;
  int shopping_cart_id;
  int shopping_cart_product_id; //this need to be added to table column of this table
  /// if we have a product with variant then we have different set of collection
  /// like for a product with one variant with two option we need to store that particular
  /// product twice and if we need from both optionsn and if this get increased
  /// in numbers of variant and options then it will get more complex

  SelectedProductVariantModel({
    this.id,
    this.option_name,
    this.price,
    this.product_variant_option_id,
    this.option_id,
    this.variant_id,
    this.product_id,
    this.shopping_cart_id,
    this.shopping_cart_product_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'option_name': option_name,
      'price': price,
      'product_variant_option_id': product_variant_option_id,
      'option_id': option_id,
      'variant_id': variant_id,
      'product_id': product_id,
      'shopping_cart_id': shopping_cart_id,
      'shopping_cart_product_id': shopping_cart_product_id,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'option_name': option_name,
      'price': price,
      'product_variant_option_id': product_variant_option_id,
      'option_id': option_id,
      'variant_id': variant_id,
      'product_id': product_id,
      'shopping_cart_id': shopping_cart_id,
      'shopping_cart_product_id': shopping_cart_product_id,
    };
  }

  SelectedProductVariantModel.fromDb(Map map)
      : id = map["id"],
        option_name = map["option_name"],
        price = map["price"],
        product_variant_option_id = map["product_variant_option_id"],
        option_id = map["option_id"],
        variant_id = map["variant_id"],
        product_id = map["product_id"],
        shopping_cart_product_id = map["shopping_cart_product_id"],
        shopping_cart_id = map["shopping_cart_id"];

  factory SelectedProductVariantModel.fromJson(Map<String, dynamic> item) {
    return SelectedProductVariantModel(
      id: item['selected_product_variant_pk'],
      option_name: item['option_name'],
      price: item['price'],
      product_variant_option_id: item['product_variant_option_id'],
      option_id: item['option_id'],
      variant_id: item['variant_id'],
      product_id: item['product_id'],
      shopping_cart_product_id: item['shopping_cart_product_id'],
      shopping_cart_id: item['shopping_cart_id'],
    );
  }
}
