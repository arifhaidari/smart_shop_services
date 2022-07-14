import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

//My Imports
import 'package:pos/db/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/drawer.dart';
import 'package:pos/pages/more/more_manage_list.dart';

class MoreHome extends StatefulWidget {
  @override
  _MoreHomeState createState() => _MoreHomeState();
}

class _MoreHomeState extends State<MoreHome> {
  final PosDatabase dbmanager = new PosDatabase();
  int currentIndex = 0;
  String _dateTimeObject;

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    print(_dateTimeObject);
    _getCurrentSessionMethod();
    _yearRevenue(DateTime.now().toString());
    _monthlyDisplay(DateTime.now().toString());
  }

  Widget _widgetAction() {
    if (currentIndex == 1) {
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
                      _dateTimeObject = DateTime.now().toString();
                    } else {
                      _dateTimeObject = date.toString();
                    }
                    _monthlyDisplay(_dateTimeObject);
                  });
                });
              }),
        ],
      );
    } else {
      return Row(
        children: <Widget>[],
      );
    }
  }

  /// For session net_revenue
  static double january = 0.0;
  static double february = 0.0;
  static double march = 0.0;
  static double april = 0.0;
  static double may = 0.0;
  static double june = 0.0;
  static double july = 0.0;
  static double august = 0.0;
  static double september = 0.0;
  static double october = 0.0;
  static double november = 0.0;
  static double december = 0.0;

  String year;
  double annualRevenue = 0;

  List<double> graphData = List();

  void _yearRevenue(String timeStamp) async {
    graphData = [];
    year = timeStamp.substring(0, 4);

    ///find yearly revenue
    await dbmanager.getAnnualRevenue(year).then((dailyExpense) {
      setState(() {
        annualRevenue = double.parse(dailyExpense.toString());
      });
    });

    ///////////// January net revenue
    await dbmanager.getSessionMonthlyRevenue(year, "01").then((dailyExpense) {
      setState(() {
        graphData.add(dailyExpense);
      });
    });

    ///////////// February net revenue
    await dbmanager.getSessionMonthlyRevenue(year, "02").then((dailyExpense) {
      setState(() {
        graphData.add(dailyExpense);
      });
    });

    ///////////// March net revenue
    await dbmanager.getSessionMonthlyRevenue(year, "03").then((dailyExpense) {
      setState(() {
        graphData.add(dailyExpense);
      });
    });

    ///////////// April net revenue
    await dbmanager.getSessionMonthlyRevenue(year, "04").then((dailyExpense) {
      setState(() {
        graphData.add(dailyExpense);
      });
    });

    ///////////// May net revenue
    await dbmanager.getSessionMonthlyRevenue(year, "05").then((dailyExpense) {
      setState(() {
        graphData.add(dailyExpense);
      });
    });

    ///////////// June net revenue
    await dbmanager.getSessionMonthlyRevenue(year, "06").then((dailyExpense) {
      setState(() {
        graphData.add(dailyExpense);
      });
    });

    ///////////// July net revenue
    await dbmanager.getSessionMonthlyRevenue(year, "07").then((dailyExpense) {
      setState(() {
        graphData.add(dailyExpense);
      });
    });

    ///////////// August net revenue
    await dbmanager.getSessionMonthlyRevenue(year, "08").then((dailyExpense) {
      setState(() {
        graphData.add(dailyExpense);
      });
    });

    ///////////// September net revenue
    await dbmanager.getSessionMonthlyRevenue(year, "09").then((dailyExpense) {
      setState(() {
        graphData.add(dailyExpense);
      });
    });

    ///////////// Ocotober net revenue
    await dbmanager.getSessionMonthlyRevenue(year, "10").then((dailyExpense) {
      setState(() {
        graphData.add(dailyExpense);
      });
    });

    ///////////// November net revenue
    await dbmanager.getSessionMonthlyRevenue(year, "11").then((dailyExpense) {
      setState(() {
        graphData.add(dailyExpense);
      });
    });

    ///////////// December net revenue
    await dbmanager.getSessionMonthlyRevenue(year, "12").then((dailyExpense) {
      setState(() {
        graphData.add(dailyExpense + 0.000000001);
      });
    });
  }

  int currentSessionId;
  void _getCurrentSessionMethod() async {
    await dbmanager.getCurrentSession().then((sessionExist) {
      if (sessionExist != null) {
        setState(() {
          currentSessionId = sessionExist.id;
        });
      } else {
        setState(() {
          currentSessionId = 1;
        });
      }
    });
    _dailyExpenseDisplay();
  }

  double dailyExpenseTotal = 0.0;
  void _dailyExpenseDisplay() async {
    String timeTemp1 = DateTime.now().toString().substring(0, 10);
    await dbmanager.getExpenseSum('daily', timeTemp1).then((dailyExpense) {
      setState(() {
        if (dailyExpense == null) {
          dailyExpenseTotal = 0.0;
        } else {
          dailyExpenseTotal = dailyExpense;
        }
      });
    });
  }

  double monthlyExpenseTotal = 0;
  int productNo = 0;
  int categoriesNO = 0;
  double monthlyRevenue = 0.0;
  int monthlySession = 0;
  int monthlyOrder = 0;
  int monthlyReturn = 0;
  int holdNo = 0;
  int invoiceNo = 0;
  int noteNo = 0;
  String monthName;
  void _monthlyDisplay(String timeStamp) async {
    String month = timeStamp.substring(5, 7); //2020-09-12
    String yearMonth = timeStamp.substring(0, 7); //2020-09-12

    monthName = DateFormat.MMM().format(DateTime.parse(timeStamp));
    // monthName = month;

    ///Get monthly epxenses
    await dbmanager.getMonthlyExpense(month).then((monthlyExpense) {
      setState(() {
        if (monthlyExpense == null) {
          monthlyExpenseTotal = 0;
        } else {
          monthlyExpenseTotal = monthlyExpense;
        }
      });
    });

    ///Get Number of products
    await dbmanager.getProductsNo().then((productItems) {
      setState(() {
        if (productItems == null) {
          productNo = 0;
        } else {
          productNo = productItems;
        }
      });
    });

    ///Get Number of notes
    await dbmanager.getNoteNo().then((noteItems) {
      print('value of noteItems');
      print(noteItems);
      setState(() {
        if (noteItems == null) {
          noteNo = 0;
        } else {
          noteNo = noteItems;
        }
      });
    });

    ///Get Number of categories
    await dbmanager.getCategoriesNo().then((categoryItems) {
      setState(() {
        if (categoryItems == null) {
          categoriesNO = 0;
        } else {
          categoriesNO = categoryItems;
        }
        print(categoriesNO);
      });
    });

    ///getMonthlyRevenue
    await dbmanager.getMonthlyRevenue(yearMonth).then((data) {
      setState(() {
        monthlyRevenue = double.parse(data.toString());
      });
    });

    ///getMonthlySessionNo
    await dbmanager.getMonthlySessionNo(yearMonth).then((data) {
      setState(() {
        if (data == null) {
          monthlySession = 0;
        } else {
          monthlySession = data;
        }
      });
    });

    ///getMonthlyOrderNo
    await dbmanager.getMonthlyOrderNo(yearMonth).then((data) {
      setState(() {
        if (data == null) {
          monthlyOrder = 0;
        } else {
          monthlyOrder = data;
        }
      });
    });

    ///getMonthlyReturnNo
    await dbmanager.getMonthlyReturnNo(yearMonth).then((data) {
      setState(() {
        if (data == null) {
          monthlyReturn = 0;
        } else {
          monthlyReturn = data;
        }
      });
    });

    ///getHoldNo
    await dbmanager.getHoldNo().then((data) {
      setState(() {
        if (data == null) {
          holdNo = 0;
        } else {
          holdNo = data;
        }
      });
    });

    ///getInvoiceNo
    await dbmanager.getInvoiceNo().then((data) {
      setState(() {
        if (data == null) {
          invoiceNo = 0;
        } else {
          invoiceNo = data;
        }
      });
    });
  }

  // var graphData1 = [1.0, 33.0, 40.0, 55.0, 66.0, 44.0, 17.0, 34.0, 46.0, 55.0, 26.0, 78.0];
  Material myGraphChart(String revenueHeading, double revenueDigit) {
    return Material(
      color: Colors.white,
      elevation: 14.0,
      shadowColor: Color(0x802196F3),
      borderRadius: BorderRadius.circular(24.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        "${revenueDigit.toString()}",
                        style: TextStyle(
                            color: Colors.green[900], fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        revenueHeading,
                        style: TextStyle(
                            color: Colors.blue[900], fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    //graph goes here
                    padding: const EdgeInsets.all(8.0),
                    child: Sparkline(
                      // data: graphData1,
                      data: graphData,
                      fillMode: FillMode.below,
                      fillGradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.blue[900], Colors.blue[200]]),
                      lineColor: Colors.blue[800],
                      pointsMode: PointsMode.all,
                      pointSize: 7.0,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Material myItems(IconData icon, String heading, int theDigit, String postFix, Color myColor) {
    return Material(
      color: Colors.white,
      elevation: 14.0,
      shadowColor: Color(0x802196F3),
      borderRadius: BorderRadius.circular(24.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        "${theDigit.toString()} $postFix",
                        style: TextStyle(
                            color: Colors.green[900], fontSize: 15.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        heading,
                        style:
                            TextStyle(color: myColor, fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Material(
                    color: myColor,
                    borderRadius: BorderRadius.circular(24.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        icon,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Material myItemsDouble(
      IconData icon, String heading, double theDigit, String postFix, Color myColor) {
    return Material(
      color: Colors.white,
      elevation: 14.0,
      shadowColor: Color(0x802196F3),
      borderRadius: BorderRadius.circular(24.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        "${theDigit.toString()} $postFix",
                        style: TextStyle(
                            color: Colors.green[900], fontSize: 15.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        heading,
                        style:
                            TextStyle(color: myColor, fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Material(
                    color: myColor,
                    borderRadius: BorderRadius.circular(24.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        icon,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
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
                    text: getTranslated(context, "more_manage"),
                    icon: Icon(FontAwesomeIcons.list),
                  ),
                  Tab(text: getTranslated(context, "more_dashboard"), icon: Icon(Icons.dashboard)),
                ],
              ),
              title: Text(getTranslated(context, "more")),
            ),
            drawer: CategoryDrawer(),
            body: TabBarView(
              children: [
                Padding(
                  padding: EdgeInsets.all(3.0),
                  child: MoreManageList(),
                ),
                StaggeredGridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  children: <Widget>[
                    // myItems(Icons.account_balance_wallet, "Net Revenue (2020)", 8900000000, Colors.blue[800]),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: myGraphChart(
                          "${getTranslated(context, "more_net_revenue")} ($year)", annualRevenue),
                    ),
                    myItemsDouble(
                        Icons.monetization_on,
                        "${getTranslated(context, "more_daily_expense")}",
                        dailyExpenseTotal,
                        "",
                        Colors.blue[800]),
                    myItemsDouble(
                        Icons.account_balance,
                        "${getTranslated(context, "more_expense")} ($monthName)",
                        monthlyExpenseTotal,
                        "",
                        Colors.blue[800]),
                    myItems(
                        Icons.shop_two,
                        "${getTranslated(context, "more_session")} ($monthName)",
                        monthlySession,
                        "",
                        Colors.blue[800]),
                    myItems(Icons.shop, "${getTranslated(context, "more_product")}", productNo, "",
                        Colors.blue[800]),
                    myItems(Icons.category, "${getTranslated(context, "more_categories")}",
                        categoriesNO, "", Colors.blue[800]),
                    myItemsDouble(
                        Icons.account_balance_wallet,
                        "${getTranslated(context, "more_revenue")}($monthName)",
                        monthlyRevenue,
                        "",
                        Colors.blue[800]),
                    myItems(
                        Icons.notification_important,
                        "${getTranslated(context, "more_notification")}",
                        noteNo,
                        "",
                        Colors.blue[800]),
                    myItems(
                        Icons.add_shopping_cart,
                        "${getTranslated(context, "home_order")}($monthName)",
                        monthlyOrder,
                        "",
                        Colors.blue[800]),
                    myItems(Icons.pause_circle_filled, "${getTranslated(context, "hold")}", holdNo,
                        "", Colors.blue[800]),
                    myItems(
                        Icons.remove_shopping_cart,
                        "${getTranslated(context, "more_return")}($monthName)",
                        monthlyReturn,
                        "",
                        Colors.blue[800]),
                    myItems(FontAwesomeIcons.fileInvoice, "${getTranslated(context, 'invoice')}",
                        invoiceNo, "", Colors.blue[800]),
                  ],
                  staggeredTiles: [
                    StaggeredTile.extent(4, 230.0), //Net Revenue
                    StaggeredTile.extent(2, 150.0), //Daily Expenses
                    StaggeredTile.extent(2, 150.0), //Monthly Expenses
                    StaggeredTile.extent(2, 310.0), //Revenue
                    StaggeredTile.extent(2, 150.0), //Products
                    StaggeredTile.extent(2, 150.0), //Categories
                    StaggeredTile.extent(4, 150.0), //orders
                    StaggeredTile.extent(2, 150.0), //Notifications
                    StaggeredTile.extent(2, 310.0), //Sessions
                    StaggeredTile.extent(2, 150.0), //Holds
                    StaggeredTile.extent(4, 150.0), //returns
                    StaggeredTile.extent(4, 150.0), //Invoices
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
