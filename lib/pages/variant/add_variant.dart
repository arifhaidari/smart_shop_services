import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/variant_model.dart';
import 'package:pos/db/variant_option_model.dart';
import 'package:pos/localization/localization_mixins.dart';

class AddVariant extends StatefulWidget {
  @override
  _AddVariantState createState() => _AddVariantState();
}

class _AddVariantState extends State<AddVariant> {
  var optionTextEditingControllers = <TextEditingController>[];

  List<VariantOption> variantOptionList = List();

  VariantOption vOptionName;

  int _option_flag = 1;

  final PosDatabase dbmanager = new PosDatabase();

  final _variantNameController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  final LogAcitvity logActivity = new LogAcitvity();
  bool log = false;

  @override
  void initState() {
    super.initState();
    logActivity.logActivation().then((value) {
      if (value != null) {
        log = value.log_activate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "variant_add")),
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
                              labelText:
                                  '${getTranslated(context, "variant_option")}-${index + 1}'),
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
      Variant st = new Variant(
        name: _variantNameController.text,
      );
      await dbmanager.insertVariant(st).then((id) {
        _insertVariantOption(id);
        if (log) {
          logActivity.recordLog(
              "${_variantNameController.text} ${getTranslated(context, 'category_added')}",
              'add_variant',
              id,
              "Variant",
              null);
        }
        _variantNameController.clear();
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

  void _insertVariantOption(int variantId) {
    for (var i = 0; i <= optionTextEditingControllers.length; i++) {
      try {
        variantOptionList[i].option_name = optionTextEditingControllers[i].text;
        variantOptionList[i].variant_id = variantId;

        dbmanager.insertVariantOption(variantOptionList[i]).then((id) => {});
      } catch (e) {
        // _showToastMessage(e.toString()); //every time it shows error
      }
    }
    setState(() {
      optionTextEditingControllers = [];
      variantOptionList = [];
      _option_flag = 1;
    });

    Navigator.of(context).pop();
  }

  void _showToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
