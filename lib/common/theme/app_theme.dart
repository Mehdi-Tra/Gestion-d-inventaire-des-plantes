// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../constants/MyColors.dart';

// class AppTheme {
//   // light mode
//   static final ThemeData darkTheme = ThemeData(
//     useMaterial3: true,
//       primaryColor: MyColors.primeryColor,
//       scaffoldBackgroundColor: MyColors.background,

//       // search bare 
//       // searchBarTheme: SearchBarThemeData(
        
//       // ),


//       // text theme

//       textTheme: TextTheme(

//         displayLarge: GoogleFonts.roboto(
//           color:Colors.white
//         ),

//         displayMedium: GoogleFonts.roboto(
//           color: Colors.white
//         ),

//         displaySmall: GoogleFonts.roboto(
//           color: Colors.white
//         ),


//         titleLarge: GoogleFonts.roboto(
//           color: MyColors.primeryColor
//         ),

//         titleMedium: GoogleFonts.roboto(
//           color: MyColors.primeryColor
//         ),

//         titleSmall: GoogleFonts.roboto(
//           color: MyColors.primeryColor
//         ),


//         headlineLarge: GoogleFonts.roboto(
//           color: MyColors.background
//         ),

//         headlineMedium: GoogleFonts.roboto(
//           color: MyColors.background
//         ),

//         headlineSmall: GoogleFonts.roboto(
//           color: MyColors.background
//         ),


//         bodyLarge: GoogleFonts.roboto(
//           color: Colors.white
//         ),

//         bodyMedium: GoogleFonts.roboto(
//           color: Colors.white
//         ),

//         bodySmall: GoogleFonts.roboto(
//           color: Colors.white
//         ),

//         labelLarge: GoogleFonts.roboto(
//           color: MyColors.primeryColor
//         ),

//         labelMedium: GoogleFonts.roboto(
//           color: MyColors.primeryColor
//         ),

//         labelSmall: GoogleFonts.roboto(
//           color: MyColors.primeryColor
//         ),



//       ),

//       // textTheme: TextTheme(
//       //   // title
//       //   titleLarge: GoogleFonts.roboto(
//       //     fontSize: 32,
//       //     fontWeight: FontWeight.w700,
//       //     color: MyColors.primeryColor
//       //   ),
//       //   titleMedium: GoogleFonts.roboto(
//       //     fontSize: 20,
//       //     color: const Color.fromARGB(255, 163, 163, 163)
//       //   ),

//       //   headlineLarge: const TextStyle(
//       //     fontSize: 22,
//       //     color: Colors.black,
//       //     fontWeight: FontWeight.w500
//       //   ) ,

//       //   //head
//       //   headlineMedium: const TextStyle(
//       //     fontSize: 20,
//       //     color: Colors.white
//       //   ),

//       //   // body
//       //   bodyLarge: GoogleFonts.roboto(
//       //     fontWeight: FontWeight.w500,
//       //     fontSize: 14,
//       //     color: MyColors.primeryColor
//       //   ),
//       //   bodyMedium: GoogleFonts.roboto(
//       //     fontSize: 14,
//       //     color: Colors.white),
        
//       // ),

//       //Button filled
//       filledButtonTheme: FilledButtonThemeData(
//         style: ButtonStyle(
//             shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//               RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//               ),
//             ),
//             textStyle: WidgetStateProperty.all<TextStyle>(
//               GoogleFonts.roboto(
//                 fontWeight: FontWeight.w900,
//                 fontSize: 25,
//                 color: MyColors.background,
//               ),
//             ),
//             backgroundColor:
//                 WidgetStateProperty.all<Color>(MyColors.buttonBackground)),
//       ),


//       // field decoration
//       inputDecorationTheme: InputDecorationTheme(
        
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: MyColors.textFieldBorder)),
//           focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide:
//                   const BorderSide(color: MyColors.textFieldFocusedBorder)),
//           hintStyle: const TextStyle(color: MyColors.textFieldHint)
            
//         ),

//       // icon theme
//           iconTheme:const IconThemeData(color: MyColors.primeryColor),
          
//       // drawer
//       drawerTheme:const DrawerThemeData(
//         backgroundColor: MyColors.background
//       ),

//       // float Action Button
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
        
//         backgroundColor: Color.fromARGB(255, 255, 255, 255)
//       ),

//       // bottom appbar
//       bottomAppBarTheme: const BottomAppBarTheme(
//         color: MyColors.background
//       ),

//       // appbar
//       appBarTheme: const AppBarTheme(
//         backgroundColor: MyColors.background
//       ),

//       // drop down menu
      
      
//   );

//   // dark mode
//   static final ThemeData lightTheme = ThemeData(primaryColor: Colors.grey);
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/MyColors.dart';

class AppTheme {
  // dark mode
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: MyColors.primeryColor,
    scaffoldBackgroundColor: MyColors.background,

