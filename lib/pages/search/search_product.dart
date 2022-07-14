import 'package:flutter/material.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/product_model.dart';
import 'package:pos/db/shopping_cart_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/product/Utility.dart';
import 'package:pos/pages/product/edit_product.dart';

class SearchProduct extends SearchDelegate {
  // final List<Product> searchProductList;

  final searchProductList;

  SearchProduct({this.searchProductList});

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

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(milliseconds: 50));

    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    mySearchList = searchProductList;
    final suggestionList = query.isEmpty
        ? searchProductList
        : mySearchList.where((item) => item.name.toLowerCase().contains(query)).toList();

    return RefreshIndicator(
      key: refreshKey,
      onRefresh: refreshList,
      child: Column(
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
                        elevation: 5,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProduct(
                                          productObject: suggestionList[index],
                                          productList: suggestionList,
                                          updateIndex: index,
                                        ))).then((value) => refreshList);
                          },
                          leading: _productAvatar(suggestionList[index].picture),
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
                                        "${suggestionList[index].name}",
                                        style: TextStyle(
                                            color: suggestionList[index].enable_product
                                                ? Colors.blue[900]
                                                : Colors.grey,
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
                                        "${suggestionList[index].quantity} - ${getTranslated(context, "analytics_in_stock")}",
                                        style: TextStyle(
                                            color: suggestionList[index].enable_product
                                                ? Colors.black
                                                : Colors.grey,
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
                                            color: suggestionList[index].enable_product
                                                ? Colors.red
                                                : Colors.grey,
                                            fontSize: 15.0),
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
      ),
    );
  }
}
