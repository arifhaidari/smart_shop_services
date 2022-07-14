import 'package:flutter/material.dart';
import 'package:pos/pages/home/home_page.dart';

class DrawerComponents extends StatelessWidget {
  final categoryName;
  final categoryId;

  DrawerComponents({
    this.categoryName,
    this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.blue.shade400))),
      child: InkWell(
        splashColor: Colors.blue,
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        categoryId: categoryId.toString(),
                        categoryName: categoryName,
                        sentIndex: 0,
                      )));
        },
        //send the id of category from here to list all the categories related to that id
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
                      categoryName.toString(),
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
    );
  }
}