    // search bar theme
    searchBarTheme: SearchBarThemeData(
      backgroundColor: MaterialStateProperty.all(MyColors.background),
      hintStyle: MaterialStateProperty.all(GoogleFonts.roboto(color: MyColors.textFieldHint)),
    ),

    // text theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(color: Colors.white),
      displayMedium: GoogleFonts.roboto(color: Colors.white),
      displaySmall: GoogleFonts.roboto(color: Colors.white),
      titleLarge: GoogleFonts.roboto(color: MyColors.primeryColor),
      titleMedium: GoogleFonts.roboto(color: MyColors.primeryColor),
      titleSmall: GoogleFonts.roboto(color: MyColors.primeryColor),
      headlineLarge: GoogleFonts.roboto(color: MyColors.background),
      headlineMedium: GoogleFonts.roboto(color: MyColors.background),
      headlineSmall: GoogleFonts.roboto(color: MyColors.background),
      bodyLarge: GoogleFonts.roboto(color: Colors.white),
      bodyMedium: GoogleFonts.roboto(color: Colors.white),
      bodySmall: GoogleFonts.roboto(color: Colors.white),
      labelLarge: GoogleFonts.roboto(color: MyColors.primeryColor),
      labelMedium: GoogleFonts.roboto(color: MyColors.primeryColor),
      labelSmall: GoogleFonts.roboto(color: MyColors.primeryColor),
    ),

    // Button filled
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          GoogleFonts.roboto(
            fontWeight: FontWeight.w900,
            fontSize: 25,
            color: MyColors.background,
          ),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(MyColors.buttonBackground),
      ),
    ),

    // field decoration
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: MyColors.textFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: MyColors.textFieldFocusedBorder),
      ),
      hintStyle: TextStyle(color: MyColors.textFieldHint),
    ),

    // icon theme
    iconTheme: IconThemeData(color: MyColors.primeryColor),

    // drawer
    drawerTheme: DrawerThemeData(
      backgroundColor: MyColors.background,
    ),

    // float Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
    ),

    // bottom appbar
    bottomAppBarTheme: BottomAppBarTheme(
      color: MyColors.background,
    ),

    // appbar
    appBarTheme: AppBarTheme(
      backgroundColor: MyColors.background,
    ),
  );

  // light mode
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: MyColors.lightPrimeryColor,
    scaffoldBackgroundColor: MyColors.lightBackground,

    // search bar theme
    searchBarTheme: SearchBarThemeData(
      backgroundColor: MaterialStateProperty.all(MyColors.lightBackground),
      hintStyle: MaterialStateProperty.all(GoogleFonts.roboto(color: MyColors.lightTextFieldHint)),
    ),

    // text theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(color: MyColors.lightPrimeryColor),
      displayMedium: GoogleFonts.roboto(color: MyColors.lightPrimeryColor),
      displaySmall: GoogleFonts.roboto(color: MyColors.lightPrimeryColor),
      titleLarge: GoogleFonts.roboto(color: MyColors.lightPrimeryColor),
      titleMedium: GoogleFonts.roboto(color: MyColors.lightPrimeryColor),
      titleSmall: GoogleFonts.roboto(color: MyColors.lightPrimeryColor),
      headlineLarge: GoogleFonts.roboto(color: MyColors.lightBackground),
      headlineMedium: GoogleFonts.roboto(color: MyColors.lightBackground),
      headlineSmall: GoogleFonts.roboto(color: MyColors.lightBackground),
      bodyLarge: GoogleFonts.roboto(color: MyColors.lightPrimeryColor),
      bodyMedium: GoogleFonts.roboto(color: MyColors.lightPrimeryColor),
      bodySmall: GoogleFonts.roboto(color: MyColors.lightPrimeryColor),
      labelLarge: GoogleFonts.roboto(color: MyColors.lightPrimeryColor),
      labelMedium: GoogleFonts.roboto(color: MyColors.lightPrimeryColor),
      labelSmall: GoogleFonts.roboto(color: MyColors.lightPrimeryColor),
    ),

    // Button filled
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          GoogleFonts.roboto(
            fontWeight: FontWeight.w900,
            fontSize: 25,
            color: MyColors.lightBackground,
          ),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(MyColors.lightButtonBackground),
      ),
    ),

    // field decoration
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: MyColors.lightTextFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: MyColors.lightTextFieldFocusedBorder),
      ),
      hintStyle: TextStyle(color: MyColors.lightTextFieldHint),
    ),

    // icon theme
    iconTheme: IconThemeData(color: MyColors.lightPrimeryColor),

    // drawer
    drawerTheme: DrawerThemeData(
      backgroundColor: MyColors.lightBackground,
    ),

    // float Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: MyColors.lightButtonBackground,
    ),

    // bottom appbar
    bottomAppBarTheme: BottomAppBarTheme(
      color: MyColors.lightBackground,
    ),

    // appbar
    appBarTheme: AppBarTheme(
      backgroundColor: MyColors.lightBackground,
    ),
  );
}
