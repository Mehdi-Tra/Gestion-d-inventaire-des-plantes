import 'package:flutter/material.dart';

FilledButton submitButton(action, String text) {
  return FilledButton(
      style: ButtonStyle(
        fixedSize:
            WidgetStateProperty.all<Size>(const Size(double.maxFinite, 49)),
      ),
      onPressed: action,
      child: Text(text, style: const TextStyle(color: Color.fromARGB(255, 0, 21, 24)),));
}