import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    } else if (Platform.isIOS || Platform.isMacOS) {
      return ios;
    } else if (Platform.isAndroid) {
      return android;
    } else if (Platform.isWindows || Platform.isLinux) {
      return web; // Use web config for desktop platforms
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyBWgSk8-C0zG4wxf76Ju4CLBgLt7QULY54",
      authDomain: "cannabis-ff4bf.firebaseapp.com",
      projectId: "cannabis-ff4bf",
      storageBucket: "cannabis-ff4bf.appspot.com",
      messagingSenderId: "931676349713",
      appId: "1:931676349713:web:4e2d0df194eef8b79998b0",
      measurementId: "G-5125G7Q9ZP");

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyArLmqZ9pgOmbjMZ6O8LCzmKMn2h3M9_78',
    appId: '1:931676349713:android:881f4342a18c814b9998b0',
    messagingSenderId: '931676349713',
    projectId: 'cannabis-ff4bf',
    storageBucket: 'cannabis-ff4bf.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDTBG3RQcON3x4FtU7W-V2k_Vc-6u7Qhgw',
    appId: '1:931676349713:ios:fb22613e82bd91399998b0',
    messagingSenderId: '931676349713',
    projectId: 'cannabis-ff4bf',
    storageBucket: 'cannabis-ff4bf.appspot.com',
    //iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.rakcha',
  );
}
