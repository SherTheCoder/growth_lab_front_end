import 'package:flutter/material.dart';

class AppTheme {
  // Define custom colors if needed
  static const Color _lightPrimaryColor = Colors.blue;
  static const Color _lightBackgroundColor = Colors.white;
  static const Color _lightSurfaceColor = Color(0xFFF5F5F5);

  static const Color _darkPrimaryColor = Colors.blue;
  static const Color _darkBackgroundColor = Colors.black;
  static const Color _darkSurfaceColor = Color(0xFF121212);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: _lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightBackgroundColor,
      foregroundColor: Colors.black, // Icons and Text color
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      surface: _lightBackgroundColor,
      onSurface: Colors.black,
      secondary: Colors.grey,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.black,
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightBackgroundColor,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBackgroundColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      surface: _darkBackgroundColor,
      onSurface: Colors.white,
      secondary: Colors.grey,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkBackgroundColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    ),
  );
}