import 'package:flutter/material.dart';
import 'package:rakcha/common/theme/app_theme.dart';

import 'features/authentication/presentaion/screens/LoginScreen.dart';
import 'features/authentication/presentaion/screens/SignInScreen.dart';
import 'features/home/presentaion/screens/LobbyScreen.dart';

class MyApp extends StatefulWidget {
  final bool initroot;
  const MyApp({required this.initroot, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: widget.initroot ? '/lobby':'/login',
      routes: {
        '/lobby': (context) => const LobbyScreen(),
        '/login': (context) => const LoginScreen(),
        '/signIn': (context) => const SignInScreen()
      },
    );
  }

}

