import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RememberMe extends StatefulWidget {
  const RememberMe({super.key});

  @override
  State<RememberMe> createState() => _RememberMeState();
}

class _RememberMeState extends State<RememberMe> {
  bool checked = false;
  final Future<SharedPreferences> _preference = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () async {
              
              SharedPreferences pref = await _preference;
              setState(() {
                checked = !checked;
                pref.setBool('remember', checked);
                log(pref.get("remember").toString());

              });
            },
            icon: Icon(
              checked ? Icons.check_box : Icons.check_box_outline_blank,
            )),
        Text('Remember Me', style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
