import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/user_model.dart';
import 'package:pos/localization/localization_mixins.dart';

class AccountHome extends StatefulWidget {
  final userObject;

  AccountHome({this.userObject});
  @override
  _AccountHomeState createState() => _AccountHomeState();
}

class _AccountHomeState extends State<AccountHome> {
  final PosDatabase dbmanager = PosDatabase();
  UserModel userObject;
  @override
  void initState() {
    super.initState();
    setState(() {
      userObject = widget.userObject;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final businessController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final accessCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameController.text = userObject.name;
    phoneController.text = userObject.phone;
    businessController.text = userObject.business;
    addressController.text = userObject.address;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, 'account_appbar_title')),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.done, color: Colors.white),
              onPressed: () {
                updateUserInfo();
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: ListView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Card(
              elevation: 5,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  title: Text(
                    getTranslated(context, 'account_user_info'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {},
                  subtitle: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Text(
                          getTranslated(context, 'account_access_code'),
                          style: TextStyle(color: Colors.black),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: getTranslated(context, 'account_name_label')),
                            controller: nameController,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return getTranslated(context, 'account_name_required');
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: getTranslated(context, 'account_phone_label')),
                            keyboardType: TextInputType.number,
                            controller: phoneController,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return getTranslated(context, 'acount_phone_required');
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: getTranslated(context, 'account_access_code_label')),
                            controller: accessCodeController,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return getTranslated(context, 'account_access_code_required');
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: getTranslated(context, 'account_business_label')),
                            controller: businessController,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return getTranslated(context, 'account_business_required');
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: getTranslated(
                                    context, getTranslated(context, 'account_address_label'))),
                            controller: addressController,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return getTranslated(context, 'account_address_required');
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Card(
              elevation: 5,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  title: Text(
                    getTranslated(context, 'account_password_management'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {},
                  subtitle: Column(
                    children: <Widget>[
                      Text(
                        getTranslated(context, 'account_password_message'),
                        style: TextStyle(color: Colors.black),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: getTranslated(context, 'account_passwrod_label')),
                          controller: passwordController,
                          validator: (String value) {
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: getTranslated(context, 'account_new_pass_label')),
                          controller: newPasswordController,
                          validator: (String value) {
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: getTranslated(context, 'account_confirm_pass')),
                          controller: confirmPasswordController,
                          validator: (String value) {
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _displayFlutterToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void updateUserInfo() async {
    if (_formKey.currentState.validate()) {
      //
      if (newPasswordController.text == confirmPasswordController.text &&
          userObject.password == passwordController.text &&
          passwordController.text != "" &&
          newPasswordController.text != "" &&
          confirmPasswordController.text != "") {
        userObject.password = newPasswordController.text;
        print("new password assigned");
      }

      userObject.name = nameController.text;
      userObject.phone = phoneController.text;
      userObject.business = businessController.text;
      userObject.address = addressController.text;

      if (accessCodeController.text == userObject.access_code) {
        await dbmanager.updateUser(userObject).then((onValue) {
          _displayFlutterToastMessage(getTranslated(context, 'account_update_success'));
          nameController.clear();
          phoneController.clear();
          businessController.clear();
          addressController.clear();
          passwordController.clear();
          accessCodeController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
          Navigator.pop(context);
        });
      }
      //
    } else {
      _displayFlutterToastMessage(getTranslated(context, 'invalid_form'));
      // Navigator.pop(context);
    }
  }
}
