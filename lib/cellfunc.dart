import 'package:flutter/material.dart';

TableRow oneline(String text1, String text2, String text3) {
  return TableRow(
    children: [
      Container(
        height: 45,
        alignment: Alignment.center,
        child: Text(
          text1,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        height: 45,
        alignment: Alignment.center,
        child: Text(
          text2,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        height: 45,
        alignment: Alignment.center,
        child: Text(
          text3,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}
