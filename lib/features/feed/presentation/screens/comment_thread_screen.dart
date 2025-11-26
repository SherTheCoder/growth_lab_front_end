import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models.dart';
import '../providers/comment_provider.dart';
import 'post_detail_screen.dart'; // Imports CommentItem

class CommentThreadScreen extends ConsumerStatefulWidget {
  final Comment parentComment;

  const CommentThreadScreen({Key? key, required this.parentComment}) : super(key: key);

  @override
  ConsumerState<CommentThreadScreen> createState() => _CommentThreadScreenState();
}

class _CommentThreadScreenState extends ConsumerState<CommentThreadScreen> {
  final TextEditingController _replyController = TextEditingController();

  void _handleSubmit() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    // 1. Add the new reply to the list of replies for THIS comment
    ref.read(repliesProvider(widget.parentComment.id).notifier).addComment(
      text,
      widget.parentComment.postId,
      parentId: widget.parentComment.id,
    );

    // 2. Increment the reply count on the PARENT comment itself.
    // We need to determine where the parent comment lives to update it.
    if (widget.parentComment.parentCommentId == "0") {
      // It's a top-level comment, so it lives in commentsProvider
      ref.read(commentsProvider(widget.parentComment.postId).notifier)
          .incrementReplyCount(widget.parentComment.id);
    } else {
      // It's a nested reply, so it lives in repliesProvider of its parent
      ref.read(repliesProvider(widget.parentComment.parentCommentId).notifier)
          .incrementReplyCount(widget.parentComment.id);
    }

    _replyController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 3. Watch the list of replies to display in the list
    final repliesState = ref.watch(repliesProvider(widget.parentComment.id));

    // 4. Find the "Live" version of the parent comment to display at the top.
    // We need to watch the provider that contains the parent comment.
    AsyncValue<List<Comment>> parentListState;
    if (widget.parentComment.parentCommentId == "0") {
      parentListState = ref.watch(commentsProvider(widget.parentComment.postId));
    } else {
      parentListState = ref.watch(repliesProvider(widget.parentComment.parentCommentId));
    }

    // Extract the updated parent comment object, or fallback to the widget's initial data
    final liveParentComment = parentListState.asData?.value.firstWhere(
          (c) => c.id == widget.parentComment.id,
      orElse: () => widget.parentComment,
    ) ?? widget.parentComment;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: theme.appBarTheme.foregroundColor),
        title: const Text("Replies", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. The Parent Comment (Using live data)
                  Container(
                    color: theme.dividerColor.withOpacity(0.05),
                    child: CommentItem(
                      comment: liveParentComment,
                      isThreadView: true,
                      onReply: () {
                        // Focus input
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ),
                  Divider(height: 1, color: theme.dividerColor),

                  // 2. Replies List
                  if (liveParentComment.replyCount == 0)
                    const SizedBox.shrink()
                  else
                  repliesState.when(
                    data: (replies) {
                      if (replies.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(child: Text("No replies yet.", style: TextStyle(color: Colors.grey))),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: replies.length,
                        separatorBuilder: (c, i) => Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                        itemBuilder: (context, index) {
                          final reply = replies[index];
                          // Recursion: Clicking reply on a reply opens a NEW Thread Screen
                          return CommentItem(
                            comment: reply,
                            onReply: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentThreadScreen(parentComment: reply),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Center(child: Text("Error: $e")),
                  ),
                ],
              ),
            ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=me'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        hintText: "Reply to ${widget.parentComment.author.name}...",
                        hintStyle: TextStyle(color: theme.colorScheme.secondary),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _handleSubmit,
                    child: Text("Reply", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}