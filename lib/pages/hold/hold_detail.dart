import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//My_Imports
import 'package:pos/db/db_helper.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/cart/cash_collection.dart';
import 'package:pos/pages/hold/hold_checkout.dart';

class HoldDetail extends StatefulWidget {
  final cartId;

  HoldDetail({this.cartId});
  @override
  _HoldDetailState createState() => _HoldDetailState();
}

class _HoldDetailState extends State<HoldDetail> {
  final PosDatabase dbmanager = new PosDatabase();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "hold_cart")),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                dbmanager.deleteShoppingCart(widget.cartId).then((_) {
                  Navigator.of(context).pop();
                });
              }),
        ],
      ),

      //=========== Items of Cards =============
      body: HoldCheckout(
        cartId: widget.cartId,
      ),

      bottomNavigationBar: Container(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0, bottom: 15.0),
          child: FlatButton(
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.blue, width: 1, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(20)),
            color: Colors.blue[900],
            splashColor: Colors.pink[700],
            onPressed: () async {
              bool allow = true;
              String name = "";
              String quantity = "";
              String cart_quantity = "";
              await dbmanager.getProductShoppingCartListById(widget.cartId).then((value) {
                value.forEach((element) {
                  if (element.quantity >= element.shopping_cart_product_quantity) {
                  } else {
                    setState(() {
                      allow = false;
                      name = element.name;
                      quantity = element.quantity.toString();
                      cart_quantity = element.shopping_cart_product_quantity.toString();
                    });
                  }
                });
                if (allow) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CashCollection(
                                cartId: widget.cartId,
                                operationType: "hold",
                              )));
                } else {
                  _showToastMessage(
                      '${getTranslated(context, "hold_quantity_low")}: $name \n ${getTranslated(context, "hold_quantity_stock")}: $quantity \n ${getTranslated(context, "hold_quantity_cart")}: $cart_quantity');
                }
              });
            },
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  getTranslated(context, "hold_checkout"),
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                  textAlign: TextAlign.center,
                )),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
