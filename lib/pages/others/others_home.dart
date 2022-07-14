import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/language_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/main.dart';
import 'package:pos/pages/others/database/database_home.dart';
import 'package:pos/pages/others/info/about_us.dart';
import 'package:pos/pages/others/info/contact_us.dart';
import 'package:pos/pages/others/logo.dart';
import 'package:pos/pages/others/qr_barcode/barcode_qr_home.dart';

class OhterHome extends StatefulWidget {
  @override
  _OhterHomeState createState() => _OhterHomeState();
}

class _OhterHomeState extends State<OhterHome> {
  @override
  void initState() {
    super.initState();
    currentSelectedLanguage();
    getUserInfo();
  }

  final PosDatabase dbmanager = new PosDatabase();

  String access_code;
  String phone;

  void getUserInfo() async {
    await dbmanager.getSingleUser().then((onValue) {
      setState(() {
        access_code = onValue.access_code;
        phone = onValue.phone;
      });
    });
  }

  String selectedLanguage = "English";
  String dari = "دری";
  String pashto = "پشتو";

  void currentSelectedLanguage() async {
    await dbmanager.getActiveLanguage().then((value) async {
      setState(() {
        if (value.language_code == 'en') {
          selectedLanguage = selectedLanguage;
        } else if (value.language_code == 'fa') {
          selectedLanguage = dari;
        } else {
          selectedLanguage = pashto;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "more_other")),
      ),
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
                  FontAwesomeIcons.qrcode,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "other_barcode_title"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ScannerQrHome()));
              },
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
                  FontAwesomeIcons.database,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "other_database"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                if (access_code != 'trial') {
                  if (phone != 'expired351focus') {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => DatabaesHome()));
                  } else {
                    _showToastMessage(getTranslated(context, 'other_contract_issue_message'));
                  }
                } else {
                  _showToastMessage(getTranslated(context, "other_trial_allowed"));
                }
              },
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
                  FontAwesomeIcons.info,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "other_about_us"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUs()));
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
                  FontAwesomeIcons.fileContract,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "other_contact"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUs()));
              },
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
                  Icons.picture_in_picture,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, 'other_logo'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Logo()));
              },
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
                  Icons.language,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
              title: Text(
                getTranslated(context, "other_language"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(selectedLanguage),
              // onTap: () {},
              trailing: DropdownButton(
                onChanged: (Language language) {
                  _changeLanguage(language);
                },
                underline: SizedBox(),
                items: Language.languageList()
                    .map<DropdownMenuItem<Language>>((lang) => DropdownMenuItem(
                          value: lang,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(
                                lang.flag,
                                style: TextStyle(fontSize: 22),
                              ),
                              Text(
                                lang.name,
                                style: TextStyle(fontSize: 22.0),
                              )
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeLanguage(Language language) async {
    Locale _temp = await setLocale(language.languageCode);

    MyApp.setLocale(context, _temp);
    // exit(0); // no need in iphone

    await dbmanager.getActiveLanguage().then((value) async {
      value.active = false;
      await dbmanager.updateLanguage(value);
    }).then((element) async {
      await dbmanager.getSigleLanguage(language.languageCode).then((value) async {
        value.active = true;
        await dbmanager.updateLanguage(value).then((value) {
          if (language.languageCode == 'en') {
            selectedLanguage = selectedLanguage;
          } else if (language.languageCode == 'fa') {
            selectedLanguage = dari;
          } else {
            selectedLanguage = pashto;
          }
        });
      });
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
