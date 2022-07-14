class InvoiceModel {
  int id;
  double invoice_subtotal;
  double invoice_discount;
  double invoice_paid_amount;
  double invoice_payable_amount; //correct the spelling
  int invoice_item_no;
  String customer_name;
  String customer_address;
  String customer_phone;
  String customer_email;
  String qr_code_string;
  String invoice_number;
  String invoice_issue_date;
  String invoice_due_date;
  bool invoice_paid_status;
  int cart_id;
  int session_id;
  int order_id;

  InvoiceModel({
    this.id,
    this.invoice_subtotal,
    this.invoice_discount,
    this.invoice_paid_amount,
    this.invoice_payable_amount,
    this.invoice_item_no,
    this.customer_name,
    this.customer_address,
    this.customer_phone,
    this.customer_email,
    this.qr_code_string,
    this.invoice_number,
    this.invoice_issue_date,
    this.invoice_due_date,
    this.invoice_paid_status,
    this.cart_id,
    this.session_id,
    this.order_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'invoice_subtotal': invoice_subtotal,
      'invoice_discount': invoice_discount,
      'invoice_paid_amount': invoice_paid_amount,
      'invoice_payable_amount': invoice_payable_amount,
      'invoice_item_no': invoice_item_no,
      'customer_name': customer_name,
      'customer_address': customer_address,
      'customer_phone': customer_phone,
      'customer_email': customer_email,
      'qr_code_string': qr_code_string,
      'invoice_number': invoice_number,
      'invoice_issue_date': invoice_issue_date,
      'invoice_due_date': invoice_due_date,
      'invoice_paid_status': invoice_paid_status,
      'cart_id': cart_id,
      'session_id': session_id,
      'order_id': order_id,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'invoice_subtotal': invoice_subtotal,
      'invoice_discount': invoice_discount,
      'invoice_paid_amount': invoice_paid_amount,
      'invoice_payable_amount': invoice_payable_amount,
      'invoice_item_no': invoice_item_no,
      'customer_name': customer_name,
      'customer_address': customer_address,
      'customer_phone': customer_phone,
      'customer_email': customer_email,
      'qr_code_string': qr_code_string,
      'invoice_number': invoice_number,
      'invoice_issue_date': invoice_issue_date,
      'invoice_due_date': invoice_due_date,
      'invoice_paid_status': invoice_paid_status,
      'cart_id': cart_id,
      'session_id': session_id,
      'order_id': order_id,
    };
  }

  InvoiceModel.fromDb(Map map)
      : id = map["id"],
        invoice_subtotal = map["invoice_subtotal"],
        invoice_discount = map["invoice_discount"],
        invoice_paid_amount = map["invoice_paid_amount"],
        invoice_payable_amount = map["invoice_payable_amount"],
        invoice_item_no = map["invoice_item_no"],
        customer_name = map["customer_name"],
        customer_address = map["customer_address"],
        customer_phone = map["customer_phone"],
        customer_email = map["customer_email"],
        qr_code_string = map["qr_code_string"],
        invoice_number = map["invoice_number"],
        invoice_issue_date = map["invoice_issue_date"],
        invoice_due_date = map["invoice_due_date"],
        invoice_paid_status = map["invoice_paid_status"] == 1 ? true : false,
        cart_id = map["cart_id"],
        session_id = map["session_id"],
        order_id = map["order_id"];

  factory InvoiceModel.fromJson(Map<String, dynamic> item) {
    return InvoiceModel(
      id: item['invoice_pk'],
      invoice_subtotal: item['invoice_subtotal'],
      invoice_discount: item['invoice_discount'],
      invoice_paid_amount: item['invoice_paid_amount'],
      invoice_payable_amount: item['invoice_payable_amount'],
      invoice_item_no: item['invoice_item_no'],
      customer_name: item['customer_name'],
      customer_address: item['customer_address'],
      customer_phone: item['customer_phone'],
      customer_email: item['customer_email'],
      qr_code_string: item['qr_code_string'],
      invoice_number: item['invoice_number'],
      invoice_issue_date: item['invoice_issue_date'].toString(),
      invoice_due_date: item['invoice_due_date'].toString(),
      invoice_paid_status: item['invoice_paid_status'],
      cart_id: item['cart_id'],
      session_id: item['session_id'],
      order_id: item['order_id'],
    );
  }
}
