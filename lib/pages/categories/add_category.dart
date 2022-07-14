import 'package:flutter/material.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/category_model.dart';
import 'package:pos/localization/localization_mixins.dart';

class AddCategory extends StatefulWidget {
  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final PosDatabase dbmanager = new PosDatabase();

  final _nameController = TextEditingController();
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

  bool val1 = true;
  onSwitchedGeneralChanged1(bool newVal1) {
    setState(() {
      val1 = newVal1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "category_add")),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.done, color: Colors.white),
              onPressed: () {
                _submitCategory(context);
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
        child: Container(
          color: Colors.white,
          child: ListTile(
            title: Text(
              getTranslated(context, "category_information"),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {},
            subtitle: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration:
                          InputDecoration(labelText: getTranslated(context, "category_name")),
                      controller: _nameController,
                      // maxLength: 10,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return getTranslated(context, "category_name_required");
                        }

                        return null;
                      },
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Switch(
                          value: val1,
                          onChanged: (newVal1) {
                            onSwitchedGeneralChanged1(newVal1);
                          },
                        ),
                      ),
                      Text(
                        getTranslated(context, "category_include"),
                        style: TextStyle(color: Colors.indigo, fontSize: 15.0),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitCategory(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      Category st = new Category(name: _nameController.text, include_in_drawer: val1);
      await dbmanager.insertCategory(st).then((id) {
        if (log) {
          logActivity.recordLog("${st.name} ${getTranslated(context, 'category_added')}",
              'add_category', id, "Category", null);
        }
        _nameController.clear();
      });

      Navigator.of(context).pop();
    }
  }
}
