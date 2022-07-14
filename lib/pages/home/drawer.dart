import 'package:flutter/material.dart';
import 'package:pos/db/category_model.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/home_page.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/home/categories.dart';

class CategoryDrawer extends StatelessWidget {
  final PosDatabase dbmanager = new PosDatabase();

  List<Category> categoryList = List();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    // double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              height: screenHeight * 0.26,
              child: DrawerHeader(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: <Color>[Colors.blue[900], Colors.blue[900]])),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Material(
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.asset(
                            'images/categories.png',
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          getTranslated(context, "category"),
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.blue.shade400))),
                  child: InkWell(
                    splashColor: Colors.blue,
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(
                                    categoryId: "all_categories",
                                    sentIndex: 0,
                                  )));
                    }, //for all categories... list all categories from here
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.category,
                                color: Colors.blue[900],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  getTranslated(context, "home_drawer_all_categories"),
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: Colors.blue[900],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: screenHeight * 0.58,
                  child: FutureBuilder(
                    future: dbmanager.getCategoryDrawerList(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        categoryList = snapshot.data;
                        return ListView.builder(
                            itemCount: categoryList == null ? 0 : categoryList.length,
                            itemBuilder: (context, index) {
                              Category ct = categoryList[index];
                              if (categoryList.length != 0) {
                                return DrawerComponents(
                                  categoryName: ct.name,
                                  categoryId: ct.id,
                                );
                              } else {
                                return PlaceHolderContent();
                              }
                            });
                      }
                      return Container(child: Center(child: new CircularProgressIndicator()));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
