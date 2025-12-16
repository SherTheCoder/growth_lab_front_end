import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models.dart';

// Uncomment real repo when testing with backend
// import '../../data/feed_repository.dart';
import '../../data/mock_feed_repo.dart';


final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

class FeedNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final FeedRepository _repository;

  FeedNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final posts = await _repository.fetchPosts();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPost(Post post) async {
    // We assume the UI shows a loading state or waits for this Future to complete.
    // We send the post to the backend first to get the real ID and Timestamp.
    try {
      final newPost = await _repository.addPost(post);

      // Add the real returned post to the top of the list
      state.whenData((currentPosts) {
        state = AsyncValue.data([newPost, ...currentPosts]);
      });
    } catch (e) {
      // You might want to rethrow or handle the error so the UI shows a snackbar
      rethrow;
    }
  }

  // --- INTERACTION METHODS WITH ERROR HANDLING ---

  Future<void> toggleUpvote(String postId) async {
    // 1. Optimistic Update (Immediate UI feedback)
    _updatePostLocally(postId, (post) {
      final isUpvoting = !post.isLiked;
      return post.copyWith(
        isLiked: isUpvoting,
        upvotes: post.upvotes + (isUpvoting ? 1 : -1),
      );
    });

    try {
      // 2. Network Call
      await _repository.toggleLike(postId);
    } catch (e) {
      // 3. Revert on Failure
      _updatePostLocally(postId, (post) {
        final wasUpvoting = post.isLiked; // The state we just switched TO
        return post.copyWith(
          isLiked: !wasUpvoting, // Switch back
          upvotes: post.upvotes + (!wasUpvoting ? 1 : -1),
        );
      });
    }
  }

  Future<void> toggleFollow(String postId) async {
    _updatePostLocally(postId, (post) => post.copyWith(isFollowing: !post.isFollowing));
    try {
      await _repository.toggleFollow(postId);
    } catch (e) {
      // Revert
      _updatePostLocally(postId, (post) => post.copyWith(isFollowing: !post.isFollowing));
    }
  }

  Future<void> toggleBookmark(String postId) async {
    _updatePostLocally(postId, (post) => post.copyWith(isBookmarked: !post.isBookmarked));
    try {
      await _repository.toggleBookmark(postId);
    } catch (e) {
      // Revert
      _updatePostLocally(postId, (post) => post.copyWith(isBookmarked: !post.isBookmarked));
    }
  }

  void incrementCommentCount(String postId) {
    // Simple local update, assuming success
    _updatePostLocally(postId, (post) => post.copyWith(comments: post.comments + 1));
  }

  // Helper to reduce boilerplate
  void _updatePostLocally(String postId, Post Function(Post) transform) {
    state.whenData((posts) {
      state = AsyncValue.data(posts.map((post) {
        if (post.id == postId) {
          return transform(post);
        }
        return post;
      }).toList());
    });
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<Post>>>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  return FeedNotifier(repository);
});

// Bookmarks Provider
final bookmarkedFeedProvider = Provider<AsyncValue<List<Post>>>((ref) {
  final feedState = ref.watch(feedProvider);
  return feedState.whenData((posts) => posts.where((p) => p.isBookmarked).toList());
});