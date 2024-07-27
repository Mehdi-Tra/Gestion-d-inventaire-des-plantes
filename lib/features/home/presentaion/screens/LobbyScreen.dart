
import 'package:flutter/material.dart';
import 'package:rakcha/features/home/presentaion/screens/HomeScreen.dart';

import '../widgets/MyDrawer.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Widget _currentScreen;



  @override
  void initState() {
    super.initState();
    _currentScreen = Homescreen(
      scaffoldKey: _scaffoldKey,
      changeCurrentScreen: changeCurrentScreen,
    );
  }

  void changeCurrentScreen(Widget newScreen) {
    setState(() {
      _currentScreen = newScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          drawer: Mydrawer(
              scaffoldKey: _scaffoldKey,
              changeCurrentScreen: changeCurrentScreen),
          body: _currentScreen),
    );
  }
}
