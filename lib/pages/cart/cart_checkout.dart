import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//My Imports
import 'package:pos/db/product_shopping_cart_join.dart';
import 'package:pos/db/selected_product_variant.dart';
import 'package:pos/db/shopping_product_model.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/product_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/home_page.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/product/Utility.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartCheckout extends StatefulWidget {
  final cartId;

  CartCheckout({this.cartId});
  @override
  _CartCheckoutState createState() => _CartCheckoutState();
}

class _CartCheckoutState extends State<CartCheckout> {
  final PosDatabase dbmanager = new PosDatabase();
  bool returnOrder = false;

  List<ProductShoppingCartJoin> productShopingCartJoinList = List();

  int cartId;
  int cartItemNo = 0;
  double cartTotalDiscount;
  double cartGrandTotal;

  ProductShoppingCartJoin productShoppingCartJoinObjectDiscount;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    cartId = widget.cartId;
    _updateCartItemNoSubtotal();
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(milliseconds: 50));

    return null;
  }

  void _updateCartItemNoSubtotal() async {
    await dbmanager.getShoppingCartById(widget.cartId).then((value) {
      if (value != null) {
        returnOrder = value.return_order;
      }
    });

    await dbmanager.getShoppingCartItemNo(widget.cartId).then((quantityNum) {
      setState(() {
        if (quantityNum != null) {
          cartItemNo = quantityNum;
          if (quantityNum == 0) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          categoryId: "all_categories",
                          sentIndex: 0,
                        )));
          }
        }
      });
    });

    await dbmanager.getShoppingCartGrandTotal(widget.cartId).then((allProductSubtotal) => {
          setState(() {
            if (allProductSubtotal == null) {
              cartGrandTotal = 0;
            } else {
              cartGrandTotal = allProductSubtotal; //this is the grand total
            }
          }),
        });

    await dbmanager.getShoppingCartTotalDiscount(widget.cartId).then((allDiscounts) => {
          setState(() {
            if (allDiscounts == null) {
              cartTotalDiscount = 0;
            } else {
              cartTotalDiscount = allDiscounts;
            }
          }),
        });
  }

  Widget _productAvatar(String pic) {
    if (pic == "default_text") {
      return CircleAvatar(
        radius: 30.0,
        child: ClipOval(
          child: SizedBox(
            width: 120.0,
            height: 120.0,
            child: Image.asset("images/no_image.jpg"),
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 30.0,
        child: ClipOval(
          child: SizedBox(
            width: 120.0,
            height: 120.0,
            child: Utility.imageFromBase64String(pic),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: CartItems(),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: Column(
          children: <Widget>[
            Expanded(
                child: FutureBuilder(
              future: dbmanager.getProductShoppingCartListById(widget.cartId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  productShopingCartJoinList = snapshot.data;
                  if (productShopingCartJoinList.length == 0) {
                    return Container(
                      child: Center(child: PlaceHolderContent()),
                    );
                  }
                  return ListView.builder(
                      itemCount: productShopingCartJoinList == null
                          ? 0
                          : productShopingCartJoinList.length,
                      itemBuilder: (context, index) {
                        ProductShoppingCartJoin pscj = productShopingCartJoinList[index];
                        if (pscj.has_variant == true) {
                          return Card(
                            child: ListTile(
                              onLongPress:
                                  () {}, // on long hold we delete the item by confirm the dialogue
                              contentPadding: EdgeInsets.all(5.0),
                              leading: _productAvatar(pscj.picture),
                              title: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text(
                                  pscj.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, color: Colors.blue[900]),
                                ),
                              ),
                              subtitle: Column(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      FutureBuilder(
                                        future: dbmanager.getSelectedProductVariantListById(
                                            pscj.shopping_cart_product_id,
                                            pscj.main_product_id,
                                            widget.cartId),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            List<SelectedProductVariantModel> selectedPVMList =
                                                snapshot.data;
                                            return ListView.builder(
                                                shrinkWrap: true,
                                                physics: ClampingScrollPhysics(),
                                                itemCount: selectedPVMList == null
                                                    ? 0
                                                    : selectedPVMList.length,
                                                itemBuilder: (context, index) {
                                                  SelectedProductVariantModel spv =
                                                      selectedPVMList[index];
                                                  return Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 1, color: Colors.blue[900]),
                                                          ),
                                                          child: Text(
                                                            spv.option_name,
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 15.0,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 1, color: Colors.blue[900]),
                                                          ),
                                                          child: Text(
                                                            "${spv.price}",
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 15.0),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "",
                                                          style: TextStyle(
                                                              color: Colors.black, fontSize: 15.0),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          }
                                          return Container(
                                              child:
                                                  Center(child: new CircularProgressIndicator()));
                                        },
                                      ),
                                    ],
                                  ),

                                  /// End of product variant

                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Text(
                                            "${pscj.price}",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          iconSize: 35,
                                          color: Colors.blue[900],
                                          onPressed: () {
                                            _operateShoppingCartProductObjectVariant(pscj, "+");
                                          },
                                          icon: FittedBox(
                                            child: Icon(
                                              FontAwesomeIcons.plusSquare,
                                              color: Colors.blue[900],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: FlatButton(
                                          onPressed: () {
                                            productShoppingCartJoinObjectDiscount = pscj;
                                            _discountDialogue(context);
                                          },
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Colors.blue,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              borderRadius: BorderRadius.circular(15)),
                                          color: Colors.blue[900],
                                          splashColor: Colors.blue,
                                          child: Text(
                                            "${getTranslated(context, "cart_discount")}: ${pscj.shopping_cart_product_discount}",
                                            style: TextStyle(color: Colors.white, fontSize: 13.0),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Text(
                                            "${getTranslated(context, "cart_quantity")} - ${pscj.shopping_cart_product_quantity}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Text(
                                            "${getTranslated(context, "cart_subtotal")}: ${pscj.shopping_cart_product_subtotal}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          iconSize: 35,
                                          color: Colors.blue[900],
                                          onPressed: () async {
                                            if (pscj.shopping_cart_product_quantity == 1) {
                                              await dbmanager
                                                  .deleteShoppingCartProductModel(
                                                      pscj.shopping_cart_product_id)
                                                  .then((onValue) {
                                                _updateCartItemNoSubtotal();
                                                refreshList();
                                                productShopingCartJoinList.removeAt(index);
                                              });
                                            } else {
                                              _operateShoppingCartProductObjectVariant(pscj, "-");
                                            }
                                          },
                                          icon: FittedBox(
                                            child: Icon(
                                              FontAwesomeIcons.minusSquare,
                                              color: Colors.blue[900],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        } // end of variant == true
                        else {
                          return Card(
                            child: ListTile(
                              onLongPress: () {},
                              contentPadding: EdgeInsets.all(5.0),
                              leading: _productAvatar(pscj.picture),
                              title: Text(
                                pscj.name,
                                style:
                                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900]),
                              ),
                              subtitle: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Text(
                                            "${pscj.price}",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Text(
                                            "",
                                            style: TextStyle(color: Colors.black, fontSize: 15.0),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          iconSize: 35,
                                          color: Colors.white,
                                          onPressed: () {
                                            _operateShoppingCartProductObject(pscj, "+");
                                          },
                                          icon: FittedBox(
                                            child: Icon(
                                              FontAwesomeIcons.plusSquare,
                                              color: Colors.blue[900],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: FlatButton(
                                          onPressed: () {
                                            productShoppingCartJoinObjectDiscount = pscj;
                                            _discountDialogue(context);
                                          },
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Colors.blue,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              borderRadius: BorderRadius.circular(15)),
                                          color: Colors.blue[900],
                                          splashColor: Colors.blue,
                                          child: Text(
                                            "${getTranslated(context, "cart_discount")}: ${pscj.shopping_cart_product_discount}",
                                            style: TextStyle(color: Colors.white, fontSize: 13.0),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${getTranslated(context, "cart_quantity")} - ${pscj.shopping_cart_product_quantity}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Text(
                                            "${getTranslated(context, "cart_subtotal")}: ${pscj.shopping_cart_product_subtotal}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Text(
                                            "",
                                            style: TextStyle(color: Colors.black, fontSize: 15.0),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          iconSize: 35,
                                          color: Colors.blue[900],
                                          onPressed: () async {
                                            if (pscj.shopping_cart_product_quantity == 1) {
                                              await dbmanager
                                                  .deleteShoppingCartProductModel(
                                                      pscj.shopping_cart_product_id)
                                                  .then((onValue) {
                                                _updateCartItemNoSubtotal();
                                                refreshList();
                                                productShopingCartJoinList.removeAt(index);
                                              });
                                            } else {
                                              _operateShoppingCartProductObject(pscj, "-");
                                            }
                                          },
                                          icon: FittedBox(
                                            child: Icon(
                                              FontAwesomeIcons.minusSquare,
                                              color: Colors.blue[900],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      });
                }
                return Container(child: Center(child: new CircularProgressIndicator()));
              },
            )),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.grey[200],
        height: 82,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 0.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Text(
                          "${getTranslated(context, "cart_grand_total")}:",
                          style: TextStyle(
                              color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          child: Text(
                            "$cartGrandTotal",
                            style: TextStyle(
                                color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Text(
                          "${getTranslated(context, "cart_discount")}:",
                          style: TextStyle(
                              color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          "$cartTotalDiscount",
                          style: TextStyle(
                              color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _operateShoppingCartProductObject(ProductShoppingCartJoin pscj, String operation) async {
    int productQuantityTemp = 0;
    Product productObjectTemp;
    await dbmanager
        .getProductQuantitySum(pscj.shopping_cart_product_main_product_id, widget.cartId)
        .then((sumValue) {
      if (sumValue == null) {
        productQuantityTemp = 0;
      } else {
        productQuantityTemp = sumValue;
      }
    });

    await dbmanager.getSingleProduct(pscj.shopping_cart_product_main_product_id).then((p) {
      productObjectTemp = p;
    });

    await dbmanager.getShoppingCartProductItem(pscj.main_product_id, widget.cartId).then((item) {
      if (operation == "+") {
        if (returnOrder) {
          _addUpShoppingCartProduct(item, pscj);
        } else {
          if (productObjectTemp.quantity > productQuantityTemp) {
            _addUpShoppingCartProduct(item, pscj);
          } else {
            _showToastMessage("${pscj.name} ${getTranslated(context, "cart_out_of_stock")}");
          }
        }
      } else {
        _decreaseUpShoppingCartProduct(item, pscj);
      }
    });
  }

  void _addUpShoppingCartProduct(ShoppingCartProductModel shoppingCartProductObject,
      ProductShoppingCartJoin productShoppingCartJoin) async {
    shoppingCartProductObject.product_quantity += 1;
    shoppingCartProductObject.product_subtotal += productShoppingCartJoin.price;
    shoppingCartProductObject.product_purchase_price_total += productShoppingCartJoin.purchase;

    await dbmanager.updateShoppingCartProduct(shoppingCartProductObject).then((id) => {});
    _updateCartItemNoSubtotal();
  }

  void _decreaseUpShoppingCartProduct(ShoppingCartProductModel shoppingCartProductObject,
      ProductShoppingCartJoin productShoppingCartJoin) async {
    shoppingCartProductObject.product_quantity -= 1;
    shoppingCartProductObject.product_subtotal -= productShoppingCartJoin.price;

    await dbmanager.updateShoppingCartProduct(shoppingCartProductObject).then((id) => {});
    _updateCartItemNoSubtotal();
  }

  ////////////////////// Product with variant ///////////////////////

  void _operateShoppingCartProductObjectVariant(
      ProductShoppingCartJoin pscj, String operation) async {
    int productQuantityTemp = 0;
    Product productObjectTemp;
    await dbmanager
        .getProductQuantitySum(pscj.shopping_cart_product_main_product_id, widget.cartId)
        .then((sumValue) {
      if (sumValue == null) {
        productQuantityTemp = 0;
      } else {
        productQuantityTemp = sumValue;
      }
    });

    await dbmanager.getSingleProduct(pscj.shopping_cart_product_main_product_id).then((p) {
      productObjectTemp = p;
    });

    await dbmanager.getShoppingCartProductById(pscj.shopping_cart_product_id).then((item) {
      if (operation == "+") {
        if (returnOrder) {
          _addUpShoppingCartProductVariant(item, pscj);
        } else {
          if (productObjectTemp.quantity > productQuantityTemp) {
            _addUpShoppingCartProductVariant(item, pscj);
          } else {
            _showToastMessage("${pscj.name} ${getTranslated(context, "cart_out_of_stock")}");
          }
        }
      } else if (operation == "-") {
        _decreaseUpShoppingCartProductVariant(item, pscj);
      } else {
        if (item.product_subtotal < double.parse(operation)) {
          _showToastMessage(getTranslated(context, "cart_greater_subtotal"));

          Navigator.of(context).pop();
        } else {
          _discountOperation(item, double.parse(operation));
        }
      }
    });
  }

  void _addUpShoppingCartProductVariant(ShoppingCartProductModel shoppingCartProductObject,
      ProductShoppingCartJoin productShoppingCartJoin) async {
    double optionTempValue = 0;
    await dbmanager
        .getSelectedProductVariantListById(shoppingCartProductObject.id,
            shoppingCartProductObject.product_id, shoppingCartProductObject.shopping_cart_id)
        .then((scp) {
      scp.forEach((listValue) {
        optionTempValue += listValue.price;
      });
    });

    double totalProductPrice = productShoppingCartJoin.price + optionTempValue;

    shoppingCartProductObject.product_quantity += 1;
    shoppingCartProductObject.product_subtotal += totalProductPrice;
    shoppingCartProductObject.product_purchase_price_total += productShoppingCartJoin.purchase;

    await dbmanager.updateShoppingCartProduct(shoppingCartProductObject).then((id) => {});
    _updateCartItemNoSubtotal();
  }

  void _decreaseUpShoppingCartProductVariant(ShoppingCartProductModel shoppingCartProductObject,
      ProductShoppingCartJoin productShoppingCartJoin) async {
    double optionTempValue = 0;
    await dbmanager
        .getSelectedProductVariantListById(shoppingCartProductObject.id,
            shoppingCartProductObject.product_id, shoppingCartProductObject.shopping_cart_id)
        .then((scp) {
      scp.forEach((listValue) {
        optionTempValue += listValue.price;
      });
    });

    double totalProductPrice = productShoppingCartJoin.price + optionTempValue;

    shoppingCartProductObject.product_quantity -= 1;
    shoppingCartProductObject.product_subtotal -= totalProductPrice;
    shoppingCartProductObject.product_purchase_price_total -= productShoppingCartJoin.purchase;

    await dbmanager.updateShoppingCartProduct(shoppingCartProductObject).then((id) => {});
    _updateCartItemNoSubtotal();
  }

  void _discountOperation(
      ShoppingCartProductModel shoppingCartProductObject, double discountAmount) async {
    double discountTemp = 0;

    discountTemp = shoppingCartProductObject.product_discount;
    shoppingCartProductObject.product_subtotal += discountTemp;
    shoppingCartProductObject.product_subtotal -= discountAmount;
    shoppingCartProductObject.product_discount = discountAmount;

    await dbmanager.updateShoppingCartProduct(shoppingCartProductObject).then((id) => {});

    Navigator.of(context).pop();
    _updateCartItemNoSubtotal();
  }

  Future<void> _discountDialogue(BuildContext context) async {
    final _discountController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, "cart_discount_title"),
              style: TextStyle(color: Colors.blue[900]),
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Form(
              key: _formKey,
              child: TextFormField(
                decoration:
                    InputDecoration(labelText: getTranslated(context, "cart_discount_input")),
                keyboardType: TextInputType.number,
                controller: _discountController,
                // maxLength: 10,
                validator: (String value) {
                  if (value.isEmpty) {
                    return getTranslated(context, "cart_discount_error");
                  }

                  return null;
                },
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "cancel"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _discountController.clear();
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "submit"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _operateShoppingCartProductObjectVariant(
                        productShoppingCartJoinObjectDiscount, _discountController.text);
                  }
                  //we can pass arguments through pop() constructor
                },
              ),
            ],
          );
        });
  } // end of discount dialogue

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
