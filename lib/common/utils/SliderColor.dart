import 'package:flutter/material.dart';

Color getSliderColor(String value) {
    if (value == "Grand danger") {
      return Colors.red;
    } else if (value == "Mauvaise") {
      return Colors.yellow;
    } else if (value == "Moyenne") {
      return Colors.orange;
    } else if (value == "Bonne") {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }
  