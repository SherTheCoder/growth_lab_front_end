import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../feed/presentation/providers/feed_provider.dart';
import '../../../feed/presentation/widgets/post_card.dart';
import '../../../feed/presentation/screens/post_detail_screen.dart'; // For CommentItem
import '../providers/profile_providers.dart'; // Import the new provider

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserState = ref.watch(authProvider);
    final user = currentUserState.value;

    if (user == null) return const Center(child: Text("Not logged in"));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () {}),
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
                        Container(height: 100, color: Colors.purpleAccent.withOpacity(0.2)),
                        Positioned(
                          bottom: 0,
                          left: 16,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(user.avatarUrl),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Text(user.username, style: const TextStyle(color: Colors.grey)),
                    Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("${user.headline} • ${user.location}", style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Text("2 Following", style: TextStyle(color: Colors.grey)),
                        SizedBox(width: 16),
                        Text("0 Followers", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Edit profile", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(onPressed: () => ref.read(authProvider.notifier).logout(), icon: const Icon(Icons.logout, color: Colors.red)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverAppBar(
              backgroundColor: Colors.black,
              pinned: false,
              floating: false,
              automaticallyImplyLeading: false,
              bottom: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: "Posts"),
                  Tab(text: "Replies"),
                  Tab(text: "Upvotes"),
                ],
              ),
            )
          ],
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              _UserPostsFeed(userId: user.id),
              // NEW: User Replies Feed
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
        if (userPosts.isEmpty) return const Center(child: Text("Create your first post", style: TextStyle(color: Colors.grey)));
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
        if (replies.isEmpty) return const Center(child: Text("No replies yet", style: TextStyle(color: Colors.grey)));
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: replies.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
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