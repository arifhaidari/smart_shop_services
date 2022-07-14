import 'package:flutter/material.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/product_model.dart';
import 'package:pos/db/product_variant_option.dart';
import 'package:pos/db/product_variant_price_list.dart';
import 'package:pos/db/selected_product_variant.dart';
import 'package:pos/db/shopping_cart_model.dart';
import 'package:pos/db/shopping_product_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/db/variant_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/home_page.dart';
import 'package:pos/pages/home/placeholder.dart';

class SearchAddCart extends StatefulWidget {
  final productObject;
  final addType;

  SearchAddCart({this.productObject, this.addType});
  @override
  _SearchAddCartState createState() => _SearchAddCartState();
}

class _SearchAddCartState extends State<SearchAddCart> {
  final PosDatabase dbmanager = new PosDatabase();

  ShoppingCartModel shoppingCartObject;

  int cartItemNo;
  int cartSubtotal;

  @override
  void initState() {
    super.initState();
    if (widget.addType == "single") {
      _createShoppingCart(widget.productObject);
    } else {
      _createShoppingCartVariant(widget.productObject);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[150],
      body: Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void _createShoppingCart(Product productObject) async {
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
      product_purchase_price_total: pObject.purchase,
      product_discount: 0,
      has_variant_option: false,
      product_id: pObject.id,
      shopping_cart_id: shoppingCartId,
    );
    dbmanager.insertShoppingCartProduct(scp).then((id) => {});
    shoppingCartObject = null;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  categoryId: "all_categories",
                  sentIndex: 0,
                )));
  }

  void _editShoppingCartProduct(
      ShoppingCartProductModel shoppingCartProductObject, Product pObject) {
    if (pObject.quantity > shoppingCartProductObject.product_quantity) {
      shoppingCartProductObject.product_quantity += 1;
      shoppingCartProductObject.product_subtotal += pObject.price;
      shoppingCartProductObject.product_purchase_price_total += pObject.purchase;

      dbmanager.updateShoppingCartProduct(shoppingCartProductObject).then((id) => {});
      shoppingCartObject = null;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    categoryId: "all_categories",
                    sentIndex: 0,
                  )));
    } else {
      shoppingCartObject = null;
      _showToastMessage("${pObject.name} ${getTranslated(context, "product_stock_out_inline")}");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    categoryId: "all_categories",
                    sentIndex: 0,
                  )));
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

      if (productObject.quantity > sumValueTemp) {
        if (shoppingCartProductModelObject == null) {
          _openVariantChoiceDialogueSave(productObject, shoppingCartObject.id);
        } else {
          _openVariantChoiceDialogueSave(productObject, shoppingCartObject.id);
        }
      } else {
        shoppingCartObject = null;
        _showToastMessage(
            "${productObject.name} ${getTranslated(context, "product_stock_out_inline")}");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      categoryId: "all_categories",
                      sentIndex: 0,
                    )));
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
            // backgroundColor: Colors.deepOrange,
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

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                categoryId: "all_categories",
                                sentIndex: 0,
                              )));
                  // Navigator.of(context).pop();

                  //we can pass arguments through pop() constructor
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
              selectedItemMap.clear(),
              variantListById = [],
              productVOListById = [],
              variantListId = [],
              shoppingCartProductModelObject = null,
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(
                            categoryId: "all_categories",
                            sentIndex: 0,
                          ))),
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
    selectedItemMap.clear();
    variantListById = [];
    productVOListById = [];
    variantListId = [];
    shoppingCartProductModelObject = null;

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  categoryId: "all_categories",
                  sentIndex: 0,
                )));
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
