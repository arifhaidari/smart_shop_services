import 'package:flutter/material.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/order/order_detail.dart';

class SessionDetailList extends StatefulWidget {
  final sessionId;

  SessionDetailList({this.sessionId});
  @override
  _SessionDetailListState createState() => _SessionDetailListState();
}

class _SessionDetailListState extends State<SessionDetailList> {
  final PosDatabase dbmanager = new PosDatabase();
  List<OrderModel> sessionOrderList = List();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: FutureBuilder(
            future: dbmanager.getSingleSessionOrderList(widget.sessionId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                sessionOrderList = snapshot.data;
                if (sessionOrderList.length == 0) {
                  return Container(
                    child: Center(child: PlaceHolderContent()),
                  );
                }
                return ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: sessionOrderList == null ? 0 : sessionOrderList.length,
                    itemBuilder: (context, index) {
                      OrderModel ol = sessionOrderList[index];
                      if (sessionOrderList.length != 0) {
                        return Card(
                          elevation: 5.0,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetail(
                                    orderObject: ol,
                                  ),
                                ),
                              );
                            },
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: RichText(
                                            text: TextSpan(
                                                text: ol.payment_completion_status == false
                                                    ? getTranslated(context, "invoice")
                                                    : (ol.order_subtotal > 0
                                                        ? getTranslated(
                                                            context, "invoice_order_number")
                                                        : getTranslated(context, "returned")),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold),
                                                children: [
                                                  TextSpan(
                                                    text: "-#${ol.id}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ]),
                                          )),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: RichText(
                                            text: TextSpan(
                                                text:
                                                    "${getTranslated(context, "notification_collected_amount")} +",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "${ol.cash_collected}",
                                                    style: TextStyle(
                                                      color: Colors.green[900],
                                                      fontSize: 15.0,
                                                    ),
                                                  ),
                                                ]),
                                          )),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: RichText(
                                            text: TextSpan(
                                                text:
                                                    "${getTranslated(context, "notification_returned_amount")} -",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "${ol.change_due}",
                                                    style: TextStyle(
                                                      color: Colors.red[900],
                                                      fontSize: 15.0,
                                                    ),
                                                  ),
                                                ]),
                                          )),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: RichText(
                                            text: TextSpan(
                                                text:
                                                    "${getTranslated(context, "more_net_revenue")} ",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "${ol.order_subtotal}",
                                                    style: TextStyle(
                                                      color: Colors.blue[900],
                                                      fontSize: 15.0,
                                                    ),
                                                  ),
                                                ]),
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return PlaceHolderContent();
                      }
                    });
              }
              return Container(child: Center(child: new CircularProgressIndicator()));
            },
          )),
        ],
      ),
    );
  }
}
