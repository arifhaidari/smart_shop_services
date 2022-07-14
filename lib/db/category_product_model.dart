class CategoryProductJoin {
  int id;
  int category_id;
  int product_id;

  CategoryProductJoin({
    this.id,
    this.category_id,
    this.product_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'category_id': category_id,
      'product_id': product_id,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'category_id': category_id,
      'product_id': product_id,
    };
  }

  CategoryProductJoin.fromDb(Map map)
      : id = map["id"],
        category_id = map["category_id"],
        product_id = map["product_id"];

  factory CategoryProductJoin.fromJson(Map<String, dynamic> item) {
    return CategoryProductJoin(
      id: item['category_product_pk'],
      category_id: item['category_id'],
      product_id: item['product_id'],
    );
  }
}
