import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/user_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/account/CustomTextStyle.dart';
import 'package:pos/pages/account/account_home.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PosDatabase dbmanager = new PosDatabase();

  UserModel userObject;
  String userName;
  String userPhone;
  String userBusiness;
  String userAddress;
  String userStart;
  String userEnd;

  void getUserObject() async {
    await dbmanager.getSingleUser().then((onValue) {
      if (onValue == null) {
        _showToastMessage(getTranslated(context, 'account_register_error'));
      } else {
        setState(() {
          userObject = onValue;
          userName = userObject.name;
          userPhone = userObject.phone;
          userBusiness = userObject.business;
          userAddress = userObject.address;
          userStart = userObject.start_contract_at;
          userEnd = userObject.end_contract_at;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUserObject();
  }

  String url = "https://smartshop.services/";

  @override
  Widget build(BuildContext context) {
    final hieght = MediaQuery.of(context).size.height;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, 'account_profile_page_bar_title')),
      ),
      backgroundColor: Colors.grey.shade200,
      resizeToAvoidBottomPadding: true,
      body: Builder(builder: (context) {
        return Container(
          child: Stack(
            children: <Widget>[
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      ),
                      top: -40,
                      left: -40,
                    ),
                    Positioned(
                      child: Container(
                        width: 300,
                        height: 260,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                      ),
                      top: -40,
                      left: -40,
                    ),
                    Positioned(
                      child: Align(
                        child: Container(
                          width: 400,
                          height: 260,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                        ),
                      ),
                      top: -40,
                      left: -40,
                    ),
                  ],
                ),
              ),
              Container(
                child: Text(
                  "",
                  style:
                      CustomTextStyle.textFormFieldBold.copyWith(color: Colors.white, fontSize: 24),
                ),
                margin: EdgeInsets.only(top: 72, left: 24),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Container(),
                    flex: 20,
                  ),
                  Expanded(
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            child: Card(
                              margin: EdgeInsets.only(top: 50, left: 16, right: 16),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(16))),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(FontAwesomeIcons.link),
                                            iconSize: 24,
                                            color: Colors.black,
                                            onPressed: () {
                                              _showServerProfile(context);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(FontAwesomeIcons.edit),
                                            color: Colors.black,
                                            iconSize: 24,
                                            onPressed: () {
                                              // _showEditDialogue(context);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      userName.toString(),
                                      style: CustomTextStyle.textFormFieldBlack.copyWith(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    Text(
                                      userBusiness.toString(),
                                      style: CustomTextStyle.textFormFieldMedium
                                          .copyWith(color: Colors.grey.shade700, fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Container(
                                      height: 2,
                                      width: double.infinity,
                                      color: Colors.grey.shade200,
                                    ),
                                    ListView(
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        ListTile(
                                          leading: CircleAvatar(
                                            radius: 20.0,
                                            backgroundColor: Colors.blue[800],
                                            child: Icon(
                                              FontAwesomeIcons.calendar,
                                              size: 25.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                          title: Text(
                                            getTranslated(context, 'account_start_contract'),
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(userStart.toString()),
                                        ),
                                        ListTile(
                                          leading: CircleAvatar(
                                            radius: 20.0,
                                            backgroundColor: Colors.blue[800],
                                            child: Icon(
                                              FontAwesomeIcons.calendarWeek,
                                              size: 25.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                          title: Text(
                                            getTranslated(context, 'account_end_contract'),
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(userEnd.toString()),
                                        ),
                                        ListTile(
                                          leading: CircleAvatar(
                                            radius: 20.0,
                                            backgroundColor: Colors.blue[800],
                                            child: Icon(
                                              FontAwesomeIcons.phone,
                                              size: 25.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                          title: Text(
                                            getTranslated(context, 'account_profile_phone'),
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(userPhone.toString() != "expired351focus"
                                              ? userPhone.toString()
                                              : "Unknown"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Material(
                              borderRadius: BorderRadius.all(Radius.circular(50.0)),
                              elevation: 10,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.person,
                                  size: 80.0,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    flex: 85,
                    // flex: 75,
                  ),
                  Expanded(
                    child: Container(),
                    flex: 05,
                  )
                ],
              )
            ],
          ),
        );
      }),
    );
  }

  Future<void> _showEditDialogue(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated(context, 'account_edit_dialogue')),
            elevation: 10,
            content: Text(getTranslated(context, 'account_edit_content')),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, 'cancel'),
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
                  getTranslated(context, 'okay'),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => AccountHome(
                                userObject: userObject,
                              )));
                },
              ),
            ],
          );
        });
  }

  Future<void> _showServerProfile(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated(context, 'account_server_title')),
            elevation: 10,
            content: Text(getTranslated(context, 'account_server_content')),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, 'cancel'),
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
                  getTranslated(context, 'okay'),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (await canLaunch(url)) {
                    await launch(
                      url,
                      // forceSafariVC: false,
                      // forceWebView: false,
                      // headers: <String, String>{'my_header_key': 'my_header_value'},
                    );
                  } else {
                    throw 'Could not launch $url';
                  }

                  // _showToastMessage("No API has provided to navigate to web");
                },
              ),
            ],
          );
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
