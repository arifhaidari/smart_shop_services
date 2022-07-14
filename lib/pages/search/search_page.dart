import 'package:flutter/material.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/product_model.dart';
import 'package:pos/db/shopping_cart_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/product/Utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/pages/search/search_add_cart.dart';

class DataSearch extends SearchDelegate {
  // final List<Product> searchProductList;

  final searchProductList;

  DataSearch({this.searchProductList});

  List<Product> mySearchList = List();

  final PosDatabase dbmanager = new PosDatabase();

  ShoppingCartModel shoppingCartObject;

  int cartItemNo;
  int cartSubtotal;
  int cartId;

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
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    mySearchList = searchProductList;
    final suggestionList = query.isEmpty
        ? searchProductList
        : mySearchList.where((item) => item.name.toLowerCase().contains(query)).toList();

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
              itemCount: suggestionList.length,
              itemBuilder: (context, index) {
                if (suggestionList.isEmpty) {
                  return PlaceHolderContent();
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          if (suggestionList[index].has_variant == false) {
                            if (suggestionList[index].quantity == 0) {
                              _showFlutterToastMessage(
                                  "${suggestionList[index].name} ${getTranslated(context, "product_stock_out_inline")}");
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchAddCart(
                                            productObject: suggestionList[index],
                                            addType: "single",
                                          )));
                            }
                          } else {
                            if (suggestionList[index].quantity == 0) {
                              _showFlutterToastMessage(
                                  "${suggestionList[index].name} ${getTranslated(context, "product_stock_out_inline")}");
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchAddCart(
                                            productObject: suggestionList[index],
                                            addType: "variant",
                                          )));
                            }
                          }
                        },
                        leading: _productAvatar(suggestionList[index].picture),
                        title: RichText(
                            text: TextSpan(
                                text: suggestionList[index].name.substring(0, query.length),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                                children: [
                              TextSpan(
                                  text: suggestionList[index].name.substring(query.length),
                                  style: TextStyle(color: Colors.blue[600], fontSize: 18.0))
                            ])),
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
                                      "${suggestionList[index].quantity} - ${getTranslated(context, "analytics_in_stock")}",
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
                                      "${suggestionList[index].price}",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.bold),
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
                }
              }),
        ),
      ],
    );
  }

  void _showFlutterToastMessage(String msg) {
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
