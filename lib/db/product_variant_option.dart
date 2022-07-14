class ProductVariantOption {
  int id;
  int product_id;
  int variant_id;
  int option_id;
  double price;

  ProductVariantOption({
    this.id,
    this.product_id,
    this.variant_id,
    this.option_id,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'product_id': product_id,
      'variant_id': variant_id,
      'option_id': option_id,
      'price': price,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'product_id': product_id,
      'variant_id': variant_id,
      'option_id': option_id,
      'price': price,
    };
  }

  ProductVariantOption.fromDb(Map map)
      : id = map["id"],
        product_id = map["product_id"],
        variant_id = map["variant_id"],
        option_id = map["option_id"],
        price = map["price"];

  factory ProductVariantOption.fromJson(Map<String, dynamic> item) {
    return ProductVariantOption(
      id: item['product_variant_option_pk'],
      product_id: item['product_id'],
      variant_id: item['variant_id'],
      option_id: item['option_id'],
      price: item['price'],
    );
  }
}
