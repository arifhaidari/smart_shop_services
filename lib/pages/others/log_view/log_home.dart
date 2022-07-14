import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/logs/all_logs.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/notification/invoice_due_detail.dart';
import 'package:pos/pages/order/order_detail.dart';
import 'package:pos/pages/others/log_view/deleted_product_view.dart';
import 'package:pos/pages/others/log_view/product_log_view.dart';
import 'package:random_color/random_color.dart';

class LogHome extends StatefulWidget {
  @override
  _LogHomeState createState() => _LogHomeState();
}

class _LogHomeState extends State<LogHome> {
  final PosDatabase dbmanager = new PosDatabase();
  List<Logs> logList = List();
  final now = DateTime.parse(DateTime.now().toString().substring(0, 10));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, 'other_logs')),
      ),
      body: FutureBuilder(
        future: dbmanager.getAllLogs(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            logList = snapshot.data;
            if (logList.length == 0) {
              return Container(
                child: Center(child: PlaceHolderContent()),
              );
            }

            return ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: logList == null ? 0 : logList.length,
                itemBuilder: (context, index) {
                  Logs ll = logList[index];
                  var due = DateTime.parse(ll.timestamp.substring(0, 10));
                  int leftDueDay = now.difference(due).inDays;
                  if (leftDueDay >= 60) {
                    expireLog(ll.id);
                  } //
                  else {
                    return _barcodeListTile(ll, logList, index);
                  }
                });
          }
          return Container(child: Center(child: new CircularProgressIndicator()));
        },
      ),
    );
  }

  Widget _barcodeListTile(Logs log, List<Logs> myBarcodeList, int myIndex) {
    RandomColor _randomColor = RandomColor();
    Color _color = _randomColor.randomColor(colorSaturation: ColorSaturation.highSaturation);

    var nameInitial = log.model[0].toUpperCase();

    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ListTile(
          onTap: () {
            myNavigator(log);
          },
          leading: CircleAvatar(
              radius: 35.0,
              backgroundColor: _color,
              foregroundColor: Colors.black,
              // backgroundImage: NetworkImage(img),
              child: Text(
                nameInitial,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              )),
          title: Text(
            log.model,
            style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.bold),
          ),
          contentPadding: EdgeInsets.all(0.0),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                log.detail,
                style:
                    TextStyle(color: Colors.blue[900], fontSize: 15.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              Text(
                DateFormat.yMMMMd().add_jm().format(DateTime.parse(log.timestamp)),
                style: TextStyle(
                    color: Colors.green[900], fontSize: 14.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void myNavigator(Logs log) async {
    if (log.operation == 'edit_product') {
      var product;
      var productLog;
      await dbmanager.getSingleProduct(log.model_id).then((value) {
        setState(() {
          product = value;
        });
      });
      await dbmanager.getSingleProductLog(log.id).then((value) {
        setState(() {
          productLog = value;
        });
      });
      if (product != null && productLog != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductLogView(
                      product: product,
                      productLog: productLog,
                    )));
      }
    } else if (log.operation == "pay_invoice") {
      await dbmanager.getSingleInvoice(log.model_id).then((onValue) {
        if (onValue != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InvoiceDueDetail(
                        invoiceObject: onValue,
                      )));
        }
      });
    } else if (log.operation == "complete_invoice") {
      await dbmanager.getSingleOrder(log.model_id).then((value) {
        if (value != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetail(
                orderObject: value,
              ),
            ),
          );
        }
      });
    } else if (log.operation == "delete_product") {
      // var productLog;
      await dbmanager.getSingleProductLog(log.id).then((value) {
        if (value != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DeletedProductView(
                        productLog: value,
                      )));
        }
      });
    } else {
      _showToastMessage('There is no more detail for this option');
    }
  }

  void _showToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void expireLog(int id) async {
    await dbmanager.deleteLog(id);
  }
}
