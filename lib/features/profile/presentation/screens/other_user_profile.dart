import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growth_lab/shared/presentation/widgets/user_avatar.dart';
import '../../../../shared/presentation/screens/coming_soon_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import 'package:growth_lab/core/models/user_model.dart';
import '../../../feed/presentation/widgets/post_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
// Import Search Repo for fetching user posts
import '../../../search/data/search_repository.dart';
import '../../../feed/domain/models.dart';

// Create a simple FutureProvider to fetch this specific user's posts
final userPostsProvider = FutureProvider.family<List<Post>, String>((ref, userId) async {
  // Use FeedRepository, not SearchRepository
  final feedRepo = ref.read(searchRepositoryProvider);
  return feedRepo.fetchUserPosts(userId);
});

// Helper provider for SearchRepository if not already in search_screen.dart
final searchRepositoryProvider = Provider((ref) => SearchRepository());


class OtherUserProfileScreen extends ConsumerWidget {
  final User user;

  const OtherUserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).value;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 180,
                backgroundColor: theme.scaffoldBackgroundColor,
                pinned: false,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Cover Image (You can use a placeholder or user.coverUrl if added later)
                      Image.network(
                        "https://images.unsplash.com/photo-1550684848-fac1c5b4e853?auto=format&fit=crop&q=80",
                        fit: BoxFit.cover,
                      ),
                      // 2. Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black12,
                              theme.scaffoldBackgroundColor,
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: UserAvatar(avatarUrl: user.avatarUrl, radius: 45),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.username, style: TextStyle(color: theme.colorScheme.secondary, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              user.name,
                              style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Real Headline & Location
                            Text(
                                "${user.headline} • ${user.location}",
                                style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 15)
                            ),
                            const SizedBox(height: 16),

                            // Real Stats
                            Row(
                              children: [
                                _StatText(
                                    count: "${user.totalConnections}",
                                    label: "Connections",
                                    theme: theme
                                ),
                                const SizedBox(width: 16),
                                _StatText(
                                    count: "${user.totalPosts}",
                                    label: "Posts",
                                    theme: theme
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Real Bio
                            if (user.bio.isNotEmpty) ...[
                              Text(
                                user.bio,
                                style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8), height: 1.4),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Real Website
                            if (user.websiteUrl.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.language, color: theme.colorScheme.primary, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                      user.websiteUrl,
                                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)
                                  ),
                                ],
                              ),

                            const SizedBox(height: 24),

                            // Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (currentUser == null) return;
                                      final repo = ref.read(chatRepositoryProvider);
                                      final chatId = await repo.getOrCreateConversation(currentUser, user);
                                      if (context.mounted) {
                                        // TODO: implement the messaging feature
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const ComingSoonScreen(
                                            icon: Icons.message,
                                            title: "Message Screen",
                                            description: "We are working on it! Messaging will be available in the next update.",
                                          )),
                                        );
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (_) => ChatScreen(
                                        //             conversationId: chatId,
                                        //             otherUser: user
                                        //         )
                                        //     )
                                        // );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: theme.colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    ),
                                    child: const Text("Send message", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _CircleAction(icon: Icons.person_add, onTap: () {}, theme: theme),
                                const SizedBox(width: 12),
                                _CircleAction(icon: Icons.more_horiz, onTap: () {}, theme: theme),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorColor: theme.colorScheme.primary,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.textTheme.bodyMedium?.color,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: "Posts"),
                      Tab(text: "About"), // Changed Pages to About since backend doesn't support pages yet
                    ],
                  ),
                  theme.scaffoldBackgroundColor,
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              _UserPostsFeed(userId: user.id),
              const Center(child: Text("About info unavailable")),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserPostsFeed extends ConsumerWidget {
  final String userId;
  const _UserPostsFeed({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // USE THE NEW PROVIDER that fetches real posts by authorID
    final postsAsync = ref.watch(userPostsProvider(userId));

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: Center(child: Text("No posts yet")),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: posts.length,
          itemBuilder: (context, index) => PostCard(post: posts[index]),
        );
      },
      error: (e, _) => Center(child: Text("Error loading posts: $e")),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

// ... Keep _StatText, _CircleAction, and _SliverAppBarDelegate classes exactly as before ...
class _StatText extends StatelessWidget {
  final String count;
  final String label;
  final ThemeData theme;

  const _StatText({required this.count, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(count, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 15)),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ThemeData theme;

  const _CircleAction({required this.icon, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          shape: BoxShape.circle
      ),
      child: IconButton(
          icon: Icon(icon, color: theme.iconTheme.color),
          onPressed: onTap
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _backgroundColor;
  _SliverAppBarDelegate(this._tabBar, this._backgroundColor);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: _backgroundColor, child: _tabBar);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}