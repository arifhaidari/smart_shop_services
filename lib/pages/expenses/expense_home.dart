import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/components/mixins.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/expense_model.dart';
import 'package:pos/db/session_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/home_page.dart';
import 'package:pos/pages/home/placeholder.dart';

class ExpenseHome extends StatefulWidget {
  @override
  _ExpenseHomeState createState() => _ExpenseHomeState();
}

class _ExpenseHomeState extends State<ExpenseHome> {
  ///////////

  final _expenseController = TextEditingController();
  final _reasonController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  ExpenseModel expenseModelObject;
  final PosDatabase dbmanager = new PosDatabase();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var refreshKeyMonthly = GlobalKey<RefreshIndicatorState>();

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(microseconds: 50));

    return null;
  }

  Future<Null> refreshListMonthly() async {
    refreshKeyMonthly.currentState?.show(atTop: false);
    await Future.delayed(Duration(microseconds: 50));

    return null;
  }

  List<ExpenseModel> expenseList = List();
  List<ExpenseModel> expenseMonthlyList = List();

  int currentSessionId;
  int updateIndex;
  double dailyExpenseTotal = 0;
  double monthlyExpenseTotal = 0;

  String _timeDailyObject;
  String _timeAnnualObject;
  String todayDatetime = DateTime.now().toString();
  final LogAcitvity logActivity = new LogAcitvity();
  bool backup = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      todayDatetime = DateTime.now().toString();
      _timeDailyObject = DateTime.now().toString().substring(0, 10);
      _timeAnnualObject = DateTime.now().toString().substring(0, 4);
    });
    _checkSessionStatus();
    _getTotalDailyExpenses();
    _getTotalMonthlyExpenses();
    logActivity.logActivation().then((value) {
      if (value != null) {
        backup = value.backup_activation;
      }
    });
  }

  void _checkSessionStatus() async {
    await dbmanager.getCurrentSession().then((sessionExist) {
      if (sessionExist == null) {
        _createNewSessionDialogue(context);
      } else {
        _checkSessionDate(context, sessionExist);
      }
    });
  }

  _checkSessionDate(BuildContext context, SessionModel sessionModelObject) async {
    String nowTimeObject = DateTime.now().toString();

    //nowTimeObject
    int yearNowTime = int.parse(nowTimeObject.substring(0, 4));
    int monthNowTime = int.parse(nowTimeObject.substring(5, 7));
    int dayNowTime = int.parse(nowTimeObject.substring(8, 10));

    //nowTimeObject
    int yearSessionTime = int.parse(sessionModelObject.opening_time.substring(0, 4));
    int monthSessionTime = int.parse(sessionModelObject.opening_time.substring(5, 7));
    int daySessionTime = int.parse(sessionModelObject.opening_time.substring(8, 10));

    if (sessionModelObject.opening_time.substring(0, 10) == nowTimeObject.substring(0, 10)) {
      currentSessionId = sessionModelObject.id;
    } else {
      if (sessionModelObject.opening_time.substring(0, 7) == nowTimeObject.substring(0, 7) &&
          dayNowTime > daySessionTime) {
        sessionEnder(sessionModelObject);
      } else if (yearSessionTime == yearNowTime && monthNowTime > monthSessionTime) {
        sessionEnder(sessionModelObject);
      } else if (yearNowTime > yearSessionTime) {
        sessionEnder(sessionModelObject);
      } else {
        _sessionErrorDialogue(context);
      }
    }
  }

  Future<void> _sessionErrorDialogue(BuildContext context) async {
    // double width = MediaQuery.of(context).size.width;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, "cart_session_time_error"),
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Text(
              getTranslated(context, "cart_session_time_content"),
              style: TextStyle(color: Colors.green[900], fontSize: 14, fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "okay"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                categoryId: "all_categories",
                                sentIndex: 0,
                              )));
                },
              ),
            ],
          );
        });
  }

  Future<void> _createNewSessionDialogue(BuildContext context) async {
    final _openingAmountController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, "cart_existing_cash"),
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: getTranslated(context, "cart_enter_amount"),
                ),
                keyboardType: TextInputType.number,
                controller: _openingAmountController,
                // maxLength: 10,
                validator: (String value) {
                  if (value.isEmpty) {
                    return getTranslated(context, "cart_enter_amount");
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
                  //Navigate to home page
                  _openingAmountController.clear();
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
                    _createNewSessionObject(context, double.parse(_openingAmountController.text));
                  }
                },
              ),
            ],
          );
        });
  }

  void _createNewSessionObject(BuildContext context, double amount) async {
    SessionModel s = new SessionModel(
      opening_balance: amount,
      opening_time: DateTime.now().toString(),
      closing_time: null,
      session_comment: null,
      close_status: false,
      drawer_status: false,
    );
    dbmanager.createSession(s).then((id) => {
          currentSessionId = id,
          Navigator.of(context).pop(),
        });
  }

  int currentIndex = 0;

  Widget _widgetAction() {
    if (currentIndex == 0) {
      //daily expense
      return Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.date_range, color: Colors.white),
              onPressed: () {
                showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2019),
                        lastDate: DateTime(2030))
                    .then((date) {
                  setState(() {
                    if (date != null) {
                      _timeDailyObject = date.toString().substring(0, 10);
                      _getTotalDailyExpenses();
                    }
                  });
                });
              }),
        ],
      );
    } else {
      // monthly expense
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
                    if (date != null) {
                      _timeAnnualObject = date.toString().substring(0, 4);
                      _getTotalMonthlyExpenses();
                    }
                  });
                });
              }),
        ],
      );
    }
  }

  void _submitExpenses(BuildContext ctx) {
    double width1 = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      decoration:
                          InputDecoration(labelText: getTranslated(context, "expense_reason")),
                      controller: _reasonController,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return getTranslated(context, "expense_reason_required");
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      decoration:
                          InputDecoration(labelText: getTranslated(context, "expense_amount")),
                      keyboardType: TextInputType.number,
                      controller: _expenseController,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return getTranslated(context, "expense_amount_required");
                        }
                        return null;
                      },
                    ),
                  ),
                  Divider(),
                  Container(
                    width: width1 * 0.7,
                    height: 50.0,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.blue, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(10.0)),
                      color: Colors.blue[900],
                      splashColor: Colors.pink[700],
                      onPressed: () {
                        _submitExpenseButton();
                        // _getTotalExpenses();
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                          ),
                          Expanded(
                              child: Text(
                            getTranslated(context, "submit"),
                            style: TextStyle(color: Colors.white, fontSize: 20.0),
                            textAlign: TextAlign.center,
                          )),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitExpenseButton() async {
    //2020-09-24
    if (_formKey.currentState.validate()) {
      if (currentIndex == 0) {
        if (expenseModelObject == null) {
          ExpenseModel st = new ExpenseModel(
            expense_type: "daily",
            reason: _reasonController.text,
            amount: double.parse(_expenseController.text),
            timestamp: DateTime.now().toString(),
            session_id: currentSessionId,
          );
          await dbmanager.insertExpense(st).then((id) => {
                _reasonController.clear(),
                _expenseController.clear(),
              });
        } //storing new daily expense
        else {
          expenseModelObject.reason = _reasonController.text;
          expenseModelObject.amount = double.parse(_expenseController.text);
          if (backup) {
            logActivity.recordBackupHistory("Expense", expenseModelObject.id, 'Edit');
          }

          dbmanager.updateExpense(expenseModelObject).then((id) => {
                setState(() {
                  expenseList[updateIndex].reason = _reasonController.text;
                  expenseList[updateIndex].amount = double.parse(_expenseController.text);
                }),
                _reasonController.clear(),
                _expenseController.clear(),
                expenseModelObject = null
              });
        } // end of editing daily expense record
        _getTotalDailyExpenses();
      } // end of daily page
      else {
        if (expenseModelObject == null) {
          ExpenseModel st = new ExpenseModel(
            expense_type: "monthly",
            reason: _reasonController.text,
            amount: double.parse(_expenseController.text),
            // timestamp: "2020-08-25 03:36:25.148538",
            timestamp: DateTime.now().toString(),
            session_id: currentSessionId,
          );
          await dbmanager.insertExpense(st).then((id) => {
                _reasonController.clear(),
                _expenseController.clear(),
              });
        } //storing new monthly expense
        else {
          expenseModelObject.reason = _reasonController.text;
          expenseModelObject.amount = double.parse(_expenseController.text);

          if (backup) {
            logActivity.recordBackupHistory("Expense", expenseModelObject.id, 'Edit');
          }

          dbmanager.updateExpense(expenseModelObject).then((id) => {
                setState(() {
                  expenseMonthlyList[updateIndex].reason = _reasonController.text;
                  expenseMonthlyList[updateIndex].amount = double.parse(_expenseController.text);
                }),
                _reasonController.clear(),
                _expenseController.clear(),
                expenseModelObject = null
              });
        } // end of editing monthly expense record
        _getTotalMonthlyExpenses();
      } // End of monthly page
    }

    Navigator.of(context).pop(); // it will close the dialogue box
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
                  text: getTranslated(context, "expense_daily"),
                  icon: Icon(Icons.access_time),
                ),
                Tab(
                    text: getTranslated(context, "expense_monthly"),
                    icon: Icon(FontAwesomeIcons.businessTime)),
              ],
            ),
            title: Text(getTranslated(context, "expense")),
          ),
          body: Padding(
            padding: const EdgeInsets.all(3.0),
            child: TabBarView(
              children: [
                CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      leading: IconButton(
                        icon: Icon(Icons.shop),
                        color: Colors.blue[900],
                        onPressed: () {},
                      ),
                      floating: true,
                      expandedHeight: 70.0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            // color: const Color(0xff7c94b6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue[900],
                              width: 8,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Align(
                            alignment: Alignment.center,
                            child: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.account_balance_wallet,
                                size: 30.0,
                                color: Colors.white,
                              ),
                              label: Text(
                                "$dailyExpenseTotal",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 23.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        <Widget>[
                          RefreshIndicator(
                            key: refreshKey,
                            onRefresh: refreshList,
                            child: FutureBuilder(
                              future: dbmanager.getExpenseList("daily", _timeDailyObject),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  expenseList = snapshot.data;
                                  if (expenseList.length == 0) {
                                    return Container(
                                      child: Center(child: PlaceHolderContent()),
                                    );
                                  }
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    itemCount: expenseList == null ? 0 : expenseList.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      ExpenseModel em = expenseList[index];
                                      return Card(
                                        elevation: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                width: width * 0.6,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      '${em.amount}',
                                                      style: TextStyle(
                                                          fontSize: 17.0,
                                                          color: Colors.blue[900],
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(
                                                      em.reason.toString(),
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: Colors.green[900],
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(DateFormat.yMMMMd()
                                                        .add_jm()
                                                        .format(DateTime.parse(em.timestamp))),
                                                  ],
                                                ),
                                              ),
                                              if (todayDatetime.substring(0, 10) ==
                                                  em.timestamp.substring(0, 10))
                                                IconButton(
                                                  onPressed: () {
                                                    _submitExpenses(context);
                                                    _reasonController.text = em.reason;
                                                    _expenseController.text = em.amount.toString();
                                                    expenseModelObject = em;
                                                    updateIndex = index;
                                                  },
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.blueAccent,
                                                  ),
                                                ),
                                              if (todayDatetime.substring(0, 10) ==
                                                  em.timestamp.substring(0, 10))
                                                IconButton(
                                                  onPressed: () {
                                                    _deleteExpenseDialogue(
                                                        context, em.id, index, "daily");
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red[800],
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                                return Container(
                                    child: Center(child: new CircularProgressIndicator()));
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      leading: IconButton(
                        icon: Icon(Icons.shop),
                        color: Colors.blue[900],
                        onPressed: () {},
                      ),
                      // title: MyAppBar(),
                      // pinned: true,
                      floating: true,
                      expandedHeight: 70.0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            // color: const Color(0xff7c94b6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue[900],
                              width: 8,
                            ),
                          ),
                          // color: Colors.blue[900],
                          alignment: Alignment.center,
                          child: Align(
                            alignment: Alignment.center,
                            child: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.account_balance_wallet,
                                size: 30.0,
                                color: Colors.white,
                              ),
                              label: Text(
                                "$monthlyExpenseTotal",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 23.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        <Widget>[
                          RefreshIndicator(
                            key: refreshKeyMonthly,
                            onRefresh: refreshListMonthly,
                            child: FutureBuilder(
                              future: dbmanager.getExpenseList("monthly", _timeAnnualObject),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  expenseMonthlyList = snapshot.data;
                                  if (expenseMonthlyList.length == 0) {
                                    return Container(
                                      child: Center(child: PlaceHolderContent()),
                                    );
                                  }
                                  return ListView.builder(
                                    // scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    itemCount:
                                        expenseMonthlyList == null ? 0 : expenseMonthlyList.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      ExpenseModel em = expenseMonthlyList[index];
                                      return Card(
                                        elevation: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                width: width * 0.6,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      '${em.amount}',
                                                      style: TextStyle(
                                                          fontSize: 17.0,
                                                          color: Colors.blue[900],
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(
                                                      em.reason.toString(),
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: Colors.green[900],
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(DateFormat.yMMMMd()
                                                        .add_jm()
                                                        .format(DateTime.parse(em.timestamp))),
                                                  ],
                                                ),
                                              ),
                                              if (todayDatetime.substring(0, 7) ==
                                                  em.timestamp.substring(0, 7))
                                                IconButton(
                                                  onPressed: () {
                                                    _submitExpenses(context);
                                                    _reasonController.text = em.reason;
                                                    _expenseController.text = em.amount.toString();
                                                    expenseModelObject = em;
                                                    updateIndex = index;
                                                  },
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.blueAccent,
                                                  ),
                                                ),
                                              if (todayDatetime.substring(0, 7) ==
                                                  em.timestamp.substring(0, 7))
                                                IconButton(
                                                  onPressed: () {
                                                    _deleteExpenseDialogue(
                                                        context, em.id, index, "monthly");
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red[800],
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                                return Container(
                                    child: Center(child: new CircularProgressIndicator()));
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue[800],
            child: Icon(Icons.add),
            onPressed: () => _submitExpenses(context),
          ),
        ),
      ),
    );
  }

  void _getTotalDailyExpenses() async {
    await dbmanager.getExpenseSum("daily", _timeDailyObject).then((dailyExpense) {
      setState(() {
        if (dailyExpense == null || dailyExpense == 0.0) {
          dailyExpenseTotal = 0.0;
        } else {
          dailyExpenseTotal = dailyExpense;
        }
      });
    });
  }

  void _getTotalMonthlyExpenses() async {
    await dbmanager.getExpenseSum("monthly", _timeAnnualObject).then((monthlyExpense) {
      setState(() {
        if (monthlyExpense == null || monthlyExpense == 0.0) {
          monthlyExpenseTotal = 0;
        } else {
          monthlyExpenseTotal = monthlyExpense;
        }
      });
    });
  }

  Future<void> _deleteExpenseDialogue(
      BuildContext context, int epxenseId, int index, String type) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, "expense_delete"),
              style:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Text(
              getTranslated(context, "expense_delete_content"),
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
                  getTranslated(context, "yes"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  if (backup) {
                    logActivity.recordBackupHistory("Expense", epxenseId, 'Delete');
                  }
                  await dbmanager.deleteExpense(epxenseId);
                  setState(() {
                    type == 'daily'
                        ? expenseList.removeAt(index)
                        : expenseMonthlyList.removeAt(index);
                  });
                  type == 'daily' ? _getTotalDailyExpenses() : _getTotalMonthlyExpenses();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
