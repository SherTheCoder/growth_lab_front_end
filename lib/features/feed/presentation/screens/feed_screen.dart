import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/growth_lab_title.dart';
import '../widgets/post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    // We watch the SAME feedProvider, but filter it differently for each tab
    final feedState = ref.watch(feedProvider);
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
                backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.85),
              elevation: 0,
              floating: true,
              snap: true,
              pinned: false,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.menu, color: theme.iconTheme.color),
                onPressed: () {},
              ),
              title: GrowthLabTitle(
                theme: theme,
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.notifications_none,
                      color: theme.iconTheme.color),
                  onPressed: () {},
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: theme.tabBarTheme.indicatorColor,
                indicatorWeight: 2,
                labelColor: theme.tabBarTheme.labelColor,
                unselectedLabelColor: theme.tabBarTheme.unselectedLabelColor,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                tabs: const [
                  Tab(text: "Bookmarked"), // Bookmarks
                  Tab(text: "Discover"), // All Posts
                  Tab(text: "Following"), // Only Followed
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // 1. INNOVATION (BOOKMARKS)
            _buildFilteredFeed(
                feedState, (post) => post.isBookmarked, "No saved items yet"),

            // 2. DISCOVER (ALL)
            feedState.when(
              data: (posts) => RefreshIndicator(
                onRefresh: () async =>
                    ref.read(feedProvider.notifier).loadPosts(),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: posts.length,
                  itemBuilder: (context, index) => PostCard(post: posts[index]),
                ),
              ),
              error: (err, _) => Center(child: Text("Error: $err")),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),

            // 3. FOLLOWING (IS FOLLOWING)
            _buildFilteredFeed(feedState, (post) => post.isFollowing,
                "You aren't following anyone yet"),
          ],
        ),
      ),
      // NOTE: Bottom Navigation Bar removed from here, as it lives in MainWrapper
    );
  }

  Widget _buildFilteredFeed(AsyncValue<List<dynamic>> feedState,
      bool Function(dynamic) filter, String emptyMsg) {
    return feedState.when(
      data: (posts) {
        final filtered = posts.where(filter).toList();
        if (filtered.isEmpty) {
          return Center(
              child: Text(emptyMsg, style: TextStyle(color: Colors.grey[600])));
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: filtered.length,
          itemBuilder: (context, index) => PostCard(post: filtered[index]),
        );
      },
      error: (e, _) => Center(child: Text("Error: $e")),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
