class ProductVariantPriceJoinModel {
  int id;
  double price; //option price
  int option_id;
  int variant_id;
  int product_id;
  String option_name;

  ProductVariantPriceJoinModel({
    this.id,
    this.price,
    this.option_id,
    this.variant_id,
    this.product_id,
    this.option_name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'price': price,
      'option_id': option_id,
      'variant_id': variant_id,
      'product_id': product_id,
      'option_name': option_name,
    };
  }

  ProductVariantPriceJoinModel.fromDb(Map map)
      : id = map["id"],
        price = map["price"],
        option_id = map["option_id"],
        variant_id = map["variant_id"],
        product_id = map["product_id"],
        option_name = map["option_name"];
}
