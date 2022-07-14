import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/components/mixins.dart';
import 'package:pos/db/authentication_model.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/user_model.dart';
import 'package:pos/django_rest_api/api_response.dart';
import 'package:pos/django_rest_api/authentication_service.dart';
import 'package:pos/django_rest_api/import_export/backup_database.dart';
import 'package:pos/localization/localization_mixins.dart';

class BackupTab extends StatefulWidget {
  @override
  _BackupTabState createState() => _BackupTabState();
}

class _BackupTabState extends State<BackupTab> {
  final PosDatabase dbmanager = new PosDatabase();
  final LogAcitvity logActivity = new LogAcitvity();
  final AuthenticationService userService = new AuthenticationService();
  APIResponse<UserAuthentication> _apiAuthResponse;
  // APIResponse<List<PosBackupModel>> _apiPosResponse;

  String myUsername;
  bool isBackingUp = false;
  int waitSeconds = 65;
  bool backupErrors = false;
  List<String> backErrorList = List();

  @override
  void initState() {
    super.initState();
    userValidation();
  }

  void userValidation() async {
    await dbmanager.getSingleUser().then((onValue) {
      if (onValue != null) {
        setState(() {
          myUsername = onValue.phone;
        });
      }
    });
  }

  bool posLoading = false;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (isBackingUp) {
        return Container(
            child: Center(
                child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              getTranslated(context, "other_please_wait"),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue[900]),
            ),
            Text(
              "${getTranslated(context, 'other_left_seconds')}: $waitSeconds",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue[900]),
            ),
          ],
        )));
      }
      if (backupErrors) {
        return Container(
            child: Center(
                child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: backErrorList.length,
                  itemBuilder: (context, index) {
                    return Text(
                      backErrorList[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.green[900], fontWeight: FontWeight.bold, fontSize: 16),
                    );
                  }),
              SizedBox(
                height: 20,
              ),
              FlatButton.icon(
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blue, width: 1, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(8),
                icon: Icon(
                  Icons.done,
                  size: 25,
                ),
                label: Text(
                  getTranslated(context, 'other_got_it'),
                  style: TextStyle(fontSize: 25),
                ),
                onPressed: () {
                  setState(() {
                    backupErrors = false;
                  });
                },
                // onPressed: () => _backupDatabaseDialogue(context),
                // child: Text("Backup"),
                color: Colors.blue[900],
                textColor: Colors.white,
              )
            ],
          ),
        )));
      }

      return Container(
          color: Colors.grey[150],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  getTranslated(context, "other_backup_press"),
                  style: TextStyle(
                      color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 24.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton.icon(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blue, width: 1, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(8),
                  icon: Icon(
                    Icons.important_devices,
                    size: 25,
                  ),
                  label: Text(
                    getTranslated(context, "other_backup"),
                    style: TextStyle(fontSize: 25),
                  ),
                  onPressed: () {
                    if (myUsername == "expired351focus") {
                      _showToastMessage(getTranslated(context, "cart_expiration_message"));
                    } else {
                      userLoginAuth();
                    }
                  },
                  // onPressed: () => _backupDatabaseDialogue(context),
                  // child: Text("Backup"),
                  color: Colors.blue[900],
                  textColor: Colors.white,
                )
              ],
            ),
          ));
    });
  }

  /////////// Authentication starts //////////////////

  bool isLoading = false;

  String token;

  void userLoginAuth() async {
    setState(() {
      isLoading = true;
    });

    _apiAuthResponse = await userService.userLogin();

    if (_apiAuthResponse.data == null) {
      _showToastMessage(getTranslated(context, "internet_connection_error"));
    } else {
      setState(() {
        isLoading = false;
      });
      if (int.parse(_apiAuthResponse.data.status) == 200) {
        setState(() {
          token = _apiAuthResponse.data.token;
        });
        _backupDatabaseDialogue(context);
      } else {
        if (_apiAuthResponse.data.token == "Your Contract Is Expired") {
          UserModel userModel;
          await dbmanager.getSingleUser().then((onValue) async {
            if (onValue != null) {
              if (onValue.phone == "expired351focus") {
                //do nothing
              } else {
                setState(() {
                  userModel = onValue;
                  userModel.phone = "expired351focus";
                  userModel.password = "expired351focus";
                });
                await dbmanager.updateUser(userModel).then((onValue) {});
              }
            }
          });
        }
        _showToastMessage(
            "${_apiAuthResponse.data.token}, status: ${_apiAuthResponse.data.status}");
      }
    }
  }
  ////////////////// Authentcation ends ////////////////

  /////////// Backup  starts ////////////////

  Future<void> _backupDatabaseDialogue(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, "other_backup_title"),
              style:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            elevation: 15,
            content: Text(
              getTranslated(context, "other_backup_content"),
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
                  getTranslated(context, "okay"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _sessionEnderStart();
                  setState(() {
                    isBackingUp = true;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  //################ create version

  final BackupDatabase backupDatabase = new BackupDatabase();

  final AuthenticationService authenticationService = new AuthenticationService();
  // APIResponse<PosBackupModel> apiPosBackup;
  //######################

  // create a count down along with please wait to show
  //when it is going to wait ...

  void _backupCategory() async {
    await backupDatabase.postOnCategory(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 5)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 3; //60
          });
          _backupProduct();
        });
      }
    });
  }

  void _backupProduct() async {
    await backupDatabase.postOnProduct(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 5)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 5; //55
          });
          _backupVariant();
        });
      }
    });
  }

  void _backupVariant() async {
    await backupDatabase.postOnVariant(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 3)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 3; //52
          });
          _backupSession();
        });
      }
    });
  }

  void _backupSession() async {
    await backupDatabase.postOnSession(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 3)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 3; //49
          });
          _backupShoppingCart();
        });
      }
    });
  }

  //the next portion has dependency on previous tables primary keys

  void _backupShoppingCart() async {
    await backupDatabase.postOnShoppingCart(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 5)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 5; //44
          });
          _backupBarcode();
        });
      }
    });
  }

  void _backupBarcode() async {
    await backupDatabase.postOnBarcode(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 3)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 3; //41
          });
          _backupAllLogs();
        });
      }
    });
  }

  /////// Logs
  void _backupAllLogs() async {
    await backupDatabase.postOnLogs(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 3)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 3; //38
          });
          _backupExpense();
        });
      }
    });
  }

  void _backupExpense() async {
    await backupDatabase.postOnExpense(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 3)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 3; //35
          });
          _backupCategoryProduct();
        });
      }
    });
  }

  void _backupCategoryProduct() async {
    await backupDatabase.postOnCategoryProduct(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 3)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 3; //32
          });
          _backupVariantOption();
        });
      }
    });
  }

  void _backupVariantOption() async {
    await backupDatabase.postOnVariantOption(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 3)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 3; //29
          });
          _backupOrder();
        });
      }
    });
  }

  void _backupOrder() async {
    await backupDatabase.postOnOrder(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 5)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 5; //24
          });
          _backupVariantProduct();
        });
      }
    });
  }

  void _backupVariantProduct() async {
    await backupDatabase.postOnVariantProduct(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 3)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 3; //21
          });
          _backupShoppingCartProduct();
        });
      }
    });
  }

  void _backupShoppingCartProduct() async {
    await backupDatabase.postOnShoppingCartProduct(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 5)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 5; //16
          });
          _backupProductLog();
        });
      }
    });
  }

  void _backupProductLog() async {
    await backupDatabase.postOnProductLog(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 3)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 3; //13
          });
          _backupProductVariantOption();
        });
      }
    });
  }

  void _backupProductVariantOption() async {
    await backupDatabase.postOnProductVariantOption(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 5)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 5; //8
          });
          _backupInvoice();
        });
      }
    });
  }

  void _backupInvoice() async {
    await backupDatabase.postOnInvoice(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 3)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 3; //5
          });
          _backupSelectedProductVariant();
        });
      }
    });
  }

  void _backupSelectedProductVariant() async {
    await backupDatabase.postOnSelectedProductVariant(token).then((onValue) async {
      if (onValue) {
        await Future.delayed(const Duration(seconds: 5)).then((onValue) {
          setState(() {
            waitSeconds = waitSeconds - 5; //0
          });
          _backupNotification();
        });
      }
    });
  }

  void _backupNotification() async {
    await backupDatabase.postOnNotification(token).then((onValue) {
      onValue.forEach((val) {});
      if (onValue.length != 0) {
        setState(() {
          backErrorList = onValue;
          isBackingUp = false;
          backupErrors = true;
          waitSeconds = 65;
        });
      } else {
        setState(() {
          isBackingUp = false;
          waitSeconds = 65;
        });
        _showToastMessage(getTranslated(context, "other_backup_success"));
      }
    });
    activateLogs();
  }

  ////////////////////// Backup ends //////////////////

  void activateLogs() async {
    logActivity.createLogActivation('active_backup');
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

  /////////////// Session Ender Goes Here ////////////////////

  void _sessionEnderStart() async {
    await dbmanager.getCurrentSession().then((sessionExist) async {
      if (sessionExist != null) {
        sessionEnder(sessionExist);
      }
      _backupCategory();
    });
  }
}
