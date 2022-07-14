import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/drawer.dart';
import 'package:pos/pages/order/invoice_detail.dart';
import 'package:pos/pages/order/invoicing_tab.dart';

import 'package:pos/db/db_helper.dart';
import 'package:pos/db/order_model.dart';
import 'package:intl/intl.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/order/order_detail.dart';
import 'package:flutter/services.dart';

class OrderHome extends StatefulWidget {
  @override
  _OrderHomeState createState() => _OrderHomeState();
}

class _OrderHomeState extends State<OrderHome> {
  final PosDatabase dbmanager = new PosDatabase();
  List<OrderModel> allOrderList = List();
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 1));

    return null;
  }

  int currentIndex = 0;
  String _dateTimeObject;

  @override
  void initState() {
    super.initState();
    _dateTimeObject = DateTime.now().toString().substring(0, 10);
  }

  Widget _widgetAction() {
    if (currentIndex == 0) {
      return Row(
        children: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.qrcode, color: Colors.white),
              onPressed: () {
                _scanOrderQr("order");
              }),
          IconButton(
              icon: Icon(Icons.date_range, color: Colors.white),
              onPressed: () {
                showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2019),
                        lastDate: DateTime(2025))
                    .then((date) {
                  setState(() {
                    if (date != null) {
                      _dateTimeObject = date.toString().substring(0, 10);
                    }
                  });
                });
              }),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.qrcode, color: Colors.white),
              onPressed: () {
                _scanOrderQr("invoice");
              }),
        ],
      );
    }
  }

  String result = "";

  Future _scanOrderQr(String operationType) async {
    try {
      var qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult.rawContent.toString();
      });

      if (operationType == "order") {
        await dbmanager.getSingleOrderByQr(result).then((orderObject) {
          if (orderObject == null) {
            _showFlutterToastMessage(
              getTranslated(context, "invoice_no_order"),
            );
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderDetail(
                          orderObject: orderObject,
                        )));
          }
        });
      } else {
        await dbmanager.getSingleInvoiceByQr(result).then((invoiceObject) {
          if (invoiceObject == null) {
            _showFlutterToastMessage(
              getTranslated(context, "invoice_no_invoice"),
            );
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InvoiceDetail(
                          invoiceObject: invoiceObject,
                        )));
          }
        });
      }
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.cameraAccessDenied) {
        _showFlutterToastMessage(getTranslated(context, "home_camera_denied"));
      } else {
        _showFlutterToastMessage("${getTranslated(context, "home_unknown_error")} $ex");
      }
    } on FormatException {
      _showFlutterToastMessage(getTranslated(context, "home_press_back_button"));
    } catch (ex) {
      _showFlutterToastMessage("${getTranslated(context, "home_unknown_error")} $ex");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Container(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue[900],
              actions: <Widget>[
                _widgetAction(),
              ],
              bottom: TabBar(
                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                // isScrollable: true,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(
                    text: getTranslated(context, "invoice_order"),
                    icon: Icon(FontAwesomeIcons.firstOrder),
                  ),
                  Tab(
                      text: getTranslated(context, "invoice"),
                      icon: Icon(FontAwesomeIcons.fileInvoice)),
                ],
              ),
              title: Text(getTranslated(context, "invoice_sale")),
            ),
            drawer: CategoryDrawer(),
            body: TabBarView(
              children: [
                Padding(
                  padding: EdgeInsets.all(3),
                  child: Container(
                    color: Colors.grey[150],
                    child: RefreshIndicator(
                      key: refreshKey,
                      onRefresh: refreshList,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                              child: FutureBuilder(
                            // future: dbmanager.getOrderList(),
                            future: dbmanager.getOrderListByDay(_dateTimeObject),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                allOrderList = snapshot.data;
                                if (allOrderList.length == 0) {
                                  return Container(
                                    child: Center(child: PlaceHolderContent()),
                                  );
                                }
                                return ListView.builder(
                                    itemCount: allOrderList == null ? 0 : allOrderList.length,
                                    itemBuilder: (context, index) {
                                      OrderModel ol = allOrderList[index];
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
                                                  builder: (context) => OrderDetail(
                                                    orderObject: ol,
                                                  ),
                                                ),
                                              );
                                            },
                                            subtitle: Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(3.0),
                                                        child: Text(
                                                          "${getTranslated(context, "invoice_order_number")}-# ${ol.id}",
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
                                                          "${getTranslated(context, "cart_quantity")} - ${ol.order_item_no}",
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
                                                          DateFormat('y/M/d -')
                                                              .add_jm()
                                                              .format(DateTime.parse(ol.timestamp)),
                                                          style: TextStyle(
                                                              color: Colors.blue[900],
                                                              fontSize: 15.0,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(3.0),
                                                        child: Text(
                                                          "${getTranslated(context, "cart_grand_total")}: ${ol.order_subtotal}",
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
                                    });
                              }
                              return Container(
                                  child: Center(child: new CircularProgressIndicator()));
                            },
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(3.0),
                  child: InvoiceTab(),
                ),
              ],
            ),
          ),
        ),
      ),
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
