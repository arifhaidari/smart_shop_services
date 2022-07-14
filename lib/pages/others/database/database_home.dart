import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/django_rest_api/import_export/drop_database.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'backup_tab.dart';
import 'import_tab.dart';

class DatabaesHome extends StatefulWidget {
  @override
  _DatabaesHomeState createState() => _DatabaesHomeState();
}

class _DatabaesHomeState extends State<DatabaesHome> {
  final PosDatabase dbmanager = new PosDatabase();
  final DropDatabase dropDatabase = new DropDatabase();
  int currentIndex = 0;

  Widget _widgetAction() {
    if (currentIndex == 1) {
      return Row(
        children: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.database, color: Colors.white),
              onPressed: () {
                clearBakcupHistory(context);
              }),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                _deleteDatabaseDialogue(context);
              }),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              _widgetAction(),
            ],
            backgroundColor: Colors.blue[900],
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
                    text: getTranslated(context, "other_import"),
                    icon: Icon(FontAwesomeIcons.fileImport)),
                Tab(
                  text: getTranslated(context, "other_backup"),
                  icon: Icon(FontAwesomeIcons.fileExport),
                ),
              ],
            ),
            title: Text(getTranslated(context, "other_database")),
          ),
          body: TabBarView(
            children: [
              Padding(
                padding: EdgeInsets.all(3.0),
                child: ImportTab(),
              ),
              Padding(
                padding: EdgeInsets.all(3.0),
                child: BackupTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> clearBakcupHistory(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, 'other_clear_history_title'),
              style:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Text(
              getTranslated(context, 'other_clear_history_content'),
              style: TextStyle(color: Colors.green[900]),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "cancel"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "yes"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  await dbmanager.deleteBackupAllHistory().then((value) {
                    _showToastMessage(getTranslated(context, 'other_clear_history_success'));
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> _deleteDatabaseDialogue(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, "other_drop_alert"),
              style:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Text(
              getTranslated(context, "other_drop_content"),
              style: TextStyle(color: Colors.green[900]),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "cancel"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "other_drop"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  removeCategory();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void removeCategory() async {
    await dropDatabase.deleteCategory();
    removeVariant();
  }

  void removeVariant() async {
    await dropDatabase.deleteVariant();
    removeVariantOption();
  }

  void removeVariantOption() async {
    await dropDatabase.deleteVariantOption();
    removeProduct();
  }

  void removeProduct() async {
    await dropDatabase.deleteProduct();
    removeProdcutVariantOption();
  }

  void removeProdcutVariantOption() async {
    await dropDatabase.deleteProdcutVariantOption();
    removeAllLogs();
  }

  /// Logs
  void removeAllLogs() async {
    await dropDatabase.deleteAllLogs();
    removeCategoryProduct();
  }

  void removeCategoryProduct() async {
    await dropDatabase.deleteCategoryProduct();
    removeVariantProduct();
  }

  void removeVariantProduct() async {
    await dropDatabase.deleteVariantProduct();
    removeShoppingCart();
  }

  void removeShoppingCart() async {
    await dropDatabase.deleteShoppingCart();
    removeShoppingCartProduct();
  }

  void removeShoppingCartProduct() async {
    await dropDatabase.deleteShoppingCartProduct();
    removeSession();
  }

  void removeSession() async {
    await dropDatabase.deleteSession();
    removeOrder();
  }

  void removeOrder() async {
    await dropDatabase.deleteOrder();
    removeProductLog();
  }

  ///ProductLog
  void removeProductLog() async {
    await dropDatabase.deleteProductLog();
    removeExpense();
  }

  void removeExpense() async {
    await dropDatabase.deleteExpense();
    removeSelectedProductVariant();
  }

  void removeSelectedProductVariant() async {
    await dropDatabase.deleteSelectedProductVariant();
    removeBarcode();
  }

  void removeBarcode() async {
    await dropDatabase.deleteBarcode();
    removeInvoice();
  }

  void removeInvoice() async {
    await dropDatabase.deleteInvoice();
    removeNotification();
  }

  // void removeCustomer() async {
  //   await dropDatabase.deleteCustomer();
  //   removeNotification();
  // }

  void removeNotification() async {
    await dropDatabase.deleteNotification();
    await Future.delayed(const Duration(seconds: 4)).then((onValue) {
      _showToastMessage(getTranslated(context, "other_drop_success"));
    });
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
}
