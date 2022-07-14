import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/localization/localization_mixins.dart';

class ProfitTab extends StatefulWidget {
  @override
  _ProfitTabState createState() => _ProfitTabState();
}

class _ProfitTabState extends State<ProfitTab> {
  List<charts.Series<Profit, String>> _seriesHorizontalProfitBarData;

  final PosDatabase dbmanager = new PosDatabase();

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
  }

  List<Profit> profitList = List();

  List<Profit> horizotalProfitData = List(); //= List();

  void _getDateBySession(List<Profit> horizotalProfitData) async {
    _seriesHorizontalProfitBarData = List<charts.Series<Profit, String>>();

    Map<String, double> profitMonthList = Map();

    //Revenue : month|revenue

    for (var i = 0; i < horizotalProfitData.length; i++) {
      profitMonthList[horizotalProfitData[i].month] = horizotalProfitData[i].monthlyProfit;
    }

    int tempLength = 12 - horizotalProfitData.length;

    for (var i = 1; i <= tempLength; i++) {
      profitMonthList["${getTranslated(context, "analytics_coming_month")}_$i"] = 0.0;
    }

    List<Profit> profitData = List();

    for (var key in profitMonthList.keys) {
      profitData.add(Profit(key, profitMonthList[key]));
    }

    _seriesHorizontalProfitBarData.add(
      charts.Series(
          domainFn: (Profit profit, _) => profit.month,
          measureFn: (Profit profit, _) => profit.monthlyProfit,
          id: getTranslated(context, "analytics_profit"),
          data: profitData,
          fillPatternFn: (_, __) => charts.FillPatternType.solid,
          fillColorFn: (Profit profit, _) => charts.ColorUtil.fromDartColor(Colors.deepOrange),
          // Set a label accessor to control the text of the bar label.
          labelAccessorFn: (Profit profit, _) =>
              '${profit.month}: ${profit.monthlyProfit.toString()}'),
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
          List<OrderModel> profit = snapshot.data;
          profit.forEach((p) {
            if (selectedYear.containsKey(p.timestamp.substring(0, 7))) {
            } else {
              selectedYear[p.timestamp.substring(0, 7)] = 0;
            }
          });
          return _buildBody(context, selectedYear);
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, Map<String, double> myDataApp) {
    // Map<String, int> selectedYearFinal = Map();
    return FutureBuilder(
      future: dbmanager.getMonthlyGraphProfit(myDataApp),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(child: Center(child: new CircularProgressIndicator()));
        } else {
          List<Profit> tempList = snapshot.data;

          tempList.forEach((p) {
            profitList.add(p);
          });

          int listLenght = profitList.length;
          int graphDisplayList = listLenght % 12;

          for (var i = graphDisplayList; i > 0; i--) {
            // setState(() {
            horizotalProfitData.add(profitList[profitList.length - i]);
          }

          return _buildChart(context, horizotalProfitData);
        }
      },
    );
  }

  Widget _buildChart(BuildContext context, List<Profit> myDataList) {
    horizotalProfitData = myDataList;
    _getDateBySession(horizotalProfitData);
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            // Text(
            //   'Monthly Revenues',
            //   style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            // ),
            Expanded(
              child: charts.BarChart(
                _seriesHorizontalProfitBarData,
                animate: true,
                vertical: false, //for expenses
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

class Profit {
  final String month;
  final double monthlyProfit;

  Profit(this.month, this.monthlyProfit);
}
