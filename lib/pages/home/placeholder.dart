import 'package:flutter/material.dart';
import 'package:pos/localization/localization_mixins.dart';

class PlaceHolderContent extends StatelessWidget {
  final title;
  final message;

  PlaceHolderContent({
    this.title = "Nothing Here",
    this.message = "Add a new item to get started",
  });
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          getTranslated(context, "home_placeholder_title"),
          style: TextStyle(fontSize: 32.0, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        Text(
          getTranslated(context, "home_placeholder_content"),
          style: TextStyle(fontSize: 16.0, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    ));
  }
}
