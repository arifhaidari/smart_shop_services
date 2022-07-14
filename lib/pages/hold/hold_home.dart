import 'package:flutter/material.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/shopping_cart_model.dart';
import 'package:intl/intl.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/hold/hold_detail.dart';
import 'package:pos/pages/home/drawer.dart';
import 'package:pos/pages/home/placeholder.dart';

//My Imports

class HoldHome extends StatefulWidget {
  @override
  _HoldHomeState createState() => _HoldHomeState();
}

class _HoldHomeState extends State<HoldHome> {
  final PosDatabase dbmanager = new PosDatabase();
  List<ShoppingCartModel> shoppingCartOnHoldList = List();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  void getDataList() async {
    await dbmanager.getShoppingCartOnHoldlist().then((value) {
      setState(() {
        shoppingCartOnHoldList = value;
      });
    });
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(milliseconds: 50));

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            backgroundColor: Colors.blue[900],
            title: Text(getTranslated(context, "hold")),
          ),
          drawer: CategoryDrawer(),
          body: RefreshIndicator(
            key: refreshKey,
            onRefresh: refreshList,
            child: Column(
              children: <Widget>[
                Expanded(
                    child: FutureBuilder(
                  future: dbmanager.getShoppingCartOnHoldlist(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      shoppingCartOnHoldList = snapshot.data;
                      if (shoppingCartOnHoldList.length == 0) {
                        return Container(
                          child: Center(child: PlaceHolderContent()),
                        );
                      }
                      return ListView.builder(
                          itemCount:
                              shoppingCartOnHoldList == null ? 0 : shoppingCartOnHoldList.length,
                          itemBuilder: (context, index) {
                            ShoppingCartModel scohl = shoppingCartOnHoldList[index];
                            if (shoppingCartOnHoldList.length != 0) {
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Card(
                                  elevation: 5,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(5.0),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HoldDetail(
                                            cartId: scohl.id,
                                          ),
                                        ),
                                      ).then((value) => getDataList());
                                    },
                                    subtitle: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(3.0),
                                                child: Text(
                                                  DateFormat('y/M/d -')
                                                      .add_jm()
                                                      .format(DateTime.parse(scohl.timestamp)),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17.0,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(3.0),
                                                child: Text(
                                                  "${getTranslated(context, "cart_quantity")} - ${scohl.cart_item_quantity}",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15.0,
                                                      fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.right,
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
                                                  "${getTranslated(context, "cart_discount")}: ${scohl.total_discount}",
                                                  style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontSize: 15.0,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(3.0),
                                                child: Text(
                                                  "${getTranslated(context, "cart_grand_total")}: ${scohl.subtotal}",
                                                  style: TextStyle(
                                                      color: Colors.blue[900],
                                                      fontSize: 15.0,
                                                      fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.right,
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
          )),
    );
  }
}
