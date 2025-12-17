import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growth_lab/shared/presentation/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../feed/presentation/providers/feed_provider.dart';
import '../../../feed/presentation/widgets/post_card.dart';
import '../../../feed/presentation/screens/post_detail_screen.dart'; // For CommentItem
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserState = ref.watch(authProvider);
    final user = currentUserState.value;
    final theme = Theme.of(context);

    if (user == null) return const Center(child: Text("Not logged in"));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
            onPressed: () {},
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // UPDATED: Theme-based background gradient instead of purple
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.2),
                                theme.scaffoldBackgroundColor,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: UserAvatar(avatarUrl: user.avatarUrl, radius: 40),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(user.username,
                        style: TextStyle(color: theme.colorScheme.secondary)),
                    Text(user.name,
                        style: theme.textTheme.headlineLarge?.copyWith(fontSize: 22)),
                    const SizedBox(height: 8),
                    Text("${user.headline} • ${user.location}",
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text("2 Following", style: theme.textTheme.bodyMedium),
                        const SizedBox(width: 16),
                        Text("0 Followers", style: theme.textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          // Uses the new OutlinedButtonTheme
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text("Edit profile"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () =>
                              ref.read(authProvider.notifier).logout(),
                          icon: const Icon(Icons.logout, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverAppBar(
              backgroundColor: Colors.transparent, // Make parent transparent
              pinned: true,
              floating: false,
              automaticallyImplyLeading: false,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), // Stronger blur
                  child: Container(
                    color: theme.scaffoldBackgroundColor.withOpacity(0.7), // Glass Tint
                  ),
                ),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: "Posts"),
                  Tab(text: "Replies"),
                  Tab(text: "Upvotes"),
                ],
              ),
            )
          ],
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _UserPostsFeed(userId: user.id),
              _UserRepliesFeed(userId: user.id),
              _UserUpvotesFeed(),
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
    // We filter the main feedProvider. Since addPost updates this, it will show up automatically.
    final feedState = ref.watch(feedProvider);
    return feedState.when(
      data: (posts) {
        final userPosts = posts.where((p) => p.author.id == userId).toList();
        if (userPosts.isEmpty) return  Center(child: Text("Create your first post", style: Theme.of(context).textTheme.bodyMedium));
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: userPosts.length,
          itemBuilder: (context, index) => PostCard(post: userPosts[index]),
        );
      },
      error: (e, _) => Center(child: Text("Error: $e")),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

// NEW WIDGET FOR REPLIES
class _UserRepliesFeed extends ConsumerWidget {
  final String userId;
  const _UserRepliesFeed({required this.userId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the dedicated replies provider for this user
    final repliesState = ref.watch(userRepliesProvider(userId));


    return repliesState.when(
      data: (replies) {
        if (replies.isEmpty) return  Center(child: Text("No replies yet", style: Theme.of(context).textTheme.bodyMedium));
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: replies.length,
          separatorBuilder: (_, __) =>  Divider(color: Theme.of(context).dividerColor, height: 1),
          itemBuilder: (context, index) {
            // Reusing CommentItem from PostDetailScreen
            return CommentItem(
              comment: replies[index],
              onReply: () {},
            );
          },
        );
      },
      error: (e, _) => Center(child: Text("Error: $e")),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _UserUpvotesFeed extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);
    return feedState.when(
      data: (posts) {
        final upvotedPosts = posts.where((p) => p.isLiked).toList();
        if (upvotedPosts.isEmpty) return const Center(child: Text("No upvotes yet", style: TextStyle(color: Colors.grey)));
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: upvotedPosts.length,
          itemBuilder: (context, index) => PostCard(post: upvotedPosts[index]),
        );
      },
      error: (e, _) => Center(child: Text("Error: $e")),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}