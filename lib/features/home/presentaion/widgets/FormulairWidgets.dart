// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

Padding paddingSubTitle()=> Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16));


Widget titleWidget(context){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          IconButton(onPressed: (){
            Navigator.pushNamedAndRemoveUntil(context, "/lobby", (Route<dynamic> route) => false);
          }, icon: Icon(Icons.arrow_back_ios_new_outlined)),
          SizedBox(width: 12,),
          Text("Formulaire", style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }


