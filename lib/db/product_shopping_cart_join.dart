class ProductShoppingCartJoin {
  int main_product_id;
  String name;
  double purchase;
  double price;
  String picture;
  int quantity;
  bool has_variant;
  int shopping_cart_product_id; // this is the shoppingCartProduct unique table id
  int shopping_cart_product_quantity;
  double shopping_cart_product_subtotal;
  double shopping_cart_product_discount;
  int shopping_cart_product_main_product_id;
  bool shopping_cart_has_variant_option;

  //product.id, product.name, product.price, product.picture, product.quantity, product.has_variant, shoppingCartProduct.id, shoppingCartProduct.product_quantity, shoppingCartProduct.product_subtotal, shoppingCartProduct.has_variant_option

  ProductShoppingCartJoin({
    this.main_product_id,
    this.name,
    this.purchase,
    this.price,
    this.picture,
    this.quantity,
    this.has_variant,
    this.shopping_cart_product_id,
    this.shopping_cart_product_quantity,
    this.shopping_cart_product_subtotal,
    this.shopping_cart_product_discount,
    this.shopping_cart_product_main_product_id,
    this.shopping_cart_has_variant_option,
  });

  Map<String, dynamic> toMap() {
    return {
      'main_product_id': main_product_id,
      'name': name,
      'purchase': purchase,
      'price': price,
      'picture': picture,
      'quantity': quantity,
      'has_variant': has_variant,
      'shopping_cart_product_id': shopping_cart_product_id,
      'product_quantity': shopping_cart_product_quantity,
      'product_subtotal': shopping_cart_product_subtotal,
      'product_discount': shopping_cart_product_discount,
      'product_id': shopping_cart_product_main_product_id,
      'has_variant_option': shopping_cart_has_variant_option,
    };
  }

  ProductShoppingCartJoin.fromDb(Map map)
      : main_product_id = map["main_product_id"],
        name = map["name"],
        purchase = map["purchase"],
        price = map["price"],
        picture = map["picture"],
        quantity = map["quantity"],
        has_variant = map["has_variant"] == 1 ? true : false,
        shopping_cart_product_id = map["shopping_cart_product_id"],
        shopping_cart_product_quantity = map["product_quantity"],
        shopping_cart_product_subtotal = map["product_subtotal"],
        shopping_cart_product_discount = map["product_discount"],
        shopping_cart_product_main_product_id = map["product_id"],
        shopping_cart_has_variant_option = map["has_variant_option"] == 1 ? true : false;
}
