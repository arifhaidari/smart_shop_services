import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos/db/notification_model.dart';
import 'package:pos/db/product_variant_option.dart';
import 'package:pos/db/product_variant_price_list.dart';
import 'package:pos/db/selected_product_variant.dart';
import 'package:pos/db/shopping_cart_model.dart';
import 'package:pos/db/shopping_product_model.dart';
import 'package:pos/db/variant_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/cart/cart_home.dart';
import 'package:pos/pages/home/drawer.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/search/search_page.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:pos/main.dart';

//My Imports
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/product_model.dart';
import 'package:pos/pages/product/Utility.dart';

//for notification
import 'dart:async';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

NotificationAppLaunchDetails notificationAppLaunchDetails;

class ProductPage extends StatefulWidget {
  final categoryId;

  ProductPage({this.categoryId = "all_categories"});
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final PosDatabase dbmanager = new PosDatabase();

  ShoppingCartModel shoppingCartObject;

  List<Product> productListSearch = List();

  int cartItemNo;
  double cartSubtotal;
  int cartId;
  bool returnOrder = false;

  @override
  void initState() {
    super.initState();
    getCartData();
    setupList();
  }

  Future<void> _showNotificationStockOut(Product productObject) async {
    NotificationModel noteObject = new NotificationModel(
        subject: "${productObject.name} ${getTranslated(context, "product_stock_out_inline")}",
        timestamp: DateTime.now().toString(),
        detail_id: productObject.id.toString(),
        note_type: "product_out",
        seen_status: false);
    await dbmanager.createNotification(noteObject).then((onValue) {});
    /////////
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'stock_out_id',
      'stock_out_name',
      'stock_out_description',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
      color: Colors.blue[900],
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        getTranslated(context, "product_stock_out"),
        '${productObject.name} ${getTranslated(context, "product_stock_out_note")}',
        platformChannelSpecifics,
        payload: productObject.id.toString());
  }

  Future<void> _showNotificationStockLow(Product productObject) async {
    //save notification
    NotificationModel noteObject = new NotificationModel(
        subject: "${productObject.name} ${getTranslated(context, "product_stock_low_inline")}",
        timestamp: DateTime.now().toString(),
        detail_id: productObject.id.toString(),
        note_type: "product_low",
        seen_status: false);
    await dbmanager.createNotification(noteObject).then((onValue) {});
    //////////
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'low_stock_id',
      'low_stock_name',
      'low_stock_description',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        '${getTranslated(context, "product_stock_low")}',
        '${productObject.name} ${getTranslated(context, "product_stock_low_detail")}',
        platformChannelSpecifics,
        payload: productObject.id.toString());
  }

  /////////// Notification ends /////////////

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

  void getCartData() async {
    await dbmanager.getShoppingCart().then((cartExist) {
      _updateCartItemNoSubtotal(cartExist);
    });
  }

  void _updateCartItemNoSubtotal(ShoppingCartModel cartExist) async {
    if (cartExist == null) {
      ShoppingCartModel sc = new ShoppingCartModel(
        subtotal: 0,
        total_discount: 0,
        cart_item_quantity: 0,
        timestamp: DateTime.now().toString(),
        checked_out: false,
        on_hold: false,
        return_order: false,
      );
      await dbmanager.shoppingCartCartCreator(sc).then((id) => {
            setState(() {
              cartItemNo = 0;
              cartSubtotal = 0;
              cartId = id;
            }),
          });
    } else {
      setState(() {
        cartId = cartExist.id;
      });
      await dbmanager.getShoppingCartItemNo(cartExist.id).then((quantityNum) => {
            setState(() {
              if (quantityNum == null) {
                cartItemNo = 0;
              } else {
                cartItemNo = quantityNum;
              }
            }),
          });

      await dbmanager.getShoppingCartGrandTotal(cartExist.id).then((allProductSubtotal) => {
            setState(() {
              if (allProductSubtotal == null) {
                cartSubtotal = 0;
              } else {
                cartSubtotal = allProductSubtotal.toDouble();
              }
            }),
          });
    }
  }

  void setupList() async {
    await dbmanager.getProductListDisplay().then((product) {
      setState(() {
        product.forEach((p) {
          productListSearch.add(p);
        });
      });
    });
  }

  List<Product> productList = List();

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
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text(getTranslated(context, 'product_home_title')),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  showSearch(
                      context: context, delegate: DataSearch(searchProductList: productListSearch));
                }),
            IconButton(
                icon: Icon(FontAwesomeIcons.barcode, color: Colors.white),
                onPressed: () {
                  _scanQR();
                })
          ],
        ),

        drawer: CategoryDrawer(),

        //=========== Items of Cards =============
        // body: PosItems(),
        body: Column(
          children: <Widget>[
            Expanded(
                child: FutureBuilder(
              future: dbmanager.getProductListById(widget.categoryId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  productList = snapshot.data;
                  if (productList.length == 0) {
                    return Container(
                      child: Center(child: PlaceHolderContent()),
                    );
                  }
                  return ListView.builder(
                      itemCount: productList == null ? 0 : productList.length,
                      itemBuilder: (context, index) {
                        Product p = productList[index];
                        if (productList.length != 0) {
                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Card(
                              elevation: 5,
                              child: ListTile(
                                onTap: () {
                                  distributerFunction(p);
                                },
                                leading: _productAvatar(p.picture),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                              "${p.name}",
                                              style: TextStyle(
                                                  color: Colors.blue[900],
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                              "${p.quantity} - ${getTranslated(context, "analytics_in_stock")}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                              "${p.price}",
                                              style: TextStyle(color: Colors.red, fontSize: 15.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return PlaceHolderContent();
                        }
                      });
                }
                return Container(child: Center(child: new CircularProgressIndicator()));
              },
            )),
          ],
        ),

        bottomNavigationBar: Container(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0, bottom: 12.0),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blue, width: 1, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(15)),
              color: Colors.blue[900],
              splashColor: Colors.pink[700],
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CartHome(
                              cartId: cartId,
                            ))).then((value) => getCartData());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    '${getTranslated(context, 'home_item_no')}: $cartItemNo',
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                    textAlign: TextAlign.left,
                  ),
                  Expanded(
                      child: Text(
                    '${getTranslated(context, "home_subtotal")}: $cartSubtotal',
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                    textAlign: TextAlign.center,
                  )),
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /////////// Distributer function /////////////////

  void distributerFunction(Product p) {
    if (p.quantity <= 5 && p.quantity > 1) {
      _showNotificationStockLow(p);
    }
    if (p.quantity == 1) {
      _showNotificationStockOut(p);
    }
    if (returnOrder) {
      if (p.has_variant == false) {
        _createShoppingCart(p);
      } else {
        _createShoppingCartVariant(p);
      }
    } else {
      if (p.has_variant == false) {
        if (p.quantity == 0) {
          _showNotificationStockOut(p);
          //change the cart
          changeCartToReturn(context, p);
          _showToastMessage("${p.name} ${getTranslated(context, "product_stock_out_inline")}");
        } else {
          _createShoppingCart(p);
        }
      } else {
        if (p.quantity == 0) {
          _showNotificationStockOut(p);
          changeCartToReturn(context, p);
          _showToastMessage("${p.name} ${getTranslated(context, "product_stock_out_inline")}");
        } else {
          _createShoppingCartVariant(p);
        }
      }
    }
  }

  Future<void> changeCartToReturn(BuildContext context, Product pObject) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, 'product_out_of_stock_title'),
              style:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Text(
              getTranslated(context, 'product_out_of_stock_content'),
              style: TextStyle(color: Colors.green[900]),
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
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "okay"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  await dbmanager.getShoppingCartById(cartId).then((valueObject) async {
                    valueObject.return_order = true;
                    await dbmanager.updateShoppingCart(valueObject).then((value) {
                      setState(() {
                        returnOrder = true;
                      });
                      if (pObject.has_variant == false) {
                        _createShoppingCart(pObject);
                      } else {
                        _createShoppingCartVariant(pObject);
                      }
                    });
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  //////////////////// Scanner part /////////////////////////

  String result = "Barcode";

  Future _scanQR() async {
    try {
      var qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult.rawContent.toString();
      });

      await dbmanager.getSingleProductByBarcode(result).then((productData) {
        if (productData == null) {
          _showToastMessage(getTranslated(context, "home_no_product"));
        } else {
          distributerFunction(productData);
        }
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.cameraAccessDenied) {
        _showToastMessage(getTranslated(context, "home_camera_denied"));
      } else {
        _showToastMessage("${getTranslated(context, "home_unknown_error")} $ex");
      }
    } on FormatException {
      _showToastMessage(getTranslated(context, "home_press_back_button"));
    } catch (ex) {
      _showToastMessage("${getTranslated(context, "home_unknown_error")} $ex");
    }
  }

  ////////////////// Product part starts ////////////////////
  //////////////////////////////////////////////////////////

  void _createShoppingCart(Product productObject) async {
    await dbmanager.getShoppingCart().then((cart) {
      setState(() {
        shoppingCartObject = cart;
      });
    });

    if (shoppingCartObject == null) {
      ShoppingCartModel sc = new ShoppingCartModel(
        subtotal: 0,
        cart_purchase_price_total: 0,
        total_discount: 0,
        cart_item_quantity: 0,
        timestamp: DateTime.now().toString(),
        checked_out: false,
        on_hold: false,
        return_order: false,
      );
      await dbmanager.shoppingCartCartCreator(sc).then((id) => {
            _saveShoppingCartProduct(productObject, id),
          });
    } else {
      await dbmanager
          .getShoppingCartProductItem(productObject.id, shoppingCartObject.id)
          .then((item) {
        if (item == null) {
          _saveShoppingCartProduct(productObject, shoppingCartObject.id);
        } else {
          _editShoppingCartProduct(item, productObject);
        }
      });
    }
  }

  void _saveShoppingCartProduct(Product pObject, int shoppingCartId) {
    ShoppingCartProductModel scp = new ShoppingCartProductModel(
      product_quantity: 1,
      product_subtotal: pObject.price,
      product_discount: 0,
      product_purchase_price_total: pObject.purchase,
      has_variant_option: false,
      product_id: pObject.id,
      shopping_cart_id: shoppingCartId,
    );
    dbmanager.insertShoppingCartProduct(scp).then((id) => {});
    shoppingCartObject = null;
    getCartData();
  }

  void _editShoppingCartProduct(
      ShoppingCartProductModel shoppingCartProductObject, Product pObject) {
    if (returnOrder) {
      shoppingCartProductObject.product_quantity += 1;
      shoppingCartProductObject.product_subtotal += pObject.price;
      shoppingCartProductObject.product_purchase_price_total += pObject.purchase;

      dbmanager.updateShoppingCartProduct(shoppingCartProductObject).then((id) => {});
      shoppingCartObject = null;
      getCartData();
    } // the else is the regular way of checkout
    else {
      if (pObject.quantity > shoppingCartProductObject.product_quantity) {
        shoppingCartProductObject.product_quantity += 1;
        shoppingCartProductObject.product_subtotal += pObject.price;
        shoppingCartProductObject.product_purchase_price_total += pObject.purchase;

        dbmanager.updateShoppingCartProduct(shoppingCartProductObject).then((id) => {});
        shoppingCartObject = null;
        getCartData();
      } else {
        shoppingCartObject = null;
        getCartData();
        _showToastMessage("${pObject.name} ${getTranslated(context, "product_stock_out_inline")}");
      }
    }
  }

  ///////////////// Product with Variant part ////////////////////////
  ShoppingCartProductModel shoppingCartProductModelObject;
  void _createShoppingCartVariant(Product productObject) async {
    await dbmanager.getShoppingCart().then((cart) {
      setState(() {
        shoppingCartObject = cart;
      });
    });

    if (shoppingCartObject == null) {
      ShoppingCartModel sc = new ShoppingCartModel(
        subtotal: 0,
        total_discount: 0,
        cart_item_quantity: 0,
        timestamp: DateTime.now().toString(),
        checked_out: false,
        on_hold: false,
        return_order: false,
      );
      await dbmanager.shoppingCartCartCreator(sc).then((id) => {
            _openVariantChoiceDialogueSave(productObject, id),
          });
    } else {
      int sumValueTemp = 0;
      await dbmanager
          .getProductQuantitySum(productObject.id, shoppingCartObject.id)
          .then((sumValue) {
        if (sumValue == null) {
          sumValueTemp = 0;
        } else {
          sumValueTemp = sumValue;
        }
      });
      await dbmanager
          .getShoppingCartProductItem(productObject.id, shoppingCartObject.id)
          .then((item) {
        shoppingCartProductModelObject = item;
      });

      if (returnOrder) {
        if (shoppingCartProductModelObject == null) {
          _openVariantChoiceDialogueSave(productObject, shoppingCartObject.id);
        } else {
          _openVariantChoiceDialogueSave(productObject, shoppingCartObject.id);
        }
      } // the regular checkout of the cart
      else {
        if (productObject.quantity > sumValueTemp) {
          if (shoppingCartProductModelObject == null) {
            _openVariantChoiceDialogueSave(productObject, shoppingCartObject.id);
          } else {
            _openVariantChoiceDialogueSave(productObject, shoppingCartObject.id);
          }
        } else {
          shoppingCartObject = null;
          getCartData();
          _showToastMessage(
              "${productObject.name} ${getTranslated(context, "product_stock_out_inline")}");
        }
      }
    }
  }

  List<int> variantListId = List();
  List<Variant> variantListById = List();
  List<ProductVariantOption> productVOListById = List();
  Map<int, ProductVariantPriceJoinModel> selectedItemMap = Map();
  void _openVariantChoiceDialogueSave(Product pObject, int shoppingCartId) async {
    int temp;

    await dbmanager.getProductVariantOptionListById(pObject.id).then((item) {
      setState(() {
        item.forEach((p) {
          productVOListById.add(p);
        });
      });
    });

    temp = productVOListById[0].variant_id;
    variantListId.add(temp); //in here create the variantListId
    productVOListById.forEach((p) {
      if (temp != p.variant_id) {
        temp = p.variant_id;
        variantListId.add(temp);
      }
    });

    ///////////// variantListById starts ////////////////
    if (variantListId.length == 1) {
      await dbmanager.getVariantListById(variantListId[0]).then((item) async {
        setState(() {
          item.forEach((p) {
            variantListById.add(p);
          });
        });
      });
    } else if (variantListId.length == 2) {
      await dbmanager.getVariantListById(variantListId[0]).then((item) async {
        setState(() {
          item.forEach((p) {
            variantListById.add(p);
          });
        });
      });
      await dbmanager.getVariantListById(variantListId[1]).then((item) async {
        setState(() {
          item.forEach((p) {
            variantListById.add(p);
          });
        });
      });
    } else if (variantListId.length == 3) {
      await dbmanager.getVariantListById(variantListId[0]).then((item) async {
        setState(() {
          item.forEach((p) {
            variantListById.add(p);
          });
        });
      });
      await dbmanager.getVariantListById(variantListId[1]).then((item) async {
        setState(() {
          item.forEach((p) {
            variantListById.add(p);
          });
        });
      });

      await dbmanager.getVariantListById(variantListId[2]).then((item) async {
        setState(() {
          item.forEach((p) {
            variantListById.add(p);
          });
        });
      });
    }
    /////////////// variantListById ends //////////////////////////

    if (variantListId.length == 1) {
      setState(() {
        selectedItemMap[variantListId[0]] = null;
      });
    } else if (variantListId.length == 2) {
      setState(() {
        selectedItemMap[variantListId[0]] = null;
        selectedItemMap[variantListId[1]] = null;
      });
    } else if (variantListId.length == 3) {
      setState(() {
        selectedItemMap[variantListId[0]] = null;
        selectedItemMap[variantListId[1]] = null;
        selectedItemMap[variantListId[2]] = null;
      });
    }

    _showVariantOptionDialog(context, pObject, shoppingCartId);
  }

  Widget _dialogueBody(Product pObject, int shoppingCartId) {
    return Container(
      height: 300,
      width: 350,
      child: ListView.builder(
          itemCount: variantListById == null ? 0 : variantListById.length,
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    variantListById[index].name,
                    style: TextStyle(
                        color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: Colors.blue[900],
                ),
                _dialogueSub(
                  pObject,
                  shoppingCartId,
                  variantListById[index].id,
                ),
              ],
            );
          }),
    );
  }

  Widget _dialogueSub(Product pObject, int shoppingCartId, int variantId) {
    List<ProductVariantPriceJoinModel> productVariantPriceJoin = List();
    var refreshKey = GlobalKey<RefreshIndicatorState>();

    Future<Null> refreshList() async {
      refreshKey.currentState?.show(atTop: false);
      await Future.delayed(Duration(milliseconds: 80));

      return null;
    }

    setSelectedItem(ProductVariantPriceJoinModel productVPJoin) {
      print('set the item');
      setState(() {
        selectedItemMap[productVPJoin.variant_id] = productVPJoin;
      });
      refreshList();
    }

    return RefreshIndicator(
      key: refreshKey,
      onRefresh: refreshList,
      child: FutureBuilder(
        future: dbmanager.getProductVariantPriceListByJoin(variantId, pObject.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            productVariantPriceJoin = snapshot.data;
            if (productVariantPriceJoin.length == 0) {
              return Container(
                child: Center(child: PlaceHolderContent()),
              );
            }

            return ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: productVariantPriceJoin == null ? 0 : productVariantPriceJoin.length,
                itemBuilder: (context, index) {
                  ProductVariantPriceJoinModel vlj = productVariantPriceJoin[index];
                  if (vlj.variant_id == variantListId[0]) {
                    //compare the selectedItem list map
                    return Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: RadioListTile(
                          groupValue: selectedItemMap[variantListId[0]],
                          value: vlj,
                          title: Text(
                            vlj.option_name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          subtitle: Text(
                            "${vlj.price.toString()}",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14.0),
                          ),
                          onChanged: (currentItem) {
                            setSelectedItem(currentItem);
                          },
                          selected: selectedItemMap[variantListId[0]] == vlj,
                          activeColor: Colors.blue[900],
                        ));
                  } else if (vlj.variant_id == variantListId[1]) {
                    return Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: RadioListTile(
                          groupValue: selectedItemMap[variantListId[1]],
                          value: vlj,
                          title: Text(
                            vlj.option_name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          subtitle: Text(
                            "${vlj.price.toString()}",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14.0),
                          ),
                          onChanged: (currentItem) {
                            setSelectedItem(currentItem);
                          },
                          selected: selectedItemMap[variantListId[1]] == vlj,
                          activeColor: Colors.blue[900],
                        ));
                  } else {
                    return Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: RadioListTile(
                          groupValue: selectedItemMap[variantListId[2]],
                          value: vlj,
                          title: Text(
                            vlj.option_name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          subtitle: Text(
                            "${vlj.price.toString()}",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14.0),
                          ),
                          onChanged: (currentItem) {
                            setSelectedItem(currentItem);
                          },
                          selected: selectedItemMap[variantListId[2]] == vlj,
                          activeColor: Colors.blue[900],
                        ));
                  }
                });
          }
          return Container(child: Center(child: new CircularProgressIndicator()));
        },
      ),
    );
  }

  Future<void> _showVariantOptionDialog(
      BuildContext context, Product pObject, int shoppingCartId) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated(context, "home_variant_selection")),
            elevation: 15,
            content: SingleChildScrollView(
              child: _dialogueBody(pObject, shoppingCartId),
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
                  selectedItemMap.clear();
                  variantListById = [];
                  productVOListById = [];
                  variantListId = [];
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "home_add_cart"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (variantListId.length == 1 && selectedItemMap[variantListId[0]] != null) {
                    _saveShoppingCartProductVariant(pObject, shoppingCartId, selectedItemMap);
                    Navigator.of(context).pop();
                  } else if (variantListId.length == 2 &&
                      selectedItemMap[variantListId[0]] != null &&
                      selectedItemMap[variantListId[1]] != null) {
                    _saveShoppingCartProductVariant(pObject, shoppingCartId, selectedItemMap);
                    Navigator.of(context).pop();
                  } else if (variantListId.length == 3 &&
                      selectedItemMap[variantListId[0]] != null &&
                      selectedItemMap[variantListId[1]] != null &&
                      selectedItemMap[variantListId[2]] != null) {
                    _saveShoppingCartProductVariant(pObject, shoppingCartId, selectedItemMap);

                    Navigator.of(context).pop();
                  } else {
                    _showToastMessage(getTranslated(context, "home_option_not_selected"));
                  }
                },
              ),
            ],
          );
        });
  }

  void _saveShoppingCartProductVariant(Product pObject, int shoppingCartId,
      Map<int, ProductVariantPriceJoinModel> selectedMap) async {
    double productPriceStoreUpdated = pObject.price;

    if (variantListId.length == 1) {
      productPriceStoreUpdated = productPriceStoreUpdated + selectedItemMap[variantListId[0]].price;
    } else if (variantListId.length == 2) {
      productPriceStoreUpdated = productPriceStoreUpdated +
          selectedItemMap[variantListId[0]].price +
          selectedItemMap[variantListId[1]].price;
    } else if (variantListId.length == 3) {
      productPriceStoreUpdated = productPriceStoreUpdated +
          selectedItemMap[variantListId[0]].price +
          selectedItemMap[variantListId[1]].price +
          selectedItemMap[variantListId[2]].price;
    }

    if (shoppingCartProductModelObject == null) {
      ShoppingCartProductModel scp = new ShoppingCartProductModel(
        product_quantity: 1,
        product_subtotal: productPriceStoreUpdated,
        product_purchase_price_total: pObject.purchase,
        product_discount: 0,
        has_variant_option: true,
        product_id: pObject.id,
        shopping_cart_id: shoppingCartId,
      );
      await dbmanager.insertShoppingCartProduct(scp).then((id) => {
            _saveSelectedItem(shoppingCartId, pObject.id, id, selectedMap),
          });
    } // end of if product is not save already
    else {
      List<SelectedProductVariantModel> tempSPVList = List();
      for (int key in selectedMap.keys) {
        await dbmanager
            .getSelectedProductVariantListByFiveId(
                shoppingCartId,
                pObject.id,
                shoppingCartProductModelObject.id,
                selectedMap[key].variant_id,
                selectedMap[key].option_id)
            .then((selectedPVM) {
          selectedPVM.forEach((item) {
            tempSPVList.add(item);
          });
          //
        });
      }

      if (selectedMap.length == tempSPVList.length) {
        shoppingCartProductModelObject.product_quantity += 1;
        shoppingCartProductModelObject.product_subtotal += productPriceStoreUpdated;

        dbmanager.updateShoppingCartProduct(shoppingCartProductModelObject).then((id) => {
              shoppingCartObject = null,
              getCartData(),
              selectedItemMap.clear(),
              variantListById = [],
              productVOListById = [],
              variantListId = [],
              shoppingCartProductModelObject = null,
            });
      } //product with same variant option already exist
      else {
        ShoppingCartProductModel scp = new ShoppingCartProductModel(
          product_quantity: 1,
          product_subtotal: productPriceStoreUpdated,
          product_purchase_price_total: pObject.purchase,
          product_discount: 0,
          has_variant_option: true,
          product_id: pObject.id,
          shopping_cart_id: shoppingCartId,
        );
        await dbmanager.insertShoppingCartProduct(scp).then((id) => {
              _saveSelectedItem(shoppingCartId, pObject.id, id, selectedMap),
            });
      }
    } // end of else // shoppingCartProductModelObject is not null
  }

  void _saveSelectedItem(int shoppingCartId, int productId, int shoppingCartProudctId,
      Map<int, ProductVariantPriceJoinModel> selectedMap) {
    for (int key in selectedMap.keys) {
      SelectedProductVariantModel scp = new SelectedProductVariantModel(
          option_name: selectedMap[key].option_name,
          price: selectedMap[key].price,
          product_variant_option_id: null,
          option_id: selectedMap[key].option_id,
          variant_id: selectedMap[key].variant_id,
          product_id: productId,
          shopping_cart_id: shoppingCartId,
          shopping_cart_product_id: shoppingCartProudctId);
      dbmanager.insertSelectedProductVariant(scp).then((id) => {
            //
          });
    }

    shoppingCartObject = null;
    getCartData();
    selectedItemMap.clear();
    variantListById = [];
    productVOListById = [];
    variantListId = [];
    shoppingCartProductModelObject = null;
  }
}
