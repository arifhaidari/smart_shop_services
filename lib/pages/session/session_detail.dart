import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/db/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/db/session_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/session/session_detail_list.dart';

class SessionDetail extends StatefulWidget {
  final sessionObject;

  SessionDetail({this.sessionObject});
  @override
  _SessionDetailState createState() => _SessionDetailState();
}

class _SessionDetailState extends State<SessionDetail> {
  final PosDatabase dbmanager = new PosDatabase();

  SessionModel sessionModelObject;
  double sessionDailyExpense = 0.0;
  List<OrderModel> singleSessionOrderList = List();
  double sessionOrderSubtotal = 0.0; // closing balance
  double sessionOrderPurchaseTotal = 0.0;
  double sessionOrderDiscount = 0.0;
  double sessionClosingBalance = 0.0;
  int sessionOrderNo = 0;

  final LogAcitvity logActivity = new LogAcitvity();
  bool backup = false;

  @override
  void initState() {
    setState(() {
      sessionModelObject = widget.sessionObject;
    });
    super.initState();
    getSessinData();
    logActivity.logActivation().then((value) {
      if (value != null) {
        backup = value.backup_activation;
      }
    });
  }

  void getSessinData() async {
    await dbmanager.getSessionDailyExpense(sessionModelObject.id, "daily").then((dailyExpense) {
      setState(() {
        if (dailyExpense != null) {
          sessionDailyExpense = dailyExpense;
        }
      });
    });

    await dbmanager.getSingleSessionOrderList(sessionModelObject.id).then((product) {
      setState(() {
        if (product.length > 0) {
          sessionOrderNo = product.length;
        }
      });
    });

    await dbmanager.getSessionOrderSubtotal(sessionModelObject.id).then((orderSubtotalSum) {
      setState(() {
        if (orderSubtotalSum != null) {
          sessionOrderSubtotal = orderSubtotalSum;
          sessionClosingBalance = sessionOrderSubtotal - sessionDailyExpense;
        }
      });
    });

    await dbmanager.getSessionOrderPurchaseTotal(sessionModelObject.id).then((orderPurchaseSum) {
      setState(() {
        if (orderPurchaseSum != null) {
          sessionOrderPurchaseTotal = orderPurchaseSum;
        }
      });
    });

    await dbmanager.getSessionOrderDiscount(sessionModelObject.id).then((orderDiscountSum) {
      setState(() {
        if (orderDiscountSum != null) {
          sessionOrderDiscount = orderDiscountSum;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "session_detail")),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.insert_comment),
            onPressed: () {
              int leftDueDay = 0;
              var now = DateTime.parse(DateTime.now().toString().substring(0, 10));
              var due = DateTime.parse(sessionModelObject.opening_time.substring(0, 10));
              setState(() {
                leftDueDay = now.difference(due).inDays;
              });
              if (leftDueDay < 8) {
                sessionComment(context);
              } else {
                _showToastMessage(getTranslated(context, 'session_comment_not_allowed'));
              }
            },
          )
        ],
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
              expandedHeight: 235.0,
              flexibleSpace: FlexibleSpaceBar(
                background: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        color: Colors.blue[900],
                        height: 135.0,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "${getTranslated(context, "session_id")} - #${sessionModelObject.id}",
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
                                          "${getTranslated(context, "more_net_revenue")}: $sessionOrderSubtotal",
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
                                          "${getTranslated(context, "notification_daily_order")}: $sessionOrderNo",
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
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        height: 103.0,
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
                                          getTranslated(context, "notification_opening_balance"),
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
                                          "${sessionModelObject.opening_balance}",
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
                                          DateFormat('y/M/d -').add_jm().format(DateTime.parse(
                                              sessionModelObject.opening_time.toString())),
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
                                          getTranslated(context, "session_closing_balance"),
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
                                          sessionClosingBalance.toString(),
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
                                          sessionModelObject.close_status
                                              ? DateFormat('y/M/d -').add_jm().format(
                                                  DateTime.parse(
                                                      sessionModelObject.closing_time.toString()))
                                              : getTranslated(context, "session_unknown"),
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
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Container(
                    margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                    child: Card(
                      elevation: 5.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            getTranslated(context,
                                'session_comment_title'), // if it was empty or null then say write some comment (optional)
                            style: TextStyle(
                                color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.bold),
                          ),
                          contentPadding: EdgeInsets.all(5.0),
                          subtitle: Text(
                            sessionModelObject.session_comment == null
                                ? getTranslated(context, 'session_comment_placeholder')
                                : sessionModelObject.session_comment,
                            style: TextStyle(
                                color: Colors.blue[900], fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SessionDetailList(
                    sessionId: sessionModelObject.id,
                  ),
                  // myCardDetails(
                  //     "images/bitcoin.png", "Bitcoin", data1, "4702", "3.0", "\u2191", 0xff07862b),
                ],
              ),
            ),
          ],
        ),
      ),

      ///the list starts from here
    );
  }

  Future<void> sessionComment(BuildContext context) async {
    double width = MediaQuery.of(context).size.width;
    var _commentController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    if (sessionModelObject.session_comment != null) {
      _commentController.text = sessionModelObject.session_comment;
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated(context, 'session_report_title')),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: getTranslated(context, 'session_write_comment'),
                ),
                controller: _commentController,
                // maxLength: 10,
                validator: (String value) {
                  if (value.isEmpty) {
                    return getTranslated(context, 'session_write_something');
                  }
                  return null;
                },
              ),
            ),
            actions: <Widget>[
              Container(
                width: width * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: MaterialButton(
                        color: Colors.blue[800],
                        elevation: 3,
                        child: Text(
                          getTranslated(context, "back"),
                          style: TextStyle(
                              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          _commentController.clear();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: MaterialButton(
                        color: Colors.blue[800],
                        elevation: 3,
                        child: Text(
                          getTranslated(context, "submit"),
                          style: TextStyle(
                              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            saveSessionComment(sessionModelObject, _commentController.text);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }

  void saveSessionComment(SessionModel sessionModel, String comment) async {
    sessionModel.session_comment = comment;
    await dbmanager.updateSession(sessionModel).then((value) {
      getSessinData();
      Navigator.of(context).pop();
    });
    if (backup) {
      logActivity.recordBackupHistory("Session", sessionModel.id, 'Edit');
    }
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
