import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_wrapper.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'main_wrapper.dart'; // Import the wrapper
import 'package:flutter/services.dart'; // Import this

void main() {
  runApp(
    const ProviderScope(
      child: GrowthLabApp(),
    ),
  );
}

class GrowthLabApp extends ConsumerWidget {
  const GrowthLabApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    SystemChrome.setSystemUIOverlayStyle(
        themeMode == ThemeMode.dark
            ? SystemUiOverlayStyle.light // White icons for Dark Mode
            : SystemUiOverlayStyle.dark  // Black icons for Light Mode
    );
    return MaterialApp(
      title: 'GrowthLab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainWrapper(), // Use MainWrapper as home
    );
  }
}