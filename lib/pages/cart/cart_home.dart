import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/db/authentication_model.dart';

//My Imports
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/user_model.dart';
import 'package:pos/django_rest_api/api_response.dart';
import 'package:pos/django_rest_api/authentication_service.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/cart/cart_checkout.dart';
import 'package:pos/pages/cart/cash_collection.dart';
import 'package:pos/pages/home/home_page.dart';

class CartHome extends StatefulWidget {
  final cartId;

  CartHome({this.cartId});
  @override
  _CartHomeState createState() => _CartHomeState();
}

class _CartHomeState extends State<CartHome> {
  final PosDatabase dbmanager = new PosDatabase();
  bool returnOrder = false;

  @override
  void initState() {
    getUserCredential();
    super.initState();
    getShoppingCartInfo();

    checkExpiryDateLocally();
  }

  void getShoppingCartInfo() async {
    await dbmanager.getShoppingCartById(widget.cartId).then((value) {
      if (value != null) {
        returnOrder = value.return_order;
      }
    });
  }

  String username;

  void getUserCredential() async {
    await dbmanager.getSingleUser().then((onValue) {
      if (onValue != null) {
        setState(() {
          username = onValue.phone;
        });
      } else {
        // do nothing
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "cart")),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                dbmanager.deleteShoppingCart(widget.cartId).then((_) {
                  // Navigator.of(context).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                categoryId: "all_categories",
                                sentIndex: 0,
                              )));
                });
              }),
          if (!returnOrder)
            IconButton(
                icon: Icon(Icons.pause_circle_filled, color: Colors.white),
                onPressed: () {
                  if (username == "expired351focus") {
                    _showToastMessage(getTranslated(context, "cart_expiration_message"));
                  } else {
                    putOnHold();
                  }
                })
        ],
      ),

      //=========== Items of Cards =============
      body: CartCheckout(
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
            onPressed: () {
              if (username == "expired351focus") {
                _showToastMessage(getTranslated(context, "cart_expiration_message"));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CashCollection(
                              cartId: widget.cartId,
                              operationType: "order",
                            )));
              }
            },
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  returnOrder
                      ? getTranslated(context, "cart_checkout_return")
                      : getTranslated(context, "cart_checkout"),
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

  bool isLoading = false;

  final AuthenticationService userService = new AuthenticationService();
  APIResponse<UserAuthentication> _apiAuthResponse;

  void checkExpiryDate() async {
    setState(() {
      isLoading = true;
    });

    _apiAuthResponse = await userService.userLogin();

    if (_apiAuthResponse.data == null) {
    } else {
      setState(() {
        isLoading = false;
      });
      if (int.parse(_apiAuthResponse.data.status) == 200) {
        // do nothing
      } else {
        if (_apiAuthResponse.data.token == "Your Contract Is Expired") {
          UserModel userModel;
          await dbmanager.getSingleUser().then((onValue) async {
            if (onValue != null) {
              setState(() {
                userModel = onValue;
                userModel.phone = "expired351focus";
                userModel.password = "expired351focus";
              });
              await dbmanager.updateUser(userModel).then((onValue) {});
            }
          });
        }
      }
    }
  }

  void checkExpiryDateLocally() async {
    UserModel userModel;
    await dbmanager.getSingleUser().then((onValue) async {
      if (onValue != null) {
        final end_contract = DateTime.parse(onValue.end_contract_at);
        final now_date = DateTime.parse(DateTime.now().toString().substring(0, 10));

        if (end_contract.difference(now_date).inDays < 7 && onValue.access_code != 'trial') {
          _showToastMessage(
              "${getTranslated(context, 'cart_remaining_day')} ${end_contract.difference(now_date).inDays}");
        }

        if (now_date.isAfter(end_contract)) {
          setState(() {
            userModel = onValue;
            userModel.phone = "expired351focus";
            userModel.password = "expired351focus";
          });
          await dbmanager.updateUser(userModel).then((onValue) {});
        } else {
          checkExpiryDate();
        }
      }
    });
  }

  void putOnHold() async {
    double subtotalTemp;
    double discountTemp;
    int cartItemQuantityTemp;

    await dbmanager.getShoppingCartGrandTotal(widget.cartId).then((allProductSubtotal) => {
          setState(() {
            if (allProductSubtotal == null) {
              subtotalTemp = 0;
            } else {
              subtotalTemp = allProductSubtotal;
            }
          }),
        });

    await dbmanager.getShoppingCartItemNo(widget.cartId).then((quantityNum) => {
          setState(() {
            if (quantityNum == null) {
              cartItemQuantityTemp = 0;
            } else {
              cartItemQuantityTemp = quantityNum;
            }
          }),
        });

    await dbmanager.getShoppingCartTotalDiscount(widget.cartId).then((allDiscounts) => {
          setState(() {
            if (allDiscounts == null) {
              discountTemp = 0;
            } else {
              discountTemp = allDiscounts;
            }
          }),
        });

    await dbmanager.getShoppingCartById(widget.cartId).then((cartByidExist) {
      cartByidExist.subtotal = subtotalTemp;
      cartByidExist.total_discount = discountTemp;
      cartByidExist.cart_item_quantity = cartItemQuantityTemp;
      cartByidExist.on_hold = true;
      dbmanager.updateShoppingCart(cartByidExist).then((id) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      categoryId: "all_categories",
                      sentIndex: 0,
                    )));
      });
      //the by cartByidExist object update the shopping cart and put on_hold = true
    });
  }

  void _showToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
