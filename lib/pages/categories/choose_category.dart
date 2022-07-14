import 'package:flutter/material.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/category_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';

class ChooseCategory extends StatefulWidget {
  final categoryObjectList;

  const ChooseCategory({Key key, this.categoryObjectList}) : super(key: key);
  @override
  _ChooseCategoryState createState() => _ChooseCategoryState();
}

class _ChooseCategoryState extends State<ChooseCategory> {
  final PosDatabase dbmanager = new PosDatabase();

  List categoriesId = List();

  List<Category> categoryList = List();

  List<Category> selectedCategoryList = List();

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  Map<int, Category> categoryMap = Map();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryObjectList != null) {
      setState(() {
        isLoading = true;
      });
      selectedCategoryList = widget.categoryObjectList;
      selectedCategoryList.forEach((value) {
        categoriesId.add(value.id);
        categoryMap[value.id] = value;
      });
      setState(() {
        isLoading = false;
      });
    }
    refreshList();
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(milliseconds: 50));

    return null;
  }

  void myOnPressed(int id) {
    if (categoriesId.contains(id)) {
      categoriesId.remove(id);
      refreshList();
    } else {
      categoriesId.add(id);
      refreshList();
    }
  }

  void myOnPressedMap(Category categoryObject) {
    if (categoryMap == null) {
      categoryMap[categoryObject.id] = categoryObject;
    } else {
      if (categoryMap.containsKey(categoryObject.id)) {
        setState(() {
          categoryMap.remove(categoryObject.id);
        });
      } else {
        setState(() {
          categoryMap[categoryObject.id] = categoryObject;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          elevation: 0.1,
          backgroundColor: Colors.blue[900],
          title: Text(getTranslated(context, "category_selection")),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.done, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context, categoryMap);
                }),
          ],
        ),
        body: Builder(
          builder: (context) {
            if (isLoading) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return RefreshIndicator(
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
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Text(
                                          "${ct.name}",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      myOnPressed(ct.id);
                                      myOnPressedMap(ct);
                                    },
                                    trailing: categoriesId.contains(ct.id)
                                        ? Icon(
                                            Icons.done,
                                            color: Colors.blue[900],
                                          )
                                        : Icon(
                                            Icons.done,
                                            color: Colors.yellow[600],
                                          ),
                                  ),
                                ),
                              );
                            });
                      }
                      return Container(child: Center(child: new CircularProgressIndicator()));
                    },
                  )),
                ],
              ),
            );
          },
        ));
  }
}
