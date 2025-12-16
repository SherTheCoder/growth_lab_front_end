import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/feed_repository.dart';
import '../../domain/models.dart';
import 'feed_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class CommentNotifier extends StateNotifier<AsyncValue<List<Comment>>> {
  final FeedRepository _repository;
  final String entityId;
  final bool isReplyThread;
  final Ref ref;

  CommentNotifier(this._repository, this.entityId, this.ref, {this.isReplyThread = false})
      : super(const AsyncValue.loading()) {
    loadComments();
  }

  void _sortComments(List<Comment> comments) {
    comments.sort((a, b) => b.upvotes.compareTo(a.upvotes));
  }

  Future<void> loadComments() async {
    try {
      List<Comment> comments;
      if (isReplyThread) {
        comments = await _repository.fetchReplies(entityId);
      } else {
        comments = await _repository.fetchComments(entityId);
      }
      _sortComments(comments);
      state = AsyncValue.data(comments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addComment(String content, String postId, {String parentId = "0"}) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    try {
      // 1. Call Backend
      final newComment = await _repository.addComment(postId, content, parentId, user);

      // 2. Update Local State
      state.whenData((comments) {
        final updatedList = [...comments, newComment];
        _sortComments(updatedList);
        state = AsyncValue.data(updatedList);
      });

      // 3. Invalidate Profile Replies so they refresh next time they are viewed
      ref.invalidate(userRepliesProvider(user.id));

    } catch (e) {
      // Handle error (optional: show snackbar via a global listener or separate error state)
    }
  }

  void incrementReplyCount(String id) {
    // Optimistic local update
    state.whenData((comments) {
      final updatedList = comments.map((c) {
        if (c.id == id) {
          return c.copyWith(replyCount: c.replyCount + 1);
        }
        return c;
      }).toList();
      state = AsyncValue.data(updatedList);
    });
  }

  Future<void> toggleUpvote(String id) async {
    // 1. Optimistic Update
    _updateCommentLocally(id, (c) {
      final isUpvoting = !c.isLiked;
      return c.copyWith(
        isLiked: isUpvoting,
        upvotes: c.upvotes + (isUpvoting ? 1 : -1),
      );
    });

    try {
      // 2. Network Call
      await _repository.toggleCommentLike(id);
    } catch (e) {
      // 3. Revert on failure
      _updateCommentLocally(id, (c) {
        final wasUpvoting = c.isLiked;
        return c.copyWith(
          isLiked: !wasUpvoting,
          upvotes: c.upvotes + (!wasUpvoting ? 1 : -1),
        );
      });
    }
  }

  Future<void> toggleBookmark(String id) async {
    _updateCommentLocally(id, (c) => c.copyWith(isBookmarked: !c.isBookmarked));
    try {
      await _repository.toggleCommentBookmark(id);
    } catch (e) {
      _updateCommentLocally(id, (c) => c.copyWith(isBookmarked: !c.isBookmarked));
    }
  }

  void _updateCommentLocally(String id, Comment Function(Comment) transform) {
    state.whenData((comments) {
      final updatedList = comments.map((c) {
        if (c.id == id) return transform(c);
        return c;
      }).toList();

      // Re-sort if upvotes changed
      _sortComments(updatedList);
      state = AsyncValue.data(updatedList);
    });
  }
}

final commentsProvider = StateNotifierProvider.family<CommentNotifier, AsyncValue<List<Comment>>, String>(
      (ref, postId) {
    final repository = ref.watch(feedRepositoryProvider);
    return CommentNotifier(repository, postId, ref, isReplyThread: false);
  },
);

final repliesProvider = StateNotifierProvider.family<CommentNotifier, AsyncValue<List<Comment>>, String>(
      (ref, commentId) {
    final repository = ref.watch(feedRepositoryProvider);
    return CommentNotifier(repository, commentId, ref, isReplyThread: true);
  },
);