import 'package:flutter/material.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/main.dart';
import 'package:pos/pages/account/profile_page.dart';
import 'package:pos/pages/analytics/analytics_home.dart';
import 'package:pos/pages/categories/category_list.dart';
import 'package:pos/pages/expenses/expense_home.dart';
import 'package:pos/pages/notification/notificatoin_home.dart';
import 'package:pos/pages/others/log_view/log_home.dart';
import 'package:pos/pages/others/others_home.dart';
import 'package:pos/pages/product/product_list.dart';
import 'package:pos/pages/return/return_home.dart';
import 'package:pos/pages/session/session_list.dart';
import 'package:pos/pages/variant/variant_list.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MoreManageList extends StatefulWidget {
  @override
  _MoreManageListState createState() => _MoreManageListState();
}

class _MoreManageListState extends State<MoreManageList> {
  final PosDatabase dbmanager = PosDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: ListView(
        children: <Widget>[
          Card(
            color: Colors.white,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue[800],
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 28.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "analytics_expense"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseHome()));
              },
              // subtitle: Text("subs"),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue[800],
                child: Icon(
                  FontAwesomeIcons.businessTime,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "more_session"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SessionList()));
              },
              // subtitle: Text("subs"),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue[800],
                child: Icon(
                  FontAwesomeIcons.chartLine,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "more_analytics"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsHome()));
              },
              // subtitle: Text("subs"),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue[800],
                child: Icon(
                  Icons.assignment_return,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "more_return"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReturnHome()));
              },
              // subtitle: Text("subs"),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue[800],
                child: Icon(
                  Icons.notification_important,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "more_notification"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => NotificationHome()));
              },
              // subtitle: Text("subs"),
            ),
          ),
          Divider(
            color: Colors.blue[900],
          ),
          Card(
            color: Colors.white,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue[800],
                child: Icon(
                  FontAwesomeIcons.shopify,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "more_product"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductList()));
              },
              // subtitle: Text("subs"),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue[800],
                child: Icon(
                  Icons.category,
                  size: 28.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "more_categories"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryList()));
              },
              // subtitle: Text("subs"),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue[800],
                child: Icon(
                  Icons.branding_watermark,
                  size: 28.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "more_variant"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VariantList()));
              },
              // subtitle: Text("subs"),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue[800],
                child: Icon(
                  FontAwesomeIcons.solidObjectGroup,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "more_other"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OhterHome()));
              },
              // subtitle: Text("subs"),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue[800],
                child: Icon(
                  Icons.info,
                  size: 28.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "more_account_info"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              },
              // subtitle: Text("subs"),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue[800],
                child: Icon(
                  FontAwesomeIcons.penFancy,
                  size: 28.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, 'other_logs'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LogHome()));
              },
              // subtitle: Text("subs"),
            ),
          ),
          Divider(
            color: Colors.blue[900],
          ),
          Card(
            color: Colors.white,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.blue[800],
                child: Icon(
                  FontAwesomeIcons.signOutAlt,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "more_sign_out"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                await dbmanager.getSingleUser().then((onValue) async {
                  onValue.remember_me = false;
                  await dbmanager.updateUser(onValue).then((onValue) {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => NotificiationCreator()));
                  });
                });
              },
            ),
          ),
          // Card(
          //   color: Colors.white,
          //   elevation: 4.0,
          //   child: ListTile(
          //     leading: CircleAvatar(
          //       radius: 20.0,
          //       backgroundColor: Colors.blue[800],
          //       child: Icon(
          //         FontAwesomeIcons.signOutAlt,
          //         size: 25.0,
          //         color: Colors.white,
          //       ),
          //     ),
          //     title: Text(
          //       "Test",
          //       style: TextStyle(fontWeight: FontWeight.bold),
          //     ),
          //     onTap: () async {
          //       Navigator.push(
          //           context, MaterialPageRoute(builder: (context) => ReceiptPrintingChannel()));
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
