import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/screens/other_user_profile.dart';
import '../../domain/models.dart';
import '../providers/comment_action.dart';
import '../providers/comment_provider.dart';
import '../providers/feed_provider.dart'; // Import Feed Provider
import '../widgets/post_card.dart';
import 'comment_thread_screen.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final Post post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  void _handleSubmit() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    // 1. Add the comment to the comment list
    ref.read(commentsProvider(widget.post.id).notifier).addComment(text, widget.post.id);

    // 2. Increment the comment count on the Post itself (in the feed)
    ref.read(feedProvider.notifier).incrementCommentCount(widget.post.id);

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commentsState = ref.watch(commentsProvider(widget.post.id));

    // 3. Try to find the 'live' version of this post from the feedProvider
    final feedState = ref.watch(feedProvider);
    final livePost = feedState.asData?.value.firstWhere(
          (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    ) ?? widget.post;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: theme.appBarTheme.foregroundColor),
        title: const Text("Thread", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PostCard(post: livePost),
                  Divider(height: 1, color: theme.dividerColor),
                  if (livePost.comments == 0)
                    const SizedBox.shrink()
                  else
                  commentsState.when(
                    data: (comments) {
                      if (comments.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: Text("No comments yet.", style: TextStyle(color: Colors.grey))),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        separatorBuilder: (c, i) => Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          // This widget is now defined at the bottom of the file
                          return CommentItem(
                            comment: comment,
                            onReply: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentThreadScreen(parentComment: comment),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    // Hide loader if we have a count but data is still fetching (optional preference)
                    // keeping standard loader here for when count > 0 but data is fetching.
                    loading: () => const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
                    error: (err, _) => Center(child: Text("Error: $err")),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=me'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  hintStyle: TextStyle(color: theme.colorScheme.secondary),
                  border: InputBorder.none,
                ),
              ),
            ),
            TextButton(
              onPressed: _handleSubmit,
              child: Text("Post", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

// --- MISSING CLASSES ADDED BELOW ---

class CommentItem extends ConsumerWidget {
  final Comment comment;
  final VoidCallback onReply;
  final bool isThreadView;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.onReply,
    this.isThreadView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OtherUserProfileScreen(user: comment.author))
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(comment.author.avatarUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => OtherUserProfileScreen(user: comment.author))
                        );
                      },
                      child: Text(
                          comment.author.name,
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color, fontSize: 14)
                      ),
                    ),
                    if (comment.author.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.blue, size: 14),
                    ],
                    const Spacer(),
                    Text("8d", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 10),
                    Icon(Icons.more_horiz, color: Colors.grey, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9), fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // UPVOTE
                    GestureDetector(
                      onTap: () {
                        if (comment.parentCommentId == "0") {
                          ref.read(commentsProvider(comment.postId).notifier).toggleUpvote(comment.id);
                        } else {
                          ref.read(repliesProvider(comment.parentCommentId).notifier).toggleUpvote(comment.id);
                        }
                      },
                      child: SmallAction(
                        icon: comment.isLiked ? Icons.change_history : Icons.change_history,
                        label: "${comment.upvotes}",
                        theme: theme,
                        color: comment.isLiked ? Colors.blue : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 24),

                    // REPLY
                    GestureDetector(
                      onTap: onReply,
                      child: SmallAction(
                          icon: Icons.chat_bubble_outline,
                          label: comment.replyCount > 0 ? "${comment.replyCount}" : "",
                          theme: theme
                      ),
                    ),
                    const SizedBox(width: 24),
                    SmallAction(icon: Icons.repeat, label: "", theme: theme),
                    const SizedBox(width: 24),

                    // BOOKMARK
                    GestureDetector(
                      onTap: () {
                        if (comment.parentCommentId == "0") {
                          ref.read(commentsProvider(comment.postId).notifier).toggleBookmark(comment.id);
                        } else {
                          ref.read(repliesProvider(comment.parentCommentId).notifier).toggleBookmark(comment.id);
                        }
                      },
                      child: SmallAction(
                        icon: comment.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        label: "",
                        theme: theme,
                        color: comment.isBookmarked ? theme.textTheme.bodyLarge?.color : Colors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
