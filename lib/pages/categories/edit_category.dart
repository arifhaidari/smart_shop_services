import 'package:flutter/material.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/db/category_model.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/localization/localization_mixins.dart';

class EditCategory extends StatefulWidget {
  final catObject;
  final catList;
  final updateIndex;

  EditCategory({
    this.catObject,
    this.catList,
    this.updateIndex,
  });

  @override
  _EditCategoryState createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  final _nameController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  final PosDatabase dbmanager = new PosDatabase();
  final LogAcitvity logActivity = new LogAcitvity();
  bool log = false;
  bool backup = false;

  Category category;

  @override
  void initState() {
    super.initState();
    category = widget.catObject;
    logActivity.logActivation().then((value) {
      if (value != null) {
        log = value.log_activate;
        backup = value.backup_activation;
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
    _nameController.text = widget.catObject.name;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "category_edit")),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                //delete and navigate to the category list
                await dbmanager.deleteCategory(category.id).then((id) {
                  if (log) {
                    logActivity.recordLog(
                        "${category.name} ${getTranslated(context, 'category_deleted')}",
                        'delete_category',
                        category.id,
                        "Category",
                        null);
                  }
                  if (backup) {
                    logActivity.recordBackupHistory("Category", category.id, 'Delete');
                  }
                });
                setState(() {
                  widget.catList.removeAt(widget.updateIndex);
                });
                Navigator.of(context).pop();
              }),
          IconButton(
              icon: Icon(Icons.done, color: Colors.white),
              onPressed: () {
                _submitCategory(context);
                Navigator.of(context).pop();
                //save and navigate the category list
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

  void _submitCategory(BuildContext context) {
    if (_formKey.currentState.validate()) {
      if (widget.catObject != null) {
        if (log) {
          logActivity
              .recordLog(
                  "${widget.catObject.name} ${getTranslated(context, 'category_is_added')} ${_nameController.text}",
                  'edit_category',
                  widget.catObject.id,
                  'Category',
                  null)
              .then((value) {
            saveEditCategory();
          });
        } else {
          saveEditCategory();
        }
      }
    }
  }

  void saveEditCategory() async {
    category.name = _nameController.text;
    category.include_in_drawer = val1;

    await dbmanager.updateCategory(category);
    if (backup) {
      logActivity.recordBackupHistory("Category", category.id, 'Edit');
    }
  }
}
