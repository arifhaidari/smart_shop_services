import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pos/db/Inventory_model.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/localization/localization_mixins.dart';

class InventoryGraph extends StatefulWidget {
  @override
  _InventoryGraphState createState() => _InventoryGraphState();
}

class _InventoryGraphState extends State<InventoryGraph> {
  List<charts.Series<Inventory, String>> _seriesPieData;
  final PosDatabase dbmanager = new PosDatabase();

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    // _generateData();
  }

  _generateData(List<InventoryModel> inventoryList) {
    _seriesPieData = List<charts.Series<Inventory, String>>();
    //temp.length > 13 ? temp.substring(0, 12) : temp

    List<Inventory> inventoryData = List();

    if (inventoryList.length == 6) {
      inventoryData = [
        new Inventory(
            productName: inventoryList[0].name.length > 13
                ? inventoryList[0].name.substring(0, 16)
                : inventoryList[0].name,
            productQuantity: inventoryList[0].product_quantity,
            colorValue: Color(0xff3366cc)),
        new Inventory(
            productName: inventoryList[1].name.length > 13
                ? inventoryList[1].name.substring(0, 16)
                : inventoryList[1].name,
            productQuantity: inventoryList[1].product_quantity,
            colorValue: Color(0xff990099)),
        new Inventory(
            productName: inventoryList[2].name.length > 13
                ? inventoryList[2].name.substring(0, 16)
                : inventoryList[2].name,
            productQuantity: inventoryList[2].product_quantity,
            colorValue: Color(0xff109618)),
        new Inventory(
            productName: inventoryList[3].name.length > 13
                ? inventoryList[3].name.substring(0, 16)
                : inventoryList[3].name,
            productQuantity: inventoryList[3].product_quantity,
            colorValue: Color(0xFF00796B)),
        new Inventory(
            productName: inventoryList[4].name.length > 13
                ? inventoryList[4].name.substring(0, 16)
                : inventoryList[4].name,
            productQuantity: inventoryList[4].product_quantity,
            colorValue: Color(0xFFF57C00)),
        new Inventory(
            productName: inventoryList[5].name.length > 13
                ? inventoryList[5].name.substring(0, 16)
                : inventoryList[5].name,
            productQuantity: inventoryList[5].product_quantity,
            colorValue: Color(0xFF004D40)),
      ];
    } else if (inventoryList.length == 5) {
      inventoryData = [
        new Inventory(
            productName: inventoryList[0].name.length > 13
                ? inventoryList[0].name.substring(0, 16)
                : inventoryList[0].name,
            productQuantity: inventoryList[0].product_quantity,
            colorValue: Color(0xff3366cc)),
        new Inventory(
            productName: inventoryList[1].name.length > 13
                ? inventoryList[1].name.substring(0, 16)
                : inventoryList[1].name,
            productQuantity: inventoryList[1].product_quantity,
            colorValue: Color(0xff990099)),
        new Inventory(
            productName: inventoryList[2].name.length > 13
                ? inventoryList[2].name.substring(0, 16)
                : inventoryList[2].name,
            productQuantity: inventoryList[2].product_quantity,
            colorValue: Color(0xff109618)),
        new Inventory(
            productName: inventoryList[3].name.length > 13
                ? inventoryList[3].name.substring(0, 16)
                : inventoryList[3].name,
            productQuantity: inventoryList[3].product_quantity,
            colorValue: Color(0xFF00796B)),
        new Inventory(
            productName: inventoryList[4].name.length > 13
                ? inventoryList[4].name.substring(0, 16)
                : inventoryList[4].name,
            productQuantity: inventoryList[4].product_quantity,
            colorValue: Color(0xFFF57C00)),
      ];
    } else if (inventoryList.length == 4) {
      inventoryData = [
        new Inventory(
            productName: inventoryList[0].name.length > 13
                ? inventoryList[0].name.substring(0, 16)
                : inventoryList[0].name,
            productQuantity: inventoryList[0].product_quantity,
            colorValue: Color(0xff3366cc)),
        new Inventory(
            productName: inventoryList[1].name.length > 13
                ? inventoryList[1].name.substring(0, 16)
                : inventoryList[1].name,
            productQuantity: inventoryList[1].product_quantity,
            colorValue: Color(0xff990099)),
        new Inventory(
            productName: inventoryList[2].name.length > 13
                ? inventoryList[2].name.substring(0, 16)
                : inventoryList[2].name,
            productQuantity: inventoryList[2].product_quantity,
            colorValue: Color(0xff109618)),
        new Inventory(
            productName: inventoryList[3].name.length > 13
                ? inventoryList[3].name.substring(0, 16)
                : inventoryList[3].name,
            productQuantity: inventoryList[3].product_quantity,
            colorValue: Color(0xFF00796B)),
      ];
    } else if (inventoryList.length == 3) {
      inventoryData = [
        new Inventory(
            productName: inventoryList[0].name.length > 13
                ? inventoryList[0].name.substring(0, 16)
                : inventoryList[0].name,
            productQuantity: inventoryList[0].product_quantity,
            colorValue: Color(0xff3366cc)),
        new Inventory(
            productName: inventoryList[1].name.length > 13
                ? inventoryList[1].name.substring(0, 16)
                : inventoryList[1].name,
            productQuantity: inventoryList[1].product_quantity,
            colorValue: Color(0xff990099)),
        new Inventory(
            productName: inventoryList[2].name.length > 13
                ? inventoryList[2].name.substring(0, 16)
                : inventoryList[2].name,
            productQuantity: inventoryList[2].product_quantity,
            colorValue: Color(0xff109618)),
      ];
    } else if (inventoryList.length == 2) {
      inventoryData = [
        new Inventory(
            productName: inventoryList[0].name.length > 13
                ? inventoryList[0].name.substring(0, 16)
                : inventoryList[0].name,
            productQuantity: inventoryList[0].product_quantity,
            colorValue: Color(0xff3366cc)),
        new Inventory(
            productName: inventoryList[1].name.length > 13
                ? inventoryList[1].name.substring(0, 16)
                : inventoryList[1].name,
            productQuantity: inventoryList[1].product_quantity,
            colorValue: Color(0xff990099)),
      ];
    } else if (inventoryList.length == 1) {
      inventoryData = [
        new Inventory(
            productName: inventoryList[0].name.length > 13
                ? inventoryList[0].name.substring(0, 16)
                : inventoryList[0].name,
            productQuantity: inventoryList[0].product_quantity,
            colorValue: Color(0xff3366cc)),
      ];
    } else {
      inventoryData = [
        new Inventory(
            productName: getTranslated(context, "analytics_no_product"),
            productQuantity: 1,
            colorValue: Color(0xff3366cc)),
      ];
    }

    _seriesPieData.add(
      charts.Series(
        domainFn: (Inventory inventory, _) => inventory.productName,
        measureFn: (Inventory inventory, _) => inventory.productQuantity,
        colorFn: (Inventory inventory, _) => charts.ColorUtil.fromDartColor(inventory.colorValue),
        id: getTranslated(context, "analytics_top_sales"),
        data: inventoryData,
        labelAccessorFn: (Inventory row, _) => '${row.productQuantity}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<InventoryModel> allInventoryList = List();
    List<InventoryModel> allInventoryTempList = List();
    return FutureBuilder(
      future: dbmanager.getInventoryList(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(child: Center(child: new CircularProgressIndicator()));
        } else {
          allInventoryList = snapshot.data;

          if (allInventoryList.length >= 6) {
            allInventoryTempList = allInventoryList.sublist(0, 6);
          } else {
            allInventoryTempList = allInventoryList;
          }

          return _buildPieChart(context, allInventoryTempList);
        }
      },
    );
  }

  Widget _buildPieChart(BuildContext context, List<InventoryModel> inventoryTempList) {
    _generateData(inventoryTempList);
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Expanded(
                child: Stack(
              children: <Widget>[
                charts.PieChart(_seriesPieData,
                    animate: true,
                    animationDuration: Duration(seconds: 1),
                    behaviors: [
                      new charts.DatumLegend(
                        outsideJustification: charts.OutsideJustification.endDrawArea,
                        horizontalFirst: false,
                        desiredMaxRows: 2,
                        cellPadding: new EdgeInsets.only(right: 4.0, bottom: 2.0),
                        entryTextStyle: charts.TextStyleSpec(
                            color: charts.MaterialPalette.purple.shadeDefault,
                            fontFamily: 'Georgia',
                            fontSize: 11),
                      )
                    ],
                    defaultRenderer:
                        new charts.ArcRendererConfig(arcWidth: 100, arcRendererDecorators: [
                      new charts.ArcLabelDecorator(labelPosition: charts.ArcLabelPosition.inside)
                    ])),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                    child: Text(
                      getTranslated(context, "analytics_hot_sales"),
                      style:
                          TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class Inventory {
  String productName;
  int productQuantity;
  Color colorValue;

  Inventory({this.productName, this.productQuantity, this.colorValue});
}
