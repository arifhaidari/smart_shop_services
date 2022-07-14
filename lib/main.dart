import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/invoice_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/localization/pos_localization.dart';
import 'package:pos/pages/account/register_page.dart';
import 'package:pos/pages/home/home_page.dart';

import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pos/pages/notification/daily_report.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/notification_model.dart';
import 'fade_animation.dart';
import 'pages/notification/notificatoin_home.dart';
import 'components/mixins.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
AndroidInitializationSettings androidInitializationSettings;
IOSInitializationSettings iosInitializationSettings;
InitializationSettings initializationSettings;

void main() {
  runApp(MyApp());

  //////////
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  var currentLanguageLocale = Locale('en', 'US');

  @override
  void initState() {
    super.initState();
    getOrCreateLanguage();
  }

  void getOrCreateLanguage() async {
    await dbmanager.getLanguageList().then((value) async {
      if (value.length > 0) {
        await dbmanager.getActiveLanguage().then((value) {
          setState(() {
            currentLanguageLocale = Locale(value.language_code, value.country_code);
            _locale = Locale(value.language_code, value.country_code);
          });
        });
      } else {
        createLanguages();
      }
    });
  }

  @override
  void didChangeDependencies() {
    getOrCreateLanguage();
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    getLocale().then((locale) {
      setState(() {
        this._locale = locale == null ? currentLanguageLocale : locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Shop',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        locale: _locale,
        supportedLocales: [
          Locale('en', 'US'),
          Locale('fa', 'IR'),
          Locale('ps', 'AR'),
        ],
        localizationsDelegates: [
          PosLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          if (deviceLocale == null) {
            // return supportedLocales.toList()[1];
            return supportedLocales.first;
          } else {
            for (var locale in supportedLocales) {
              if (locale.languageCode == deviceLocale.languageCode &&
                  locale.countryCode == deviceLocale.countryCode) {
                return deviceLocale; // edit now
                // return deviceLocale;
              }
            }
            return supportedLocales.first; // change this to last
          }
        },
        home: NotificiationCreator(),
      );
    }
  }
}

class NotificiationCreator extends StatefulWidget {
  @override
  _NotificiationCreatorState createState() => _NotificiationCreatorState();
}

class _NotificiationCreatorState extends State<NotificiationCreator> {
  final PosDatabase dbmanger = new PosDatabase();

  String username = "";
  String password = "";
  String access_code = "";
  bool is_logged_in = true;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initializingNotification();
    _getCurrentSession();
    _getUserCredential();
  }

  void _getUserCredential() async {
    await dbmanger.getSingleUser().then((onValue) {
      if (onValue == null) {
        _showToastMessage(getTranslated(context, 'main_ask_register'));
      } else {
        setState(() {
          username = onValue.phone;
          password = onValue.password;
          access_code = onValue.access_code;
          is_logged_in = onValue.remember_me;
        });

        navigateByRememberMe();
      }
    });
  }

  void navigateByRememberMe() {
    if (is_logged_in) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 0.40 * screenHight,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('images/background.png'), fit: BoxFit.fill)),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 30,
                          width: 80,
                          height: 0.30 * screenHight,
                          child: FadeAnimation(
                              1,
                              Container(
                                decoration: BoxDecoration(
                                    image:
                                        DecorationImage(image: AssetImage('images/light-1.png'))),
                              )),
                        ),
                        Positioned(
                          left: 140,
                          width: 80,
                          height: 0.20 * screenHight,
                          child: FadeAnimation(
                              1.3,
                              Container(
                                decoration: BoxDecoration(
                                    image:
                                        DecorationImage(image: AssetImage('images/light-2.png'))),
                              )),
                        ),
                        Positioned(
                          right: 40,
                          top: 40,
                          width: 80,
                          height: 0.20 * screenHight,
                          child: FadeAnimation(
                              1.5,
                              Container(
                                decoration: BoxDecoration(
                                    image:
                                        DecorationImage(image: AssetImage('images/ss_logo.png'))),
                              )),
                        ),
                        Positioned(
                          child: FadeAnimation(
                              1.6,
                              Container(
                                margin: EdgeInsets.only(top: 50),
                                child: Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 50,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Column(
                      children: <Widget>[
                        FadeAnimation(
                            1.8,
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(143, 148, 251, .2),
                                        blurRadius: 20.0,
                                        offset: Offset(0, 10))
                                  ]),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                          border:
                                              Border(bottom: BorderSide(color: Colors.grey[100]))),
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: _usernameController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText:
                                                getTranslated(context, 'main_phone_number_hint'),
                                            hintStyle: TextStyle(color: Colors.grey[400])),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        obscureText: true,
                                        controller: _passwordController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: getTranslated(context, 'main_password'),
                                            hintStyle: TextStyle(color: Colors.grey[400])),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        FadeAnimation(
                            2,
                            ListTile(
                              title: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(colors: [
                                      Colors.blue[900],
                                      Colors.blue[700],
                                    ])),
                                child: Center(
                                  child: Text(
                                    getTranslated(context, 'main_login'),
                                    style:
                                        TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              onTap: () {
                                _logingConfirmation();
                              },
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FadeAnimation(
                                1.5,
                                Text(
                                  getTranslated(context, 'main_no_account'),
                                  style: TextStyle(color: Colors.black),
                                )),
                            FadeAnimation(
                              1.5,
                              FlatButton(
                                textColor: Colors.blue[800],
                                onPressed: () {
                                  Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => RegisterPage()))
                                      .then((onValue) {
                                    _getUserCredential();
                                  });
                                },
                                child: Text(
                                  getTranslated(context, 'main_register'),
                                  style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // FlatButton(
                        //   child: FadeAnimation(
                        //       1.5,
                        //       Text(
                        //         getTranslated(context, 'main_forget_password'),
                        //         style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
                        //       )),
                        //   onPressed: () {
                        //     // print("forget passwrod");
                        //   },
                        // )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  void initializingNotification() async {
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings =
        InitializationSettings(androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _requestIOSPermissions();
    // _showWeeklyAtDayAndTime();
    _showDailyAtTime();
    _showInvoiceNotification();
  }

  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future onSelectNotification(String payload) async {
    // make null payload somewhere
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
    // Navigator.of(context, rootNavigator: true).pop(); // it casue issue

    if (payload == "weekly") {
      // await Navigator.push(
      //     context,
      //     new MaterialPageRoute(
      //         builder: (context) => new WeeklyReport(timestamp: DateTime.now().toString())));
      // } else if (payload.substring(0, 5) == "daily") {
    } else if (payload[0] == "d") {
      await Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new DailyReport(
                    sessionId: payload.substring(6),
                  )));
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationHome()),
      );
    }
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(getTranslated(context, 'ok')),
                  onPressed: () async {
                    // Navigator.of(context, rootNavigator: true).pop();
                    if (payload == "weekly") {
                      // await Navigator.push(
                      //     context,
                      //     new MaterialPageRoute(
                      //         builder: (context) => new WeeklyReport(
                      //               timestamp: DateTime.now().toString(),
                      //             )));
                    } else if (payload[0] == "d") {
                      await Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new DailyReport(
                                    sessionId: payload.substring(6),
                                  )));
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationHome()),
                      );
                    }
                  },
                )
              ],
            ));
  }

  String currentSessionId;

  void _getCurrentSession() async {
    await dbmanger.getCurrentSession().then((onValue) {
      if (onValue == null) {
        currentSessionId = "0";
      } else {
        setState(() {
          currentSessionId = onValue.id.toString();
        });
      }
    });
  }

  Future<void> _showDailyAtTime() async {
    String myPayLoad = "daily-" + "$currentSessionId";
    var time = Time(20, 30, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'daily_channel_id', 'daily_channel_name', 'daily_channel_description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'Session Report',
        // getTranslated(context, 'main_daily_note_title'),
        'Session details are available, click to see today sale',
        // getTranslated(context, 'main_daily_note_detail'),
        time,
        platformChannelSpecifics,
        payload: myPayLoad);
  }

  Future<void> _showInvoiceNotification() async {
    var now = DateTime.parse(DateTime.now().toString().substring(0, 10));

    List<InvoiceModel> tempListOnce = new List();
    await dbmanger.getInvoiceList().then((onValue) async {
      setState(() {
        tempListOnce = onValue;
      });
    });
    tempListOnce.forEach((invoiceValue) async {
      var due = DateTime.parse(invoiceValue.invoice_due_date);
      int leftDueDay = due.difference(now).inDays;
      if (leftDueDay == 1) {
        await dbmanager
            .getSingleNotificationByType(invoiceValue.id.toString(), 'invoice')
            .then((onValue) async {
          if (onValue == null) {
            NotificationModel noteObject = new NotificationModel(
                subject:
                    "$leftDueDay day is left for ${invoiceValue.customer_name}'s invoice due date",
                timestamp: DateTime.now().toString(),
                detail_id: invoiceValue.id.toString(),
                note_type: "invoice",
                seen_status: false);
            await dbmanager.createNotification(noteObject).then((onValue) {});
            /////////
            var androidPlatformChannelSpecifics = AndroidNotificationDetails(
              'invoice_due_id',
              'invoice_due_name',
              'invoice_due_description',
              importance: Importance.Max,
              priority: Priority.High,
              ticker: 'ticker',
              color: Colors.blue[900],
            );
            var iOSPlatformChannelSpecifics = IOSNotificationDetails();
            var platformChannelSpecifics =
                NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
            await flutterLocalNotificationsPlugin.show(
                0,
                "$leftDueDay day is left to pay",
                // "$leftDueDay ${getTranslated(context, 'main_left_day')}",
                '${invoiceValue.customer_name} due date is about to over',
                // '${invoiceValue.customer_name} ${getTranslated(context, "main_due_over")}',
                platformChannelSpecifics,
                payload: "");
          }
        });
      }
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

  void _logingConfirmation() {
    if (_formKey.currentState.validate()) {
      if (_usernameController.text == username &&
          _passwordController.text == password &&
          username != "" &&
          password != "") {
        rememberMe();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else if (username == "expired351focus" &&
          password == "expired351focus" &&
          access_code == "trial") {
        _showToastMessage(getTranslated(context, "main_trial_over"));
      } else {
        _showToastMessage(getTranslated(context, 'main_credential_error'));
      }
    }
  }
}
