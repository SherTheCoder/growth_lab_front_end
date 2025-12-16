import 'package:flutter/material.dart';
import 'package:growth_lab/core/models/user_model.dart';
import 'package:growth_lab/shared/presentation/widgets/user_avatar.dart';
import '../../../profile/presentation/screens/other_user_profile.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Get the current theme data
    final theme = Theme.of(context);

    // Mock suggested accounts
    final suggestions = [
      const User(id: 's1', name: 'Maximilian Werner', username: '@maximilian', avatarUrl: 'https://i.pravatar.cc/150?u=max', headline: 'Founder of INSPIRED', location: 'Switzerland', isVerified: true),
      const User(id: 's2', name: 'Franziska Heyde', username: '@franziska', avatarUrl: 'https://i.pravatar.cc/150?u=fran', headline: 'Founder of With All Your Heart', location: 'Germany', isVerified: true),
      const User(id: 's3', name: 'Impact Radar', username: '@impactradar', avatarUrl: 'https://i.pravatar.cc/150?u=impact', headline: 'Community', location: 'Germany'),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        // UPDATED: Use headline style instead of hardcoded white
        title: Text(
          "Search",
          style: theme.textTheme.headlineLarge?.copyWith(fontSize: 24),
        ),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              // UPDATED: Use body text color so it's visible in both modes
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: "Accounts, topics, keywords...",
                // UPDATED: Use theme hint color
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                // Note: We keep the border radius but let the global InputDecorationTheme handle colors
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Suggested accounts",
              // UPDATED: Use theme text style
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: suggestions.length,
              // UPDATED: Use theme divider color (subtle in both modes)
              separatorBuilder: (_, __) => Divider(color: theme.dividerColor),
              itemBuilder: (context, index) {
                final user = suggestions[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OtherUserProfileScreen(user: user))
                    );
                  },
                  leading: UserAvatar(avatarUrl: user.avatarUrl),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          // UPDATED: Use body text (Black in Light, White in Dark)
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 14, color: Colors.blue),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.username, style: theme.textTheme.bodyMedium),
                      Text(
                        user.headline,
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: OutlinedButton(
                    onPressed: () {},
                    // UPDATED: Removed hardcoded styles.
                    // This now inherits from 'outlinedButtonTheme' in app_theme.dart
                    // (Teal in Light mode, White in Dark mode)
                    child: const Text("Follow"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}