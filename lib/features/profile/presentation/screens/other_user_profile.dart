import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growth_lab/shared/presentation/widgets/user_avatar.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import 'package:growth_lab/core/models/user_model.dart';
import '../../../feed/presentation/providers/feed_provider.dart';
import '../../../feed/presentation/widgets/post_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_providers.dart';

// Placeholder for the ChatScreen which we will build next
// import '../../../chat/presentation/screens/chat_screen.dart';

class OtherUserProfileScreen extends ConsumerWidget {
  final User user;

  const OtherUserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).value;

    // FIX: Added DefaultTabController to coordinate TabBar and TabBarView
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 180,
                backgroundColor: Colors.black,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        "https://images.unsplash.com/photo-1550684848-fac1c5b4e853?auto=format&fit=crop&q=80",
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.4),
                        colorBlendMode: BlendMode.darken,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black12, Colors.black],
                            stops: [0.0, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar overlap
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: UserAvatar(avatarUrl: user.avatarUrl, radius: 45,),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.username, style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              user.name,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text("${user.headline} • ${user.location}", style: const TextStyle(color: Colors.white, fontSize: 15)),
                            const SizedBox(height: 16),
                            Row(
                              children: const [
                                _StatText(count: "5", label: "Following"),
                                SizedBox(width: 16),
                                _StatText(count: "98", label: "Followers"),
                                SizedBox(width: 16),
                                _StatText(count: "1", label: "Page"),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "tea maker, artist, healthcare app maker, decentralisation curioso, alternative way of being/living",
                              style: TextStyle(color: Colors.grey[400], height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Icon(Icons.language, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text("https://www.herb elletease.com", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (currentUser == null) return;

                                        final repo = ref.read(chatRepositoryProvider);
                                        // FIX: Pass full User objects to create conversation in memory
                                        final chatId = await repo.getOrCreateConversation(currentUser, user);

                                        if (context.mounted) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => ChatScreen(
                                                      conversationId: chatId,
                                                      otherUser: user
                                                  )
                                              )
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      ),
                                      child: const Text("Send message", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _CircleAction(icon: Icons.person_add, onTap: () {}),
                                const SizedBox(width: 12),
                                _CircleAction(icon: Icons.more_horiz, onTap: () {}),
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
                  const TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: "Posts"),
                      Tab(text: "Pages"),
                    ],
                  ),
                ),
                pinned: false,
              ),
            ];
          },
          body: TabBarView(
            children: [
              _UserPostsFeed(userId: user.id),
              const Center(child: Text("No pages yet", style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatText extends StatelessWidget {
  final String count;
  final String label;
  const _StatText({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[900], shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: Colors.white), onPressed: onTap),
    );
  }
}

class _UserPostsFeed extends ConsumerWidget {
  final String userId;
  const _UserPostsFeed({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);
    return feedState.when(
      data: (posts) {
        final userPosts = posts.where((p) => p.author.id == userId).toList();
        if (userPosts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: Center(child: Text("No posts yet", style: TextStyle(color: Colors.grey))),
          );
        }
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}