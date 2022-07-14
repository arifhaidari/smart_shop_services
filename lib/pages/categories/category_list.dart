import 'package:flutter/material.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/categories/add_category.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/category_model.dart';
import 'package:pos/pages/categories/edit_category.dart';
import 'package:pos/pages/home/placeholder.dart';

// import 'dart:io';

class CategoryList extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final PosDatabase dbmanager = new PosDatabase();

  List<Category> categoryList = List();

  @override
  void initState() {
    super.initState();
    refreshList();
    // doTest();
  }

  void getDataList() async {
    await dbmanager.getCategoryList().then((value) {
      setState(() {
        categoryList = value;
      });
    });
  }

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(milliseconds: 100));

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "category")),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddCategory()))
                    .then((value) {
                  getDataList();
                });
              }),
        ],
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: Column(
          children: <Widget>[
            Expanded(
                child: FutureBuilder(
              future: dbmanager.getCategoryList(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  categoryList = snapshot.data;
                  if (categoryList.length == 0) {
                    return Container(
                      child: Center(child: PlaceHolderContent()),
                    );
                  }
                  return ListView.builder(
                      itemCount: categoryList == null ? 0 : categoryList.length,
                      itemBuilder: (context, index) {
                        Category ct = categoryList[index];
                        return Card(
                          elevation: 5.0,
                          child: ListTile(
                            title: Text(
                              "${ct.name}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditCategory(
                                            catObject: ct,
                                            catList: categoryList,
                                            updateIndex: index,
                                          ))).then((value) => refreshList());
                            },
                          ),
                        );
                      });
                }
                return Container(child: Center(child: new CircularProgressIndicator()));
              },
            )),
          ],
        ),
      ),
    );
  }

  void doTest() async {
    // print("insid the doTest");
  }

  // void _showToastMessage(String msg) {
  //   Fluttertoast.showToast(
  //       msg: msg,
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.TOP,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  // }
}
// 200919748170
