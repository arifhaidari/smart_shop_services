import 'package:flutter/material.dart';

//My Imports
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/invoice_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/order/invoice_detail.dart';
import 'package:random_color/random_color.dart';

class InvoiceTab extends StatefulWidget {
  @override
  _InvoiceTabState createState() => _InvoiceTabState();
}

class _InvoiceTabState extends State<InvoiceTab> {
  final PosDatabase dbmanager = new PosDatabase();
  List<InvoiceModel> invoiceList = List();

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  void getDataList() async {
    await dbmanager.getInvoiceList().then((value) {
      setState(() {
        invoiceList = value;
      });
    });
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(milliseconds: 50));

    return null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    RandomColor _randomColor = RandomColor();
    return Container(
      color: Colors.grey[150],
      child: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: Column(
          children: <Widget>[
            Expanded(
                child: FutureBuilder(
              future: dbmanager.getInvoiceList(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  invoiceList = snapshot.data;
                  if (invoiceList.length == 0) {
                    return Container(
                      child: Center(child: PlaceHolderContent()),
                    );
                  }
                  return ListView.builder(
                      itemCount: invoiceList == null ? 0 : invoiceList.length,
                      itemBuilder: (context, index) {
                        InvoiceModel invoiceObject = invoiceList[index];
                        return Container(
                          width: width * 1.0,
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InvoiceDetail(
                                        invoiceObject: invoiceObject,
                                      ),
                                    ),
                                  ).then((value) => getDataList());
                                },
                                title: Text(
                                  invoiceObject.customer_name,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                contentPadding: EdgeInsets.all(0.0),
                                subtitle: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                              "${getTranslated(context, "invoice_paid")}: ${invoiceObject.invoice_paid_amount}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                              "${getTranslated(context, "invoice_issue")}: ${invoiceObject.invoice_issue_date}",
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
                                              "${getTranslated(context, "invoice_payable")}: ${invoiceObject.invoice_payable_amount}",
                                              style: TextStyle(
                                                  color: Colors.green[900],
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                              "${getTranslated(context, "invoice_due")}: ${invoiceObject.invoice_due_date.toString()}",
                                              style: TextStyle(
                                                  color: Colors.green[900],
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
                          ),
                        );
                      });
                }
                return Container(child: Center(child: new CircularProgressIndicator()));
              },
            )),
          ],
        ),
      ),
    );
  }
}
