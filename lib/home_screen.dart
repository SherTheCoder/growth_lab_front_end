import 'package:flutter/material.dart';
import 'package:growth_lab/features/chat/presentation/screens/inbox_screen.dart';
import 'package:growth_lab/shared/presentation/screens/coming_soon_screen.dart';
import 'features/create_post/presentation/screens/create_post_screen.dart';
import 'features/feed/presentation/screens/feed_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // CHANGED: Removed CreatePostScreen from this list
  // because it will be a popup, not a persistent tab.
  final List<Widget> _pages = [
    const FeedScreen(),     // Index 0
    // const SearchScreen(),   // Index 1
    // TODO: implement the search screen
    const ComingSoonScreen(
      icon: Icons.search,
      title: "Search Screen",
      description: "We are working on it. Searching Profiles will be available in the next update.",
      showGoBack: false,
    ),
    // Index 2 is skipped in this list because we handle it manually
    // const InboxScreen(), // Index 3 -> Logic will map this to match tab index
    // TODO: implement the search screen
    const ComingSoonScreen(
      icon: Icons.forward_to_inbox_rounded,
      title: "Inbox",
      description: "We are working on it! Inboxes and messaging will be available in the next update.",
      showGoBack: false,
    ),
    const ProfileScreen(),  // Index 4 -> Logic will map this to match tab index
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      // Logic to show correct page based on index
      // If index is > 2 (Messages/Profile), we subtract 1 because Create isn't in _pages
      body: _pages[_currentIndex > 2 ? _currentIndex - 1 : _currentIndex],

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: theme.colorScheme.primary.withOpacity(0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return IconThemeData(
                color: theme.colorScheme.primary,
                size: 26,
              );
            }
            return IconThemeData(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              size: 24,
            );
          }),
        ),
        child: NavigationBar(
          height: 65,
          selectedIndex: _currentIndex,
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          onDestinationSelected: (int index) {
            // THE FIX: INTERCEPT THE "CREATE" BUTTON
            if (index == 2) {
              // Push the screen as a full-screen modal
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen())
              );
              // Do NOT update _currentIndex, so the tab stays on Feed (or wherever you were)
              return;
            }

            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            // CENTER: Create Post
            NavigationDestination(
              icon: Icon(Icons.add_box_outlined),
              selectedIcon: Icon(Icons.add_box_rounded),
              label: 'Create',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}