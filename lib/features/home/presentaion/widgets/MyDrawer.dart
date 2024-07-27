import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rakcha/features/home/presentaion/screens/ArchiveScreen.dart';
import 'package:rakcha/features/home/presentaion/screens/HistoryScreen.dart';
import 'package:rakcha/features/home/presentaion/screens/HomeScreen.dart';
import 'package:rakcha/features/home/presentaion/screens/ProfileScreen.dart';
import 'package:rakcha/features/home/presentaion/screens/statisticScreen.dart';

class Mydrawer extends StatefulWidget {
  final Function(Widget) changeCurrentScreen;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Mydrawer(
      {required this.scaffoldKey,
      required this.changeCurrentScreen,
      super.key});

  @override
  State<Mydrawer> createState() => _MydrawerState();
}

class _MydrawerState extends State<Mydrawer> {
  @override
  void initState() {
    super.initState();
    items = [
      {
        "label": "Profile",
        'icon': const Icon(Icons.account_circle_outlined),
        'navigat': ProfileScreen(scaffoldKey:widget.scaffoldKey,)
      },
      {
        "label": "Inventaire",
        'icon': const Icon(Icons.home_outlined),
        'navigat': Homescreen(
            changeCurrentScreen: widget.changeCurrentScreen,
            scaffoldKey: widget.scaffoldKey)
      },
      {
        "label": "Historique",
        'icon': const Icon(Icons.history_outlined),
        'navigat':  HistoryScreen(scaffoldKey:widget.scaffoldKey),
      },
      {
        "label": "Archive",
        'icon': const Icon(Icons.history_outlined),
        'navigat': ArchiveScreen(
            changeCurrentScreen: widget.changeCurrentScreen,
            scaffoldKey: widget.scaffoldKey)
      },
      {
        "label": "Statistiques",
        'icon': const Icon(Icons.pie_chart_outline_outlined),
        'navigat': StatisticScreen(scaffoldKey:widget.scaffoldKey,)
      },
      {"label": "Déconnecté", 'icon': const Icon(Icons.logout)},
    ];
  }

  final GlobalKey<DrawerControllerState> _drawerKey =
      GlobalKey<DrawerControllerState>();

  late List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      key: _drawerKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          accountSpace(context),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          listItem()
        ],
      ),
    );
  }

  Widget accountSpace(context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        padding: const EdgeInsets.only(top: 16),
        width: constraints.maxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                log('${_drawerKey.currentContext?.size?.width}');
              },
              icon: const Icon(Icons.account_circle),
            ),
            Text(
              "Admin",
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ],
        ),
      );
    });
  }

  Widget listItem() {
    return Column(
      children: List<ListTile>.generate(items.length, (int index) {
        return ListTile(
          iconColor: Theme.of(context).iconTheme.color,
          leading: items[index]["icon"],
          title: Text(
            items[index]["label"],
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onTap: () {
            log("Item $index");

            if (items[index]["label"] == "Déconnecté") {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/login", (Route<dynamic> route) => false);
            } else {
              widget.changeCurrentScreen(items[index]["navigat"]);
              Navigator.of(context).pop();
            }
          },
        );
      }),
    );
  }
}
