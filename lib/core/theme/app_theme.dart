import 'package:flutter/material.dart';

class AppTheme {
  // --- COLOR PALETTE EXTRACTED FROM SCREENSHOTS ---

  // Primary Accent (The Teal/Green color in buttons)
  static const Color _primaryColor = Color(0xFF3A7D79);

  // Secondary/Variant (Used for gradients or accents)
  static const Color _secondaryColor = Color(
      0xFFD4AF37); // Gold-ish tone seen in gradients

  // Light Theme Colors
  static const Color _lightBackgroundColor = Color(0xFFFFFFFF); // Pure White
  static const Color _lightSurfaceColor = Color(
      0xFFF8F9FB); // Very light grey/blue for backgrounds
  static const Color _lightTextColor = Color(0xFF1A1A1A); // Almost Black
  static const Color _lightSubTextColor = Color(0xFF555555); // Dark Grey

  // Dark Theme Colors (The Deep Navy style)
  static const Color _darkBackgroundColor = Color(0xFF0D121D); // Deep Navy Blue
  static const Color _darkSurfaceColor = Color(
      0xFF161C28); // Lighter Navy for Cards
  static const Color _darkTextColor = Color(0xFFFFFFFF); // Pure White
  static const Color _darkSubTextColor = Color(0xFFAAAAAA); // Light Grey

  // --- LIGHT THEME DEFINITION ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _lightBackgroundColor,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightBackgroundColor,
      foregroundColor: _lightTextColor,
      elevation: 0,
      iconTheme: IconThemeData(color: _lightTextColor),
    ),
    // ... inside lightTheme ...

    // Buttons (Pill-shaped, Teal)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryColor,
        side: const BorderSide(color: _primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    // Color Scheme (New Flutter Standard)
    colorScheme: const ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: _lightBackgroundColor,
      onSurface: _lightTextColor,
      onPrimary: Colors.white, // Text on teal buttons
    ),

    // Card Theme (for Post Cards)
    cardTheme: CardThemeData(
        color: _lightBackgroundColor,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: Colors.grey.withOpacity(0.5),
              width: 1
          ),
        ),

    ),

    // Input Decoration (TextFields)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurfaceColor,
      hintStyle: const TextStyle(color: _lightSubTextColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _lightBackgroundColor, // or _darkSurfaceColor
      titleTextStyle: TextStyle(
          color: _lightTextColor, fontWeight: FontWeight.bold, fontSize: 20),
      contentTextStyle: TextStyle(color: _lightTextColor, fontSize: 16),
    ),
    // Typography
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          color: _lightTextColor, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: _lightTextColor),
      bodyMedium: TextStyle(color: _lightSubTextColor),
    ),

    // Tab Bar
    tabBarTheme: const TabBarThemeData(
      labelColor: _primaryColor,
      unselectedLabelColor: _lightSubTextColor,
      indicatorColor: _primaryColor,
    ),
  );

  // --- DARK THEME DEFINITION ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBackgroundColor,
      foregroundColor: _darkTextColor,
      elevation: 0,
      iconTheme: IconThemeData(color: _darkTextColor),
    ),
    // ... inside darkTheme ...
    dialogTheme: DialogThemeData(
      backgroundColor: _lightBackgroundColor, // or _darkSurfaceColor
      titleTextStyle: TextStyle(
          color: _lightTextColor, fontWeight: FontWeight.bold, fontSize: 20),
      contentTextStyle: TextStyle(color: _lightTextColor, fontSize: 16),
    ),

    // Buttons (Pill-shaped, Teal)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        // White text on dark for secondary buttons
        side: const BorderSide(color: Colors.white24, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: _darkSurfaceColor,
      onSurface: _darkTextColor,
      onPrimary: Colors.white,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: _darkSurfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Add a subtle border for dark mode cards if needed to separate from background
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceColor,
      hintStyle: const TextStyle(color: _darkSubTextColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    // Typography
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          color: _darkTextColor, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: _darkTextColor),
      bodyMedium: TextStyle(color: _darkSubTextColor),
    ),

    // Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkBackgroundColor,
      selectedItemColor: _primaryColor, // Teal for active tab
      unselectedItemColor: _darkSubTextColor,
    ),
  );
}