import 'package:flutter/material.dart';
import 'package:pos/localization/localization_mixins.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "other_contact_us")),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            elevation: 5,
            child: Container(
              margin: EdgeInsets.all(5),
              color: Colors.white,
              child: ListTile(
                title: Text(
                  getTranslated(context, "other_contact_us"),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22, color: Colors.green[900]),
                  textAlign: TextAlign.center,
                ),
                // subtitle: Text("subs"),
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: Container(
              margin: EdgeInsets.all(20),
              color: Colors.white,
              child: ListTile(
                  title: Text(
                      '${getTranslated(context, "account_phone_label")}: +93728333663 \n${getTranslated(context, "other_contact_email")}: info@smartshop.services',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900]))),
            ),
          ),
          Card(
            elevation: 5,
            child: Container(
              margin: EdgeInsets.all(5),
              color: Colors.white,
              child: ListTile(
                title: Text(
                  getTranslated(context, "account_address_label"),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22, color: Colors.green[900]),
                  textAlign: TextAlign.center,
                ),
                // subtitle: Text("subs"),
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: Container(
              margin: EdgeInsets.all(20),
              color: Colors.white,
              child: ListTile(
                  title: Text(getTranslated(context, "other_contact_address"),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900]))),
            ),
          ),
          Card(
            elevation: 5,
            child: Container(
              margin: EdgeInsets.all(5),
              color: Colors.white,
              child: ListTile(
                title: Text(
                  getTranslated(context, "other_more_info_title"),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22, color: Colors.green[900]),
                  textAlign: TextAlign.center,
                ),
                // subtitle: Text("subs"),
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: Container(
              margin: EdgeInsets.all(20),
              color: Colors.white,
              child: ListTile(
                  title: Text(
                      '${getTranslated(context, "other_more_info_content")}:\nhttps://smartshop.services \nhttp://fsh.af',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900]))),
            ),
          ),
        ],
      ),
    );
  }
}
