import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/MyColors.dart';

class AppTheme {
  // light mode
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
      primaryColor: MyColors.primeryColor,
      scaffoldBackgroundColor: MyColors.background,

      // search bare 
      // searchBarTheme: SearchBarThemeData(
        
      // ),


      // text theme

      textTheme: TextTheme(

        displayLarge: GoogleFonts.roboto(
          color:Colors.white
        ),

        displayMedium: GoogleFonts.roboto(
          color: Colors.white
        ),

        displaySmall: GoogleFonts.roboto(
          color: Colors.white
        ),


        titleLarge: GoogleFonts.roboto(
          color: MyColors.primeryColor
        ),

        titleMedium: GoogleFonts.roboto(
          color: MyColors.primeryColor
        ),

        titleSmall: GoogleFonts.roboto(
          color: MyColors.primeryColor
        ),


        headlineLarge: GoogleFonts.roboto(
          color: MyColors.background
        ),

        headlineMedium: GoogleFonts.roboto(
          color: MyColors.background
        ),

        headlineSmall: GoogleFonts.roboto(
          color: MyColors.background
        ),


        bodyLarge: GoogleFonts.roboto(
          color: Colors.white
        ),

        bodyMedium: GoogleFonts.roboto(
          color: Colors.white
        ),

        bodySmall: GoogleFonts.roboto(
          color: Colors.white
        ),

        labelLarge: GoogleFonts.roboto(
          color: MyColors.primeryColor
        ),

        labelMedium: GoogleFonts.roboto(
          color: MyColors.primeryColor
        ),

        labelSmall: GoogleFonts.roboto(
          color: MyColors.primeryColor
        ),



      ),

      // textTheme: TextTheme(
      //   // title
      //   titleLarge: GoogleFonts.roboto(
      //     fontSize: 32,
      //     fontWeight: FontWeight.w700,
      //     color: MyColors.primeryColor
      //   ),
      //   titleMedium: GoogleFonts.roboto(
      //     fontSize: 20,
      //     color: const Color.fromARGB(255, 163, 163, 163)
      //   ),

      //   headlineLarge: const TextStyle(
      //     fontSize: 22,
      //     color: Colors.black,
      //     fontWeight: FontWeight.w500
      //   ) ,

      //   //head
      //   headlineMedium: const TextStyle(
      //     fontSize: 20,
      //     color: Colors.white
      //   ),

      //   // body
      //   bodyLarge: GoogleFonts.roboto(
      //     fontWeight: FontWeight.w500,
      //     fontSize: 14,
      //     color: MyColors.primeryColor
      //   ),
      //   bodyMedium: GoogleFonts.roboto(
      //     fontSize: 14,
      //     color: Colors.white),
        
      // ),

      //Button filled
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            textStyle: WidgetStateProperty.all<TextStyle>(
              GoogleFonts.roboto(
                fontWeight: FontWeight.w900,
                fontSize: 25,
                color: MyColors.background,
              ),
            ),
            backgroundColor:
                WidgetStateProperty.all<Color>(MyColors.buttonBackground)),
      ),


      // field decoration
      inputDecorationTheme: InputDecorationTheme(
        
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: MyColors.textFieldBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: MyColors.textFieldFocusedBorder)),
          hintStyle: const TextStyle(color: MyColors.textFieldHint)
            
        ),

      // icon theme
          iconTheme:const IconThemeData(color: MyColors.primeryColor),
          
      // drawer
      drawerTheme:const DrawerThemeData(
        backgroundColor: MyColors.background
      ),

      // float Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        
        backgroundColor: Color.fromARGB(255, 255, 255, 255)
      ),

      // bottom appbar
      bottomAppBarTheme: const BottomAppBarTheme(
        color: MyColors.background
      ),

      // appbar
      appBarTheme: const AppBarTheme(
        backgroundColor: MyColors.background
      ),

      // drop down menu
      
      
  );

  // dark mode
  static final ThemeData darkTheme = ThemeData(primaryColor: Colors.grey);
}
