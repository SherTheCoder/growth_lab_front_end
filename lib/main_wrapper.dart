import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'home_screen.dart'; // Import the new HomeScreen

class MainWrapper extends ConsumerWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // CHANGED: Return HomeScreen instead of FeedScreen
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
      error: (err, stack) {
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}