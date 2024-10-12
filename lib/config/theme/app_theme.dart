import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.blue,
      
      appBarTheme:  const AppBarTheme(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white, size: 30 ),
        titleTextStyle: TextStyle(
          fontSize: 25,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
