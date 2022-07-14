import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos/db/Inventory_model.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/analytics/expenses_tab.dart';
import 'package:pos/pages/analytics/inventory_graph.dart';
import 'package:pos/pages/analytics/profit_tab.dart';
import 'package:pos/pages/analytics/revenue_tab.dart';
import 'package:pos/pages/analytics/sale_tab.dart';
import 'package:pos/pages/home/placeholder.dart';

class AnalyticsHome extends StatefulWidget {
  final Widget child;

  AnalyticsHome({Key key, this.child}) : super(key: key);

  _AnalyticsHomeState createState() => _AnalyticsHomeState();
}

class _AnalyticsHomeState extends State<AnalyticsHome> {
  // List<charts.Series<Sales, String>> _seriesData;

  final _searchFieldController = TextEditingController();
  final PosDatabase dbmanager = new PosDatabase();

  String _dateTimeObject = "all";

  List<InventoryModel> inventoryList = List();

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue[900],
            bottom: TabBar(
              // isScrollable: true,
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  text: getTranslated(context, "analytics_revenue"),
                  icon: Icon(FontAwesomeIcons.chartBar),
                ),
                Tab(
                  text: getTranslated(context, "analytics_profit"),
                  icon: Icon(FontAwesomeIcons.chartBar),
                ),
                Tab(
                    text: getTranslated(context, "analytics_inventory"),
                    icon: Icon(FontAwesomeIcons.chartPie)),
                Tab(
                  text: getTranslated(context, "analytics_expense"),
                  icon: Icon(FontAwesomeIcons.wallet),
                ),
                Tab(
                    text: getTranslated(context, "analytics_sales"),
                    icon: Icon(FontAwesomeIcons.chartLine)),
              ],
            ),
            title: Text(getTranslated(context, "analytics_title")),
          ),
          body: TabBarView(
            children: [
              Padding(
                padding: EdgeInsets.all(3.0),
                child: RavenueTab(),
              ),
              Padding(
                padding: EdgeInsets.all(3.0),
                child: ProfitTab(),
              ),
              Padding(
                padding: EdgeInsets.all(3.0),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {},
                      ),
                      // title: MyAppBar(),
                      // pinned: true,
                      floating: true,
                      expandedHeight: 400.0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: InventoryGraph(),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        <Widget>[
                          FutureBuilder(
                            future: dbmanager.getInventoryList(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                inventoryList = snapshot.data;
                                if (inventoryList.length == 0) {
                                  return Container(
                                    child: Center(child: PlaceHolderContent()),
                                  );
                                }

                                return ListView.builder(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    itemCount: inventoryList == null ? 0 : inventoryList.length,
                                    itemBuilder: (context, index) {
                                      InventoryModel iml = inventoryList[index];
                                      return Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Card(
                                          elevation: 5,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.all(5.0),
                                            onTap: null,
                                            subtitle: Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(3.0),
                                                        child: Text(
                                                          iml.name,
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
                                                          "${getTranslated(context, "analytics_revenue")}:  ${iml.product_subtotal}",
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
                                                          "${iml.quantity} - ${getTranslated(context, "analytics_in_stock")}",
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
                                                          "${getTranslated(context, "analytics_sold_items")}: ${iml.product_quantity}",
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
                              return Container(
                                  child: Center(child: new CircularProgressIndicator()));
                            },
                          ),
                          // myCardDetails(
                          //     "images/bitcoin.png", "Bitcoin", data1, "4702", "3.0", "\u2191", 0xff07862b),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: ExpenseTab(),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: SaleTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
