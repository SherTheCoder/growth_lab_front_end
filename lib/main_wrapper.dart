import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growth_lab/features/chat/presentation/screens/inbox_screen.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/feed/presentation/screens/feed_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/create_post/presentation/screens/create_post_screen.dart';

// Controls the bottom navigation state
final navIndexProvider = StateProvider<int>((ref) => 0);

class MainWrapper extends ConsumerWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 1. Auth Guard
    if (authState.value == null) {
      return const LoginScreen();
    }

    // 2. Main App Navigation
    final currentIndex = ref.watch(navIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          FeedScreen(),   // Index 0
          SearchScreen(), // Index 1
          SizedBox(),     // Index 2 (Placeholder for Create Post)
          InboxScreen(), // Index 3
          ProfileScreen(),// Index 4
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Open Create Post Modal instead of switching tab
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
          } else {
            ref.read(navIndexProvider.notifier).state = index;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}