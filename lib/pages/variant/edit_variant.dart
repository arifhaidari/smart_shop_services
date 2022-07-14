import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/variant_model.dart';
import 'package:pos/db/variant_option_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/variant/variant_list.dart';

class EditVariant extends StatefulWidget {
  final varObject;

  EditVariant({
    this.varObject,
  });

  @override
  _EditVariantState createState() => _EditVariantState();
}

class _EditVariantState extends State<EditVariant> {
  var optionTextEditingControllers = <TextEditingController>[];

  List<VariantOption> variantOptionList = List();

  VariantOption vOptionName;
  final LogAcitvity logActivity = new LogAcitvity();
  bool log = false;
  bool backup = false;

  @override
  void initState() {
    super.initState();
    logActivity.logActivation().then((value) {
      if (value != null) {
        log = value.log_activate;
        backup = value.backup_activation;
      }
    });
  }

  int _option_flag = 1;

  final PosDatabase dbmanager = new PosDatabase();

  final _variantNameController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _variantNameController.text = widget.varObject.name;
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => VariantList()));
            },
          ),
          elevation: 0.1,
          backgroundColor: Colors.blue[900],
          title: Text(getTranslated(context, "variant_edit")),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.done, color: Colors.white),
                onPressed: () {
                  _submitVariant(context);
                }),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(
                      getTranslated(context, "variant"),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {},
                    subtitle: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration:
                                InputDecoration(labelText: getTranslated(context, "variant_name")),
                            controller: _variantNameController,
                            // maxLength: 10,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return getTranslated(context, "variant_name_required");
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Colors.blueAccent,
                ),
                Container(
                  height: 50.0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        getTranslated(context, "variant_option"),
                        style: TextStyle(
                            color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.blueAccent,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _option_flag,
                    itemBuilder: (context, index) {
                      final _variantOptionController = TextEditingController();
                      VariantOption vo = VariantOption();

                      return Container(
                        color: Colors.white,
                        child: ListTile(
                          subtitle: TextFormField(
                            decoration: InputDecoration(
                                labelText: '${getTranslated(context, "variant_option")}-$index'),
                            controller: _variantOptionController,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return getTranslated(context, "variant_option_name_required");
                              } else {
                                optionTextEditingControllers.add(_variantOptionController);
                                variantOptionList.add(vo);
                              }

                              return null;
                            },
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                optionTextEditingControllers = [];
                                variantOptionList = [];
                                if (_option_flag > 1) {
                                  _option_flag--;
                                }
                              });
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red[800],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue[800],
          child: Icon(Icons.add),
          onPressed: addField,
        ),
      ),
    );
  }

  void addField() {
    setState(() {
      optionTextEditingControllers = [];
      variantOptionList = [];
      _option_flag++;
    });
  }

  void _submitVariant(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      Variant varObject = widget.varObject;
      String tempName = varObject.name;

      varObject.name = _variantNameController.text;

      await dbmanager.updateVariant(varObject).then((id) {
        if (log) {
          logActivity.recordLog(
              "$tempName ${getTranslated(context, 'category_is_added')} ${_variantNameController.text}",
              'edit_variant',
              varObject.id,
              "Variant",
              null);
        }
        if (backup) {
          logActivity.recordBackupHistory("Variant", varObject.id, 'Edit');
        }
        _variantNameController.clear();
      });

      await dbmanager.deleteVariantOption(varObject.id).then((value) {
        _insertVariantOption(varObject.id);
      });
    } else {
      setState(() {
        optionTextEditingControllers = [];
        variantOptionList = [];
        _option_flag = 1;
      });
      _showToastMessage(getTranslated(context, "invalid_form"));
    }
  }

  void _insertVariantOption(int variantId) async {
    for (var i = 0; i <= optionTextEditingControllers.length; i++) {
      try {
        variantOptionList[i].option_name = optionTextEditingControllers[i].text;
        variantOptionList[i].variant_id = variantId;

        await dbmanager.insertVariantOption(variantOptionList[i]).then((id) => {});
      } catch (e) {
        _showToastMessage(e.toString());
      }
    }
    setState(() {
      optionTextEditingControllers = [];
      variantOptionList = [];
      _option_flag = 1;
    });

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VariantList()));
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
