class ProductShoppingCartInvoicing {
  String name;
  String alias;
  double price;
  bool has_variant;
  int shopping_cart_product_quantity;
  double shopping_cart_product_subtotal;
  double shopping_cart_product_discount;
  bool shopping_cart_has_variant_option;

  //product.id, product.name, product.price, product.picture, product.quantity, product.has_variant, shoppingCartProduct.id, shoppingCartProduct.product_quantity, shoppingCartProduct.product_subtotal, shoppingCartProduct.has_variant_option

  ProductShoppingCartInvoicing({
    this.name,
    this.alias,
    this.price,
    this.has_variant,
    this.shopping_cart_product_quantity,
    this.shopping_cart_product_subtotal,
    this.shopping_cart_product_discount,
    this.shopping_cart_has_variant_option,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'alias': alias,
      'price': price,
      'has_variant': has_variant,
      'product_quantity': shopping_cart_product_quantity,
      'product_subtotal': shopping_cart_product_subtotal,
      'product_discount': shopping_cart_product_discount,
      'has_variant_option': shopping_cart_has_variant_option,
    };
  }

  ProductShoppingCartInvoicing.fromDb(Map map)
      : name = map["name"],
        alias = map["alias"],
        price = map["price"],
        has_variant = map["has_variant"] == 1 ? true : false,
        shopping_cart_product_quantity = map["product_quantity"],
        shopping_cart_product_subtotal = map["product_subtotal"],
        shopping_cart_product_discount = map["product_discount"],
        shopping_cart_has_variant_option = map["has_variant_option"] == 1 ? true : false;
}
