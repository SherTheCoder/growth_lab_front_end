import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/widgets/post_image_widget.dart';
import '../../../profile/presentation/screens/other_user_profile.dart';
import '../../domain/models.dart';
import '../providers/feed_provider.dart';
import '../screens/post_detail_screen.dart';
import 'package:growth_lab/shared/presentation/widgets/user_avatar.dart';

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

    // CHANGED: Wrapped in Card to match the screenshot style
    return Card(
      // Margin creates the "floating" effect distinct from the background
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias, // Ensures content stays inside rounded corners
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, post, theme),
            const SizedBox(height: 12), // Increased spacing slightly
            _buildContent(context, post, theme),
            if (post.type != PostContentType.text) ...[
              const SizedBox(height: 12),
              _buildMedia(context, post),
            ],
            const SizedBox(height: 12),
            _buildActionBar(context, post, theme),
          ],
        ),
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
                  MaterialPageRoute(
                      builder: (_) =>
                          OtherUserProfileScreen(user: post.author)));
            },
            child: UserAvatar(avatarUrl: post.author.avatarUrl, radius: 20),
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
                              MaterialPageRoute(
                                  builder: (_) => OtherUserProfileScreen(
                                      user: post.author)));
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
                  style: TextStyle(
                      color: theme.colorScheme.secondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _FollowButton(
            isFollowing: post.isFollowing,
            onTap: () {
              // UPDATED: Use author.id for following user logic
              ref.read(feedProvider.notifier).toggleFollow(post.author.id);
            },
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
            style: TextStyle(
                color: theme.textTheme.bodyMedium?.color, // Uses theme color
                fontSize: 15,
                height: 1.5), // Increased line height for readability
          ),
          if (isLongText && !isExpanded)
            GestureDetector(
              onTap: () => setState(() => isExpanded = true),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Show more",
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context, Post post) {
    if (post.mediaUrls.length > 1) {
      return SizedBox(
        height: 300, // Fixed height for carousel to keep UI consistent
        child: PageView.builder(
          itemCount: post.mediaUrls.length,
          itemBuilder: (ctx, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: PostImageWidget(imageUrl: post.mediaUrls[index]),
            );
          },
        ),
      );
    } else if (post.mediaUrls.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // We REMOVE the AspectRatio widget here.
        // PostImageWidget already has a maxHeight constraint (450px)
        // so it won't take up the whole screen, but it will respect natural shape.
        child: PostImageWidget(imageUrl: post.mediaUrls.first),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionBar(BuildContext context, Post post, ThemeData theme) {
    final iconColor = theme.iconTheme.color?.withOpacity(0.6) ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Better spacing
        children: [
          _ActionButton(
            icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
            label: post.upvotes.toString(),
            color: post.isLiked ? Color(0xFFFF2D55) : iconColor,
            onTap: () => ref.read(feedProvider.notifier).toggleUpvote(post.id),
          ),
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
          _ActionButton(
            icon: Icons.repeat,
            label: post.reposts > 0 ? post.reposts.toString() : "",
            color: iconColor,
            onTap: () {},
          ),
          IconButton(
            icon: Icon(
              post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: post.isBookmarked
                  ? theme.colorScheme.primary
                  : iconColor,
              size: 22,
            ),
            onPressed: () =>
                ref.read(feedProvider.notifier).toggleBookmark(post.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
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
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
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

  const _FollowButton(
      {required this.isFollowing, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isFollowing
        ? Colors.transparent // Using new Flutter standard for "greyed out" element
        : theme.colorScheme.primary;

    final textColor = isFollowing
        ? theme.textTheme.bodyMedium?.color
        : theme.colorScheme.onPrimary;

    final color = isFollowing
        ? theme.textTheme.bodyLarge?.color
        : theme.colorScheme.primary;
    final borderColor = theme.dividerColor.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
              color: isFollowing ? borderColor : (color ?? Colors.blue)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isFollowing ? "Following" : "Follow",
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}