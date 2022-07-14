class ShoppingCartModel {
  int id;
  double subtotal;
  double cart_purchase_price_total;
  double total_discount;
  int cart_item_quantity;
  String timestamp;
  bool checked_out;
  bool on_hold;
  bool return_order;

  ShoppingCartModel({
    this.id,
    this.subtotal,
    this.cart_purchase_price_total,
    this.total_discount,
    this.cart_item_quantity, //change from grand_total to cart_item_quantity
    this.timestamp,
    this.checked_out,
    this.on_hold,
    this.return_order,
  });

  Map<String, dynamic> toMap() {
    return {
      'subtotal': subtotal,
      'cart_purchase_price_total': cart_purchase_price_total,
      'total_discount': total_discount,
      'cart_item_quantity': cart_item_quantity,
      'timestamp': timestamp,
      'checked_out': checked_out,
      'on_hold': on_hold,
      'return_order': return_order,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'subtotal': subtotal,
      'cart_purchase_price_total': cart_purchase_price_total,
      'total_discount': total_discount,
      'cart_item_quantity': cart_item_quantity,
      'timestamp': timestamp,
      'checked_out': checked_out,
      'on_hold': on_hold,
      'return_order': return_order,
    };
  }

  ShoppingCartModel.fromDb(Map map)
      : id = map["id"],
        subtotal = map["subtotal"],
        cart_purchase_price_total = map["cart_purchase_price_total"],
        total_discount = map["total_discount"],
        cart_item_quantity = map["cart_item_quantity"],
        timestamp = map["timestamp"],
        checked_out = map["checked_out"] == 1 ? true : false,
        on_hold = map["on_hold"] == 1 ? true : false,
        return_order = map["return_order"] == 1 ? true : false;

  factory ShoppingCartModel.fromJson(Map<String, dynamic> item) {
    return ShoppingCartModel(
      id: item['shopping_cart_pk'],
      subtotal: item['subtotal'],
      cart_purchase_price_total: item['cart_purchase_price_total'],
      total_discount: item['total_discount'],
      cart_item_quantity: item['cart_item_quantity'],
      timestamp: item['timestamp'].toString(),
      checked_out: item['checked_out'],
      on_hold: item['on_hold'],
      return_order: item['return_order'],
    );
  }
}
