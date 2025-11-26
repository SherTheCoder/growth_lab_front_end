import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/feed_repository.dart';
import '../../domain/models.dart';
import 'feed_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_providers.dart'; // Import profile providers

class CommentNotifier extends StateNotifier<AsyncValue<List<Comment>>> {
  final FeedRepository _repository;
  final String entityId;
  final bool isReplyThread;
  final Ref ref; // Needed to invalidate other providers

  CommentNotifier(this._repository, this.entityId, this.ref, {this.isReplyThread = false})
      : super(const AsyncValue.loading()) {
    loadComments();
  }
  void _sortComments(List<Comment> comments) {
    // Sort by upvotes descending
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

  // UPDATED: Add Comment
  Future<void> addComment(String content, String postId, {String parentId = "0"}) async {
    // 1. Get Current User (Required for the author field)
    final user = ref.read(authProvider).value;
    if (user == null) return;

    // 2. Add to Repository
    final newComment = await _repository.addComment(postId, content, parentId, user);

    // 3. Update Local State (The list currently being viewed)
    state.whenData((comments) {
      state = AsyncValue.data([...comments, newComment]);
    });

    // 4. *** CRITICAL FIX ***
    // Invalidate the Profile Replies provider for this user.
    // This forces the Profile Screen to re-fetch the replies list next time it's viewed.
    ref.invalidate(userRepliesProvider(user.id));
  }

  // ... (Other methods: toggleUpvote, etc. same as before) ...
  void incrementReplyCount(String id) { /* ... */ }
  void toggleUpvote(String id) {
    state.whenData((comments) {
      final updatedList = comments.map((c) {
        if (c.id == id) {
          final isUpvoting = !c.isLiked;
          return c.copyWith(
            isLiked: isUpvoting,
            upvotes: c.upvotes + (isUpvoting ? 1 : -1),
          );
        }
        return c;
      }).toList();

      _sortComments(updatedList); // Re-sort after vote change
      state = AsyncValue.data(updatedList);
    });
  }
  void toggleBookmark(String id) {
    state.whenData((comments) {
      final updatedList = comments.map((c) {
        if (c.id == id) {
          return c.copyWith(isBookmarked: !c.isBookmarked);
        }
        return c;
      }).toList();
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


