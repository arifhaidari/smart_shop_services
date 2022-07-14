class OrderModel {
  int id;
  double order_subtotal; //net total
  double order_purchase_price_total;
  double order_discount;
  double cash_collected;
  double change_due;
  int order_item_no;
  String timestamp;
  String qr_code_string;
  bool payment_completion_status;
  int cart_id;
  int session_id;

  OrderModel({
    this.id,
    this.order_subtotal,
    this.order_purchase_price_total,
    this.order_discount,
    this.cash_collected,
    this.change_due,
    this.order_item_no,
    this.timestamp,
    this.qr_code_string,
    this.payment_completion_status,
    this.cart_id,
    this.session_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'order_subtotal': order_subtotal,
      'order_purchase_price_total': order_purchase_price_total,
      'order_discount': order_discount,
      'cash_collected': cash_collected,
      'change_due': change_due,
      'order_item_no': order_item_no,
      'timestamp': timestamp,
      'qr_code_string': qr_code_string,
      'payment_completion_status': payment_completion_status,
      'cart_id': cart_id,
      'session_id': session_id,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'order_subtotal': order_subtotal,
      'order_purchase_price_total': order_purchase_price_total,
      'order_discount': order_discount,
      'cash_collected': cash_collected,
      'change_due': change_due,
      'order_item_no': order_item_no,
      'timestamp': timestamp,
      'qr_code_string': qr_code_string,
      'payment_completion_status': payment_completion_status,
      'cart_id': cart_id,
      'session_id': session_id,
    };
  }

  OrderModel.fromDb(Map map)
      : id = map["id"],
        order_subtotal = map["order_subtotal"],
        order_purchase_price_total = map["order_purchase_price_total"],
        order_discount = map["order_discount"],
        cash_collected = map["cash_collected"],
        change_due = map["change_due"],
        order_item_no = map["order_item_no"],
        timestamp = map["timestamp"],
        qr_code_string = map["qr_code_string"],
        payment_completion_status = map["payment_completion_status"] == 1 ? true : false,
        cart_id = map["cart_id"],
        session_id = map["session_id"];

  factory OrderModel.fromJson(Map<String, dynamic> item) {
    return OrderModel(
      id: item['pos_order_pk'],
      order_subtotal: item['order_subtotal'],
      order_purchase_price_total: item['order_purchase_price_total'],
      order_discount: item['order_discount'],
      cash_collected: item['cash_collected'],
      change_due: item['change_due'],
      order_item_no: item['order_item_no'],
      timestamp: item['timestamp'].toString(),
      qr_code_string: item['qr_code_string'],
      payment_completion_status: item['payment_completion_status'],
      cart_id: item['cart_id'],
      session_id: item['session_id'],
    );
  }
}
