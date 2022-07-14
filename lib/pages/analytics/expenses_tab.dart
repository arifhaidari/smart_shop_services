import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/db/session_model.dart';
import 'package:pos/localization/localization_mixins.dart';

class ExpenseTab extends StatefulWidget {
  @override
  _ExpenseTabState createState() => _ExpenseTabState();
}

class _ExpenseTabState extends State<ExpenseTab> {
  List<charts.Series<Expense, String>> _seriesHorizontalExpenseBarData;

  // year = timeStamp.substring(0, 4);//2020
  // String month = timeStamp.substring(5, 7); //09
  // String yearMonth = timeStamp.substring(0, 7); //2020-09
  final PosDatabase dbmanager = new PosDatabase();

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
  }

  List<Expense> expenseList = List();

  List<Expense> horizotalExpenseData = List(); //= List();

  void _getDateBySession(List<Expense> horizotalExpenseData) async {
    _seriesHorizontalExpenseBarData = List<charts.Series<Expense, String>>();

    Map<String, double> revenueMonthList = Map();

    //Revenue : month|revenue

    for (var i = 0; i < horizotalExpenseData.length; i++) {
      revenueMonthList[horizotalExpenseData[i].month] = horizotalExpenseData[i].monthlyExpense;
    }

    int tempLength = 12 - horizotalExpenseData.length;

    for (var i = 1; i <= tempLength; i++) {
      revenueMonthList["${getTranslated(context, "analytics_coming_month")}_$i"] = 0.0;
    }

    List<Expense> expenseData = List();

    for (var key in revenueMonthList.keys) {
      expenseData.add(Expense(key, revenueMonthList[key]));
    }

    _seriesHorizontalExpenseBarData.add(
      charts.Series(
          domainFn: (Expense expense, _) => expense.month,
          measureFn: (Expense expense, _) => expense.monthlyExpense,
          id: getTranslated(context, "analytics_revenue"),
          data: expenseData,
          fillPatternFn: (_, __) => charts.FillPatternType.solid,
          // fillColorFn: (Expense expense, _) {
          //   return charts.MaterialPalette.blue.shadeDefault;
          // },
          // fillColorFn: (Expense expense, _) => charts.ColorUtil.fromDartColor(Color(0xff990099)),
          fillColorFn: (Expense expense, _) => charts.ColorUtil.fromDartColor(Colors.blue[800]),
          // Set a label accessor to control the text of the bar label.
          labelAccessorFn: (Expense expense, _) =>
              '${expense.month}: ${expense.monthlyExpense.toString()}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> selectedYear = Map();
    return FutureBuilder(
      future: dbmanager.getOrderListAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(child: Center(child: new CircularProgressIndicator()));
        } else {
          List<OrderModel> expense = snapshot.data;
          expense.forEach((p) {
            // setState(() {
            if (selectedYear.containsKey(p.timestamp.substring(0, 7))) {
              // do nothing
            } else {
              selectedYear[p.timestamp.substring(0, 7)] = 0;
            }
            // });
          });

          return _buildBody(context, selectedYear);
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, Map<String, double> myDataApp) {
    return FutureBuilder(
      future: dbmanager.getMonthlyGraphExpense(myDataApp),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(child: Center(child: new CircularProgressIndicator()));
        } else {
          List<Expense> tempList = snapshot.data;

          tempList.forEach((p) {
            expenseList.add(p);
          });

          int listLenght = expenseList.length;
          int graphDisplayList = listLenght % 12;

          for (var i = graphDisplayList; i > 0; i--) {
            // setState(() {
            horizotalExpenseData.add(expenseList[expenseList.length - i]);
          }

          return _buildChart(context, horizotalExpenseData);
        }
      },
    );
  }

  Widget _buildChart(BuildContext context, List<Expense> myDataList) {
    horizotalExpenseData = myDataList;
    _getDateBySession(horizotalExpenseData);
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: charts.BarChart(
                _seriesHorizontalExpenseBarData,
                animate: true,
                vertical: false,
                // vertical: MediaQuery.of(context).orientation == Orientation.portrait
                //     ? false
                //     : true, //for expenses
                barRendererDecorator: new charts.BarLabelDecorator<String>(),
                domainAxis: new charts.OrdinalAxisSpec(renderSpec: new charts.NoneRenderSpec()),
                // barGroupingType: charts.BarGroupingType.grouped,
                // behaviors: [new charts.SeriesLegend()],
                animationDuration: Duration(seconds: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Expense {
  final String month;
  final double monthlyExpense;

  Expense(this.month, this.monthlyExpense);
}
