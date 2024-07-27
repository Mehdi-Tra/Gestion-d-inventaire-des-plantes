import 'package:flutter/material.dart';

class Myappbar extends StatelessWidget {

  final GlobalKey<ScaffoldState> scaffoldKey;

  final String title;

  const Myappbar({required this.scaffoldKey, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          IconButton(
            onPressed: () {
              if (scaffoldKey.currentState!.isDrawerOpen) {
                scaffoldKey.currentState!.openEndDrawer();
              } else {
                scaffoldKey.currentState!.openDrawer();
              }
            },
            icon: Icon(
              Icons.account_circle_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Center(
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge)),
          )
        ],
      ),
    );
  }
}
