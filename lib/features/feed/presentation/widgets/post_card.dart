import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/screens/other_user_profile.dart';
import '../../domain/models.dart';
import '../providers/feed_provider.dart';
import '../screens/post_detail_screen.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1), width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, post, theme),
          const SizedBox(height: 8),
          _buildContent(context, post, theme),
          if (post.type != PostContentType.text) ...[
            const SizedBox(height: 12),
            _buildMedia(context, post),
          ],
          const SizedBox(height: 12),
          _buildActionBar(context, post, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Post post, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OtherUserProfileScreen(user: post.author))
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(post.author.avatarUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => OtherUserProfileScreen(user: post.author))
                          );
                        },
                        child: Text(
                          post.author.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (post.author.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.blue, size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "${post.author.headline} • ${post.author.location}",
                  style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _FollowButton(
            isFollowing: post.isFollowing,
            onTap: () => ref.read(feedProvider.notifier).toggleFollow(post.id),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Post post, ThemeData theme) {
    const int maxChars = 140;
    final bool isLongText = post.content.length > maxChars;
    final String displayText = !isExpanded && isLongText
        ? "${post.content.substring(0, maxChars)}... "
        : post.content;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayText,
            style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 15, height: 1.4),
          ),
          if (isLongText && !isExpanded)
            GestureDetector(
              onTap: () => setState(() => isExpanded = true),
              child: Text(
                "Show more",
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context, Post post) {
    // ... media logic remains similar as it relies on Images ...
    if (post.type == PostContentType.carousel) {
      return SizedBox(
        height: 250,
        child: PageView.builder(
          itemCount: post.mediaUrls.length,
          itemBuilder: (ctx, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(post.mediaUrls[index], fit: BoxFit.cover),
              ),
            );
          },
        ),
      );
    } else if (post.type == PostContentType.image) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(post.mediaUrls.first, fit: BoxFit.cover),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionBar(BuildContext context, Post post, ThemeData theme) {
    final iconColor = theme.iconTheme.color?.withOpacity(0.6) ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.change_history,
            label: post.upvotes.toString(),
            color: post.isLiked ? Colors.blue : iconColor,
            onTap: () => ref.read(feedProvider.notifier).toggleUpvote(post.id),
          ),
          const SizedBox(width: 24),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: post.comments.toString(),
            color: iconColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: post),
                ),
              );
            },
          ),
          const SizedBox(width: 24),
          _ActionButton(
            icon: Icons.repeat,
            label: post.reposts > 0 ? post.reposts.toString() : "",
            color: iconColor,
            onTap: () {},
          ),
          const SizedBox(width: 24),
          _ActionButton(
            icon: Icons.ios_share,
            label: "",
            color: iconColor,
            onTap: () {},
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: post.isBookmarked ? theme.textTheme.bodyLarge?.color : iconColor,
              size: 22,
            ),
            onPressed: () => ref.read(feedProvider.notifier).toggleBookmark(post.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Icon(Icons.more_horiz, color: iconColor, size: 22),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;
  final ThemeData theme;

  const _FollowButton({required this.isFollowing, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    // If following: background transparent, text color depends on theme
    // If not following: background transparent (or colored if desired), text color depends on theme

    // For specific "Growth Lab" style:
    // Dark Mode: White text, white border
    // Light Mode: Black text, black border
    final color = isFollowing ? theme.textTheme.bodyLarge?.color : theme.colorScheme.primary;
    final borderColor = theme.dividerColor.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isFollowing ? theme.scaffoldBackgroundColor : Colors.transparent,
          border: Border.all(color: isFollowing ? borderColor : (color ?? Colors.blue)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isFollowing ? "Following" : "Follow",
          style: TextStyle(
            color: isFollowing ? theme.textTheme.bodyMedium?.color : color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}