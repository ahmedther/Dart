import 'package:flutter/material.dart';
import '../customicons/custom_icons.dart';

class Func {
  static snackBar_func(text) {
    return SnackBar(
        content: Row(
      children: <Widget>[
        const Icon(CustomIcon1.attention, color: Colors.amber),
        SizedBox(
          width: 30,
        ),
        Expanded(child: Text(text)),
      ],
    ));
  }
}
