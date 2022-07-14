import 'package:meta/meta.dart';

class InventoryModel {
  String name;
  int quantity;
  int product_quantity;
  double product_subtotal;
  double product_discount;

  InventoryModel({
    this.name,
    this.quantity,
    this.product_quantity,
    this.product_subtotal,
    this.product_discount,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'product_quantity': product_quantity,
      'product_subtotal': product_subtotal,
      'product_discount': product_discount,
    };
  }

  InventoryModel.fromDb(Map map)
      : name = map["name"],
        quantity = map["quantity"],
        product_quantity = map["product_quantity"],
        product_subtotal = map["product_subtotal"],
        product_discount = map["product_discount"];
}
