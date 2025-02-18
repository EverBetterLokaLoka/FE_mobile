import 'package:flutter/material.dart';

class ItineraryAppBar extends AppBar {
  ItineraryAppBar({
    Key? key,
    required String titleText,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    bool centerTitle = true,
    Color backgroundColor = Colors.white,
  }) : super(
    key: key,
    title: Text(
      titleText,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Colors.black,
      ),
    ),
    actions: actions,
    bottom: bottom,
    centerTitle: centerTitle,
    backgroundColor: backgroundColor,
    elevation: 4.0,
  );
}