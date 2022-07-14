class VariantProductJoin {
  int id;
  int variant_id;
  int product_id;

  VariantProductJoin({
    this.id,
    this.variant_id,
    this.product_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'variant_id': variant_id,
      'product_id': product_id,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'variant_id': variant_id,
      'product_id': product_id,
    };
  }

  VariantProductJoin.fromDb(Map map)
      : id = map["id"],
        variant_id = map["variant_id"],
        product_id = map["product_id"];

  factory VariantProductJoin.fromJson(Map<String, dynamic> item) {
    return VariantProductJoin(
      id: item['variant_product_pk'],
      variant_id: item['variant_id'],
      product_id: item['product_id'],
    );
  }
}
