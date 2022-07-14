import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/components/mixins.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/user_model.dart';
import 'package:pos/django_rest_api/api_response.dart';
import 'package:pos/django_rest_api/validation_service.dart';
import 'package:pos/fade_animation.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/home_page.dart';
import 'package:pos/pages/product/Utility.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _phoneController = TextEditingController();
  final _accessCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  final PosDatabase dbmanager = new PosDatabase();
  bool registerLoading = false;
  @override
  void initState() {
    super.initState();
    _getUserCredential();
  }

  bool existUser = false;

  File imageFile; //_selectedFile;

  bool _inProcess = false;

  String imgString = "no_logo";

  void _getUserCredential() async {
    await dbmanager.getSingleUser().then((onValue) {
      if (onValue == null) {
        setState(() {
          existUser = false;
        });
      } else {
        setState(() {
          existUser = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(builder: (context) {
        if (registerLoading) {
          return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 0.32 * screenHight,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('images/background.png'), fit: BoxFit.fill)),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 25,
                        width: 80,
                        height: 0.28 * screenHight,
                        child: FadeAnimation(
                            1,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(image: AssetImage('images/light-1.png'))),
                            )),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 0.12 * screenHight,
                        child: FadeAnimation(
                            1.3,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(image: AssetImage('images/light-2.png'))),
                            )),
                      ),
                      Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 0.12 * screenHight,
                        child: FadeAnimation(
                            1.5,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(image: AssetImage('images/ss_logo.png'))),
                            )),
                      ),
                      Positioned(
                        child: FadeAnimation(
                            1.6,
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Center(
                                child: Text(
                                  getTranslated(context, 'account_signup'),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
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
                          Form(
                            key: _formKey,
                            child: Container(
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
                              child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                          border:
                                              Border(bottom: BorderSide(color: Colors.grey[100]))),
                                      child: TextFormField(
                                        controller: _phoneController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText:
                                                getTranslated(context, 'main_phone_number_hint'),
                                            hintStyle: TextStyle(color: Colors.grey[400])),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                          border:
                                              Border(bottom: BorderSide(color: Colors.grey[100]))),
                                      child: TextFormField(
                                        controller: _accessCodeController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText:
                                                getTranslated(context, 'account_access_code_label'),
                                            hintStyle: TextStyle(color: Colors.grey[400])),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                          border:
                                              Border(bottom: BorderSide(color: Colors.grey[100]))),
                                      child: TextFormField(
                                        obscureText: true,
                                        controller: _passwordController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText:
                                                getTranslated(context, 'account_password_label'),
                                            hintStyle: TextStyle(color: Colors.grey[400])),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        obscureText: true,
                                        controller: _repeatPasswordController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText:
                                                getTranslated(context, 'account_confirm_pass'),
                                            hintStyle: TextStyle(color: Colors.grey[400])),
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.all(8.0),
                                        child: FlatButton(
                                          textColor: Colors.blue[900],
                                          child: Text(imgString == "no_logo"
                                              ? getTranslated(context, "account_no_logo")
                                              : getTranslated(context, "account_yes_logo")),
                                          onPressed: () {
                                            _showChoiceDialog(context);
                                          },
                                        ))
                                  ],
                                ),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 15,
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
                                  getTranslated(context, "main_register"),
                                  style:
                                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            onTap: () {
                              _regsiterUser();
                            },
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      FlatButton(
                        child: FadeAnimation(
                            1.5,
                            Text(
                              getTranslated(context, "main_login"),
                              style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
                            )),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  /////////////////////////

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(getTranslated(context, "product_media")),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Divider(
                      height: 10.0,
                      color: Colors.blue[900],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Text(getTranslated(context, "product_gallery")),
                        onTap: () {
                          getImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    Divider(
                      height: 10.0,
                      color: Colors.blue[900],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Text(getTranslated(context, "product_camera")),
                        onTap: () {
                          getImage(ImageSource.camera);
                        },
                      ),
                    ),
                    Divider(
                      height: 10.0,
                      color: Colors.blue[900],
                    ),
                  ],
                ),
              ));
        });
  }

  getImage(ImageSource source) async {
    setState(() {
      _inProcess = true;
    });
    File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 350,
          maxHeight: 350,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.blue[800],
            toolbarTitle: "Smart Cropper",
            statusBarColor: Colors.deepOrange.shade900,
            backgroundColor: Colors.white,
          ));

      setState(() {
        imageFile = cropped;
        imgString = Utility.base64String(cropped.readAsBytesSync());
        _inProcess = false;
      });
    } else {
      setState(() {
        _inProcess = false;
      });
    }
    Navigator.of(context).pop();
  }

  void _regsiterUser() {
    setState(() {
      registerLoading = true;
    });
    if (_formKey.currentState.validate() &&
        _phoneController.text != "" &&
        _accessCodeController.text != "" &&
        _passwordController.text != "" &&
        _repeatPasswordController.text != "" &&
        _passwordController.text == _repeatPasswordController.text) {
      final phone = _phoneController.text;
      final accessCode = _accessCodeController.text;
      final password = _passwordController.text;
      final repeatPassword = _repeatPasswordController.text;

      Map<String, dynamic> validationData = {
        "phone": phone,
        "password": password,
        "repeat_password": repeatPassword,
        "access_code": accessCode,
      };

      if (_accessCodeController.text != 'trial') {
        validateUserAuth(validationData);
      } else {
        saveTrial(validationData);
      }
    } else {
      setState(() {
        registerLoading = false;
      });
      _showToastMessage(getTranslated(context, "account_register_validate_message"));
    }
  }

  void saveTrial(Map<String, dynamic> credential) async {
    await dbmanager.getSingleUser().then((onValue) async {
      if (onValue == null) {
        UserModel userObject = UserModel(
          name: "Trial User",
          phone: credential['phone'],
          email: "example@abc.com",
          business: "Pharmacy",
          address: "Kabul, Afghanistan",
          password: credential['password'],
          logo: imgString,
          remember_me: true,
          access_code: credential['access_code'],
          start_contract_at: DateTime.now().toString(),
          end_contract_at: DateTime.now().add(new Duration(days: 7)).toString(),
        );

        await dbmanager.createUser(userObject).then((onValue) {
          setState(() {
            registerLoading = false;
          });
          _showToastMessage(getTranslated(context, "account_registration_success"));
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        setState(() {
          registerLoading = false;
        });
        _showToastMessage(getTranslated(context, 'account_already_registered'));
      }
    });
  }

  final ValidationService validationService = new ValidationService();
  APIResponse<UserModel> _apiValidateResponse;

  bool isLoading = false;

  void validateUserAuth(Map<String, dynamic> validationCredential) async {
    setState(() {
      isLoading = true;
    });

    _apiValidateResponse = await validationService
        .validatePosUser(validationCredential); //pass credential map from here

    if (_apiValidateResponse.data == null) {
      setState(() {
        registerLoading = false;
      });
      _showToastMessage(getTranslated(context, "internet_connection_error"));
    } else {
      setState(() {
        isLoading = false;
      });
      if (!_apiValidateResponse.error) {
        saveLocally(_apiValidateResponse.data);
      } else {
        setState(() {
          registerLoading = false;
        });
        if (_apiValidateResponse.data.name == "Your Contract Is Expired") {
          if (existUser) {
            UserModel userModel;
            await dbmanager.getSingleUser().then((onValue) async {
              if (onValue != null) {
                setState(() {
                  userModel = onValue;
                  userModel.phone = "expired351focus";
                  userModel.password = "expired351focus";
                });
                await dbmanager.updateUser(userModel).then((onValue) {
                  //
                });
              }
            });
          }
        }
        _showToastMessage("${_apiValidateResponse.data.name}");
      }
    }
  }

  void saveLocally(UserModel userModel) async {
    UserModel userUpdateModel;
    if (existUser) {
      await dbmanager.getSingleUser().then((onValue) {
        userUpdateModel = onValue;
      });

      if (userUpdateModel.phone != userModel.phone &&
          userUpdateModel.password != userModel.password &&
          userUpdateModel.phone != 'expired351focus' &&
          userUpdateModel.password != 'expired351focus') {
        _showToastMessage(getTranslated(context, "account_online_local"));
        //do you want to replace your account ... navigate from a dialogue box
        setState(() {
          registerLoading = false;
        });
        _replaceUserDialogue(context, userUpdateModel, userModel);
      } else {
        userUpdateModel.name = userModel.name;
        userUpdateModel.phone = userModel.phone;
        userUpdateModel.email = userModel.email;
        userUpdateModel.business = userModel.business;
        userUpdateModel.address = userModel.address;
        userUpdateModel.password = userModel.password;
        userUpdateModel.logo = imgString;
        userUpdateModel.access_code = userModel.access_code;
        userUpdateModel.start_contract_at = userModel.start_contract_at;
        userUpdateModel.end_contract_at = userModel.end_contract_at;
        await dbmanager.updateUser(userUpdateModel).then((onValue) {
          setState(() {
            registerLoading = false;
          });
          _showToastMessage(getTranslated(context, "account_renewed_contract"));
        });
        // navigate to home
        rememberMe();
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    } else {
      await dbmanager.createUser(userModel).then((onValue) {
        setState(() {
          registerLoading = false;
        });
        _showToastMessage(getTranslated(context, "account_registration_success"));
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  Future<void> _replaceUserDialogue(
      BuildContext context, UserModel localUser, UserModel onlineUser) async {
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    //
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, "account_replace_user"),
              style:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Text(getTranslated(context, "account_replace_user_content")),
                    TextFormField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: getTranslated(context, "account_phone_label"),
                          hintStyle: TextStyle(color: Colors.grey[400])),
                      controller: phoneController,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: getTranslated(context, "main_password"),
                          hintStyle: TextStyle(color: Colors.grey[400])),
                      controller: passwordController,
                    )
                  ],
                ),
              ),
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
                onPressed: () async {
                  if (formKey.currentState.validate()) {
                    if (phoneController.text == localUser.phone &&
                        passwordController.text == localUser.password) {
                      //upate user
                      setState(() {
                        localUser.name = onlineUser.name;
                        localUser.phone = onlineUser.phone;
                        localUser.email = onlineUser.email;
                        localUser.business = onlineUser.business;
                        localUser.password = onlineUser.password;
                        localUser.logo = imgString;
                        localUser.address = onlineUser.address;
                        localUser.access_code = onlineUser.access_code;
                        localUser.start_contract_at = onlineUser.start_contract_at;
                        localUser.end_contract_at = onlineUser.end_contract_at;
                      });
                      await dbmanager.updateUser(localUser).then((onValue) {
                        _showToastMessage(getTranslated(context, "account_replace_success"));
                      });

                      //navigate to login page
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    } else {
                      _showToastMessage(getTranslated(context, "account_credential_match"));

                      Navigator.of(context).pop();
                    }
                  } else {
                    _showToastMessage(getTranslated(context, "invalid_form"));

                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  void _showToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
