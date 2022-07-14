import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/db/authentication_model.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//My Imports
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/user_model.dart';
import 'package:pos/django_rest_api/api_response.dart';
import 'package:pos/django_rest_api/authentication_service.dart';
import 'package:pos/django_rest_api/import_export/import_database.dart';
import 'package:pos/django_rest_api/import_export/import_messages.dart';
import 'package:pos/localization/localization_mixins.dart';

class ImportTab extends StatefulWidget {
  @override
  _ImportTabState createState() => _ImportTabState();
}

class _ImportTabState extends State<ImportTab> {
  final PosDatabase dbmanager = new PosDatabase();

  bool isLoading = false;

  final AuthenticationService userService = new AuthenticationService();
  APIResponse<UserAuthentication> _apiAuthResponse;

  String token = "";
  String myUsername;

  bool isImporting = false;
  int waitSeconds = 93;
  bool importErrors = false;
  List<String> importErrorList = List();

  @override
  void initState() {
    super.initState();
    userValidation();
    userLoginAuth();
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

  void userLoginAuth() async {
    setState(() {
      isLoading = true;
    });

    _apiAuthResponse = await userService.userLogin();

    if (_apiAuthResponse.data == null) {
      _showToastMessage(getTranslated(context, 'internet_connection_error'));
    } else {
      setState(() {
        isLoading = false;
      });
      if (int.parse(_apiAuthResponse.data.status) == 200) {
        setState(() {
          token = _apiAuthResponse.data.token;
        });
      } else {
        if (_apiAuthResponse.data.token == "Your Contract Is Expired") {
          UserModel userModel;
          await dbmanager.getSingleUser().then((onValue) async {
            if (onValue != null) {
              if (onValue.phone == "expired351focus") {
                //do noting
              } else {
                setState(() {
                  userModel = onValue;
                  userModel.phone = "expired351focus";
                  userModel.password = "expired351focus";
                });
                await dbmanager.updateUser(userModel).then((onValue) {
                  // do nothing
                });
              }
            }
          });
        }
        _showToastMessage(
            "${_apiAuthResponse.data.token}, status: ${_apiAuthResponse.data.status}");
      }
    }
  }

  // List<InvoiceModel> invoiceList = List();
  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    return Builder(
      builder: (context) {
        if (myUsername == "expired351focus") {
          return Container(
            child: Center(
              child: Text(
                getTranslated(context, "other_contract_over_message"),
                style: TextStyle(fontSize: 25.0, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          if (isLoading) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (isImporting) {
            return Container(
                child: Center(
                    child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  getTranslated(context, 'other_please_wait'),
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue[900]),
                ),
                Text(
                  "${getTranslated(context, 'other_left_seconds')}: $waitSeconds",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue[900]),
                ),
              ],
            )));
          }
          if (_apiAuthResponse.data == null) {
            return Container(
              child: Center(
                child: Text(
                  getTranslated(context, "internet_connection_error"),
                  style: TextStyle(fontSize: 25.0, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (_apiAuthResponse.error) {
            return Container(
              child: Center(
                child: Text(
                  _apiAuthResponse.data.token,
                  style: TextStyle(fontSize: 25.0, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        }
        if (importErrors) {
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
                    itemCount: importErrorList.length,
                    itemBuilder: (context, index) {
                      return Text(
                        importErrorList[index],
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
                      importErrors = false;
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
                    getTranslated(context, "other_import_command"),
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
                      Icons.import_contacts,
                      size: 25,
                    ),
                    label: Text(
                      getTranslated(context, 'other_import'),
                      style: TextStyle(fontSize: 25),
                    ),
                    onPressed: () async {
                      if (myUsername != "expired351focus") {
                        int shoppingListLenght = 0;
                        int sessionListLenght = 0;
                        if (_apiAuthResponse.data != null && !_apiAuthResponse.error) {
                          await dbmanager.getShoppingCartList().then((onValue) {
                            if (onValue.length != 0) {
                              setState(() {
                                shoppingListLenght = onValue.length;
                              });
                            }
                          });

                          await dbmanager.getAllSessionList().then((onValue) {
                            if (onValue.length != 0) {
                              setState(() {
                                sessionListLenght = onValue.length;
                              });
                            }
                          });

                          if (shoppingListLenght != 0 || sessionListLenght != 0) {
                            _showToastMessage(getTranslated(context, 'other_first_drop'));
                          } else {
                            _importDatabaseDialogue(context);
                          }
                        } else {
                          _showToastMessage(
                              getTranslated(context, 'other_connection_credential_error'));
                        }
                      } else {
                        _showToastMessage(getTranslated(context, 'other_contract_over_message'));
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
      },
    );
  }

  Future<void> _importDatabaseDialogue(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, 'other_import_title'),
              style:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Text(
              getTranslated(context, 'other_import_content'),
              style: TextStyle(color: Colors.green[900]),
            ),
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
                  getTranslated(context, 'other_import_start'),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _importCategory();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  /////////////###### Import Starts
  ///send the token and posbckup_id to the other file class
  List<String> messageList = List();
  final ImportDatabase importDatabase = new ImportDatabase();

  void _importCategory() async {
    setState(() {
      isImporting = true;
    });
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfCategory(token);

    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 5)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 8; //75
      });
      _importProduct();
    });
  }

  void _importProduct() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfProduct(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }

    await Future.delayed(const Duration(seconds: 10)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 7; //70
      });
      _importVariant();
    });
  }

  void _importVariant() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfVariant(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 5)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //65
      });
      _importSession();
    });
  }

  void _importSession() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfSession(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 7)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //60
      });
      _importShoppingCart();
    });
  }

  void _importShoppingCart() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfShoppingCart(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 10)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //50
      });
      _importBarcode();
    });
  }

  void _importBarcode() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfBarcodeModel(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 5)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //45
      });
      _importLogs();
    });
  }

  /// Logs
  void _importLogs() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfLogs(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 5)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //45
      });
      _importExpense();
    });
  }

  void _importExpense() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfExpense(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 5)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //40
      });
      _importCategoryProduct();
    });
  }

  void _importCategoryProduct() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfCategoryProductJoin(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 7)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //35
      });
      _importVariantOption();
    });
  }

  void _importVariantOption() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfVariantOption(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 7)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //30
      });
      _importOrder();
    });
  }

  void _importOrder() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfOrder(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 10)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //25
      });
      _importVariantProduct();
    });
  }

  void _importVariantProduct() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfVariantProductJoin(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 10)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //20
      });
      _importShoppingCartProduct();
    });
  }

  void _importShoppingCartProduct() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfShoppingCartProduct(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 10)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //15
      });
      _importProductLog();
    });
  }

  ///ProductLog
  void _importProductLog() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfProductLog(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 5)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //45
      });
      _importProductVariantOption();
    });
  }

  void _importProductVariantOption() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfProductVariantOption(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 10)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //10
      });
      _importInvoice();
    });
  }

  void _importInvoice() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfInvoiceModel(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 7)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 5; //5
      });
      _importSelectedProductVariant();
    });
  }

  void _importSelectedProductVariant() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfSelectedProductVariantModel(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    await Future.delayed(const Duration(seconds: 10)).then((onValue) {
      setState(() {
        waitSeconds = waitSeconds - 8; //0
      });
      _importNotification();
    });
  }

  void _importNotification() async {
    APIResponse<ImportMessages> _apiResponse;
    _apiResponse = await importDatabase.listOfNotificationModel(token);
    if (_apiResponse.error) {
      messageList.add(_apiResponse.errorMessage);
    }
    displayTheError(messageList);
  }

  void displayTheError(List<String> messages) async {
    if (messages.length != 0) {
      setState(() {
        importErrorList = messages;
        isImporting = false;
        importErrors = true;
        waitSeconds = 93;
      });
    } else {
      setState(() {
        isImporting = false;
        waitSeconds = 93;
      });
      _showToastMessage(getTranslated(context, 'other_import_success'));
    }
  }

///////////// Import ends

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
