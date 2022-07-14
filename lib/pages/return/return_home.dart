import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:pos/db/db_helper.dart';
import 'package:pos/db/order_model.dart';
import 'package:intl/intl.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/return/return_detail.dart';

import 'package:month_picker_dialog/month_picker_dialog.dart';

class ReturnHome extends StatefulWidget {
  @override
  _ReturnHomeState createState() => _ReturnHomeState();
}

class _ReturnHomeState extends State<ReturnHome> {
  final PosDatabase dbmanager = new PosDatabase();
  List<OrderModel> allOrderList = List();

  int currentIndex = 0;
  String _dateMonthObject;
  String _dateYearObject;

  @override
  void initState() {
    super.initState();
    _dateMonthObject = DateTime.now().toString().substring(0, 7);
    _dateYearObject = DateTime.now().toString().substring(0, 4);
  }

  Widget _widgetAction() {
    if (currentIndex == 0) {
      return Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.date_range, color: Colors.white),
              onPressed: () {
                showMonthPicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2019),
                        lastDate: DateTime(2030))
                    .then((date) {
                  setState(() {
                    if (date == null) {
                      // do nothing
                    } else {
                      _dateMonthObject = date.toString().substring(0, 7);
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
              icon: Icon(Icons.date_range, color: Colors.white),
              onPressed: () {
                showDatePicker(
                        initialDatePickerMode: DatePickerMode.year,
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2019),
                        lastDate: DateTime(2030))
                    .then((date) {
                  setState(() {
                    if (date == null) {
                      // do nothing
                    } else {
                      _dateYearObject = date.toString().substring(0, 4);
                    }
                  });
                });
              }),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  text: getTranslated(context, "return_month"),
                  icon: Icon(FontAwesomeIcons.businessTime),
                ),
                Tab(
                    text: getTranslated(context, "return_year"),
                    icon: Icon(FontAwesomeIcons.calendarAlt)),
              ],
            ),
            title: Text(getTranslated(context, "return")),
          ),
          body: TabBarView(
            children: [
              Padding(
                padding: EdgeInsets.all(3),
                child: Container(
                  color: Colors.grey[150],
                  child: Column(
                    children: <Widget>[
                      Expanded(
                          child: FutureBuilder(
                        future: dbmanager.getReturnListByMonth(_dateMonthObject, "month"),
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
                                              builder: (context) => ReturnDetail(
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
                                                      "${getTranslated(context, "return")}-# ${ol.id}",
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
                          return Container(child: Center(child: new CircularProgressIndicator()));
                        },
                      )),
                    ],
                  ),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.all(3.0),
              //   child: OrderTab(),
              // ),
              Padding(
                padding: EdgeInsets.all(3.0),
                child: Container(
                  color: Colors.grey[150],
                  child: Column(
                    children: <Widget>[
                      Expanded(
                          child: FutureBuilder(
                        future: dbmanager.getReturnListByMonth(_dateYearObject, "year"),
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
                                              builder: (context) => ReturnDetail(
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
                                                      "${getTranslated(context, "return")}-# ${ol.id}",
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
                          return Container(child: Center(child: new CircularProgressIndicator()));
                        },
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
