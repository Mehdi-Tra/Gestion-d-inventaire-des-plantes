import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rakcha/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  bool? initRoot = await getInitRoot();

  if (initRoot == null) {
    runApp(
      MyApp(initroot: false),
    );
  } else {
    if (initRoot == false) {
      runApp(
        MyApp(initroot: false),
      );
    } else {
      runApp(
        MyApp(initroot: true),
      );
    }
  }
}

Future<bool?> getInitRoot() async {
  SharedPreferences _sharedPref = await SharedPreferences.getInstance();

  return _sharedPref.getBool("remember");
}
