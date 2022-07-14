import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/notification/session_daily_list.dart';

class DailyReport extends StatefulWidget {
  final sessionId;

  DailyReport({this.sessionId});
  @override
  _DailyReportState createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  final PosDatabase dbmanager = new PosDatabase();

  int sessionId;
  double openingBalance;
  double closingBalance; // current ballance // done
  int orderNo; // done
  String openingTime;
  double netRevenue; // = closingBalance - sessionDailyExpense
  double sessionDailyExpense;

  @override
  void initState() {
    super.initState();
    _getCurrentSession();
  }

  void _getCurrentSession() async {
    List<OrderModel> singleSessionOrderList = List();
    await dbmanager.getListLast().then((sessionExist) {
      if (sessionExist == null) {
        //show a dailogue box which shows the error
      } else {
        setState(() {
          sessionId = sessionExist.id;
          openingBalance = sessionExist.opening_balance;
          openingTime =
              DateFormat('y/M/d -').add_jm().format(DateTime.parse(sessionExist.opening_time));
        });
      }
    });

    await dbmanager.getSingleSessionOrderList(sessionId).then((onValue) {
      if (onValue.length > 0) {
        setState(() {
          orderNo = onValue.length;
        });
      }
    });

    await dbmanager.getSessionDailyExpense(sessionId, "daily").then((dailyExpense) {
      setState(() {
        sessionDailyExpense = dailyExpense;
      });
    });

    await dbmanager.getSessionOrderSubtotal(sessionId).then((orderSubtotalSum) {
      setState(() {
        if (orderSubtotalSum == null) {
          closingBalance = 0;
        } else {
          closingBalance = orderSubtotalSum;
        }
      });
    });

    setState(() {
      netRevenue = closingBalance - sessionDailyExpense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0.1,
          backgroundColor: Colors.blue[900],
          title: Text(getTranslated(context, "notification_daily")),
        ),
        body: Padding(
          padding: EdgeInsets.all(3.0),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                  color: Colors.blue[900],
                  icon: Icon(Icons.shop),
                  onPressed: () {},
                ),
                floating: true,
                expandedHeight: 230.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            color: Colors.blue[900],
                            height: 130.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${getTranslated(context, "session_id")} - #$sessionId",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            "${getTranslated(context, "more_net_revenue")}: $netRevenue",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            "${getTranslated(context, "more_expense")}: $sessionDailyExpense",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            "${getTranslated(context, "notification_daily_order")}: $orderNo",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            height: 100.0,
                            // height: screenHeight * 0.14,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    color: Colors.blue[900],
                                    padding: const EdgeInsets.all(5.0),
                                    margin: const EdgeInsets.all(3.0),
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                              getTranslated(
                                                  context, "notification_opening_balance"),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                              "$openingBalance",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                              openingTime.toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    color: Colors.blue[900],
                                    padding: const EdgeInsets.all(5.0),
                                    margin: const EdgeInsets.all(3.0),
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                              getTranslated(
                                                  context, "notification_current_balance"),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                              "$closingBalance",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                              getTranslated(context, "session_unknown"),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    SessionDailyDetailList(
                      sessionId: sessionId,
                    ),
                    // myCardDetails(
                    //     "images/bitcoin.png", "Bitcoin", data1, "4702", "3.0", "\u2191", 0xff07862b),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
