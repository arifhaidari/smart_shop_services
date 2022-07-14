import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/monthly_date_model.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/db/session_model.dart';
import 'package:pos/localization/localization_mixins.dart';

class SaleTab extends StatefulWidget {
  @override
  _SaleTabState createState() => _SaleTabState();
}

class _SaleTabState extends State<SaleTab> {
  List<charts.Series<Sales, String>> _seriesData;
  final PosDatabase dbmanager = new PosDatabase();

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
  }

  List<MonthlyDateModel> revenueExpenseList = List();

  void _getDateBySession(List<MonthlyDateModel> verticalRevenueExpenseData, int yearNo) async {
    _seriesData = List<charts.Series<Sales, String>>();
    Map<String, double> revenueYearList = Map();
    Map<String, double> expenseYearList = Map();
    Map<String, double> profitYearList = Map();

    //Revenue Year List
    revenueYearList["1st"] = 0;
    revenueYearList["2nd"] = 0;
    revenueYearList["3rd"] = 0;
    revenueYearList["4th"] = 0;
    revenueYearList["5th"] = 0;

    //Expense Year List
    expenseYearList["1st"] = 0;
    expenseYearList["2nd"] = 0;
    expenseYearList["3rd"] = 0;
    expenseYearList["4th"] = 0;
    expenseYearList["5th"] = 0;

    //Profit Year List
    profitYearList["1st"] = 0;
    profitYearList["2nd"] = 0;
    profitYearList["3rd"] = 0;
    profitYearList["4th"] = 0;
    profitYearList["5th"] = 0;

    for (var i = 1; i <= yearNo; i++) {
      if (yearNo == 1) {
        for (var i = 0; i < 12; i++) {
          revenueYearList["1st"] = revenueYearList["1st"] + verticalRevenueExpenseData[i].revenue;
          expenseYearList["1st"] = expenseYearList["1st"] + verticalRevenueExpenseData[i].expense;
          profitYearList["1st"] = profitYearList["1st"] + verticalRevenueExpenseData[i].profit;
        }
      }
      if (yearNo == 2) {
        for (var i = 12; i < 24; i++) {
          revenueYearList["2nd"] = revenueYearList["2nd"] + verticalRevenueExpenseData[i].revenue;
          expenseYearList["2nd"] = expenseYearList["2nd"] + verticalRevenueExpenseData[i].expense;
          profitYearList["2nd"] = profitYearList["2nd"] + verticalRevenueExpenseData[i].profit;
        }
      }
      if (yearNo == 3) {
        for (var i = 24; i < 36; i++) {
          revenueYearList["3rd"] = revenueYearList["3rd"] + verticalRevenueExpenseData[i].revenue;
          expenseYearList["3rd"] = expenseYearList["3rd"] + verticalRevenueExpenseData[i].expense;
          profitYearList["3rd"] = profitYearList["3rd"] + verticalRevenueExpenseData[i].profit;
        }
      }
      if (yearNo == 4) {
        for (var i = 36; i < 48; i++) {
          revenueYearList["4th"] = revenueYearList["4th"] + verticalRevenueExpenseData[i].revenue;
          expenseYearList["4th"] = expenseYearList["4th"] + verticalRevenueExpenseData[i].expense;
          profitYearList["4th"] = profitYearList["4th"] + verticalRevenueExpenseData[i].profit;
        }
      }
      if (yearNo == 5) {
        for (var i = 48; i < 60; i++) {
          revenueYearList["5th"] = revenueYearList["5th"] + verticalRevenueExpenseData[i].revenue;
          expenseYearList["5th"] = expenseYearList["5th"] + verticalRevenueExpenseData[i].expense;
          profitYearList["5th"] = profitYearList["5th"] + verticalRevenueExpenseData[i].profit;
        }
      }
    }

    List<Sales> revenueData = List();
    List<Sales> expenseData = List();
    List<Sales> profitData = List();

    for (var key in revenueYearList.keys) {
      revenueData.add(Sales(key, revenueYearList[key]));
    }

    for (var key in expenseYearList.keys) {
      expenseData.add(Sales(key, expenseYearList[key]));
    }

    for (var key in profitYearList.keys) {
      profitData.add(Sales(key, profitYearList[key]));
    }

    _seriesData.add(
      charts.Series(
        domainFn: (Sales sales, _) => sales.year,
        measureFn: (Sales sales, _) => sales.sale,
        id: getTranslated(context, "analytics_revenue"),
        data: revenueData,
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        fillColorFn: (Sales sales, _) => charts.ColorUtil.fromDartColor(Colors.blue[800]),
        colorFn: (Sales sales, _) => charts.ColorUtil.fromDartColor(Colors.blue[800]),
      ),
    );

    _seriesData.add(
      charts.Series(
        domainFn: (Sales sales, _) => sales.year,
        measureFn: (Sales sales, _) => sales.sale,
        id: getTranslated(context, "analytics_expense"),
        data: expenseData,
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        fillColorFn: (Sales sales, _) => charts.ColorUtil.fromDartColor(Colors.green[800]),
        colorFn: (Sales sales, _) => charts.ColorUtil.fromDartColor(Colors.green[800]),
      ),
    );

    _seriesData.add(
      charts.Series(
        domainFn: (Sales sales, _) => sales.year,
        measureFn: (Sales sales, _) => sales.sale,
        id: getTranslated(context, "analytics_profit"),
        data: profitData,
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        fillColorFn: (Sales sales, _) => charts.ColorUtil.fromDartColor(Colors.deepOrange),
        colorFn: (Sales sales, _) => charts.ColorUtil.fromDartColor(Colors.deepOrange),
      ),
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
          List<OrderModel> annualSale = snapshot.data;
          annualSale.forEach((p) {
            if (selectedYear.containsKey(p.timestamp.substring(0, 7))) {
              // do nothing
            } else {
              selectedYear[p.timestamp.substring(0, 7)] = 0; // it should be zero
            }
          });

          return _buildBody(context, selectedYear);
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, Map<String, double> myDataApp) {
    List<MonthlyDateModel> verticalRevenueExpenseTemp = List();
    return FutureBuilder(
      future: dbmanager.getAnnualGraphSale(myDataApp),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(child: Center(child: new CircularProgressIndicator()));
        } else {
          List<MonthlyDateModel> tempList = snapshot.data;

          int listLenght = tempList.length;
          int graphDisplayList = (listLenght / 12).floor();
          for (var i = 0; i < graphDisplayList * 12; i++) {
            verticalRevenueExpenseTemp.add(tempList[i]);
          }

          return _buildChart(context, verticalRevenueExpenseTemp, graphDisplayList);
        }
      },
    );
  }

  Widget _buildChart(BuildContext context, List<MonthlyDateModel> myDataList, int yearNo) {
    // verticalRevenueExpenseData = myDataList;
    _getDateBySession(myDataList, yearNo);
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              getTranslated(context, "analytics_sale_tab"),
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: charts.BarChart(
                _seriesData,
                animate: true,
                barGroupingType: charts.BarGroupingType.grouped,
                behaviors: [
                  new charts.SeriesLegend(
                    // charts.DatumLegend(
                    entryTextStyle: charts.TextStyleSpec(
                        color: charts.MaterialPalette.purple.shadeDefault, fontSize: 17),
                    // ),
                  ),
                ],
                animationDuration: Duration(seconds: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Sales {
  final String year;
  final double sale;

  Sales(this.year, this.sale);
}
