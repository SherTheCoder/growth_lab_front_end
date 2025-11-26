import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/feed_repository.dart';
import '../../domain/models.dart';

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
    state.whenData((currentPosts) {
      state = AsyncValue.data([post, ...currentPosts]);
    });
    try {
      await _repository.addPost(post);
    } catch (e) {
      // Handle error
    }
  }

  // --- RESTORED INTERACTION METHODS ---

  void toggleUpvote(String postId) {
    // 1. Update UI Immediately
    state.whenData((posts) {
      state = AsyncValue.data(posts.map((post) {
        if (post.id == postId) {
          final isUpvoting = !post.isLiked;
          return post.copyWith(
            isLiked: isUpvoting,
            upvotes: post.upvotes + (isUpvoting ? 1 : -1),
          );
        }
        return post;
      }).toList());
    });

    // 2. Update Repository (Global Store)
    _repository.toggleLike(postId);
  }

  void toggleFollow(String postId) {
    state.whenData((posts) {
      state = AsyncValue.data(posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(isFollowing: !post.isFollowing);
        }
        return post;
      }).toList());
    });
    _repository.toggleFollow(postId);
  }

  void toggleBookmark(String postId) {
    state.whenData((posts) {
      state = AsyncValue.data(posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(isBookmarked: !post.isBookmarked);
        }
        return post;
      }).toList());
    });
    _repository.toggleBookmark(postId);
  }

  void incrementCommentCount(String postId) {
    state.whenData((posts) {
      state = AsyncValue.data(posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(comments: post.comments + 1);
        }
        return post;
      }).toList());
    });
    _repository.incrementCommentCount(postId);
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