import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'main_wrapper.dart';

void main() {
  // Ensure widgets are initialized before setting system UI
  WidgetsFlutterBinding.ensureInitialized();

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

    // Optional: Set system bar colors based on theme
    SystemChrome.setSystemUIOverlayStyle(
        themeMode == ThemeMode.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark
    );

    return MaterialApp(
      title: 'GrowthLab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainWrapper(), // This is where the logic lives
    );
  }
}