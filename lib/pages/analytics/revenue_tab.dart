import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/localization/localization_mixins.dart';

class RavenueTab extends StatefulWidget {
  @override
  _RavenueTabState createState() => _RavenueTabState();
}

class _RavenueTabState extends State<RavenueTab> {
  List<charts.Series<NetRevenue, String>> _seriesHorizontalRevenueBarData;

  final PosDatabase dbmanager = new PosDatabase();

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
  }

  List<NetRevenue> netRevenueList = List();

  List<NetRevenue> horizotalRevenueData = List(); //= List();

  void _getDateBySession(List<NetRevenue> horizotalRevenueData) async {
    _seriesHorizontalRevenueBarData = List<charts.Series<NetRevenue, String>>();

    Map<String, double> revenueMonthList = Map();

    for (var i = 0; i < horizotalRevenueData.length; i++) {
      revenueMonthList[horizotalRevenueData[i].month] = horizotalRevenueData[i].monthRevenue;
    }

    int tempLength = 12 - horizotalRevenueData.length;

    for (var i = 1; i <= tempLength; i++) {
      revenueMonthList["${getTranslated(context, "analytics_coming_month")}_$i"] = 0.0;
    }

    List<NetRevenue> netRevenueData = List();

    for (var key in revenueMonthList.keys) {
      netRevenueData.add(NetRevenue(key, revenueMonthList[key]));
    }

    _seriesHorizontalRevenueBarData.add(
      charts.Series(
          domainFn: (NetRevenue netRevenue, _) => netRevenue.month,
          measureFn: (NetRevenue netRevenue, _) => netRevenue.monthRevenue,
          id: getTranslated(context, "analytics_revenue"),
          data: netRevenueData,
          fillPatternFn: (_, __) => charts.FillPatternType.solid,
          // fillColorFn: (Expense expense, _) {
          //   return charts.MaterialPalette.blue.shadeDefault;
          // },
          // fillColorFn: (Expense expense, _) => charts.ColorUtil.fromDartColor(Color(0xff990099)),
          fillColorFn: (NetRevenue expense, _) => charts.ColorUtil.fromDartColor(Colors.green[800]),
          // Set a label accessor to control the text of the bar label.
          labelAccessorFn: (NetRevenue netRevenue, _) =>
              '${netRevenue.month}: ${netRevenue.monthRevenue.toString()}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Screen got rebuild');
    Map<String, double> selectedYear = Map();
    return FutureBuilder(
      future: dbmanager.getOrderListAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(child: Center(child: new CircularProgressIndicator()));
        } else {
          List<OrderModel> netRevenue = snapshot.data;
          netRevenue.forEach((p) {
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
    return FutureBuilder(
      future: dbmanager.getMonthlyGraphRevenue(myDataApp),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(child: Center(child: new CircularProgressIndicator()));
        } else {
          List<NetRevenue> tempList = snapshot.data;

          tempList.forEach((p) {
            netRevenueList.add(p);
          });

          int listLenght = netRevenueList.length;
          int graphDisplayList = listLenght % 12;

          for (var i = graphDisplayList; i > 0; i--) {
            horizotalRevenueData.add(netRevenueList[netRevenueList.length - i]);
          }
          return _buildChart(context, horizotalRevenueData);
        }
      },
    );
  }

  Widget _buildChart(BuildContext context, List<NetRevenue> myDataList) {
    horizotalRevenueData = myDataList;
    _getDateBySession(horizotalRevenueData);
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: charts.BarChart(
                _seriesHorizontalRevenueBarData,
                animate: true,
                vertical: false,
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

class NetRevenue {
  final String month;
  final double monthRevenue;

  NetRevenue(this.month, this.monthRevenue);
}
