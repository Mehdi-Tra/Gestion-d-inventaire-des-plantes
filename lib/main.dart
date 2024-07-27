import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rakcha/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  bool? initRoot = await getInitRoot();

  if (initRoot == null) {
    runApp(DevicePreview(
      enabled: true,
      tools: const [
        ...DevicePreview.defaultTools,
      ],
      builder: (context) => const MyApp(initroot: false),
    ));
  } else {
    if (initRoot == false) {
      runApp(DevicePreview(
        enabled: true,
        tools: const [
          ...DevicePreview.defaultTools,
        ],
        builder: (context) => const MyApp(initroot: false),
      ));
    } else {
      runApp(DevicePreview(
        enabled: true,
        tools: const [
          ...DevicePreview.defaultTools,
        ],
        builder: (context) => const MyApp(initroot: true),
      ));
    }
  }
}

Future<bool?> getInitRoot() async {
  SharedPreferences _sharedPref = await SharedPreferences.getInstance();

  return _sharedPref.getBool("remember");
}
