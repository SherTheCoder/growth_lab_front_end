import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/data/connections.dart';
import '../../data/feed_repository.dart';
import '../../domain/models.dart';

// Providers
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  return ConnectionRepository();
});

class FeedNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final FeedRepository _feedRepository;
  final ConnectionRepository _connectionRepository;

  FeedNotifier(this._feedRepository, this._connectionRepository) : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final posts = await _feedRepository.fetchPosts();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPost(Post post) async {
    try {
      final newPost = await _feedRepository.addPost(post);
      state.whenData((currentPosts) {
        state = AsyncValue.data([newPost, ...currentPosts]);
      });
    } catch (e) {
      rethrow;
    }
  }

  // --- INTERACTIONS ---

  Future<void> toggleUpvote(String postId) async {
    _updatePostLocally(postId, (post) {
      final isUpvoting = !post.isLiked;
      return post.copyWith(
        isLiked: isUpvoting,
        upvotes: post.upvotes + (isUpvoting ? 1 : -1),
      );
    });

    try {
      await _feedRepository.toggleLike(postId);
    } catch (e) {
      // Revert on Failure
      _updatePostLocally(postId, (post) {
        final wasUpvoting = post.isLiked;
        return post.copyWith(
          isLiked: !wasUpvoting,
          upvotes: post.upvotes + (!wasUpvoting ? 1 : -1),
        );
      });
    }
  }

  // UPDATED: Follow Logic
  Future<void> toggleFollow(String authorId) async {
    // 1. Optimistic Update: Find ALL posts by this author and toggle their state
    _updatePostsByAuthorLocally(authorId, (post) => post.copyWith(isFollowing: !post.isFollowing));

    try {
      // 2. Network Call
      await _connectionRepository.toggleFollow(authorId);
    } catch (e) {
      // 3. Revert on Failure
      _updatePostsByAuthorLocally(authorId, (post) => post.copyWith(isFollowing: !post.isFollowing));
    }
  }

  Future<void> toggleBookmark(String postId) async {
    _updatePostLocally(postId, (post) => post.copyWith(isBookmarked: !post.isBookmarked));
    try {
      await _feedRepository.toggleBookmark(postId);
    } catch (e) {
      _updatePostLocally(postId, (post) => post.copyWith(isBookmarked: !post.isBookmarked));
    }
  }

  void incrementCommentCount(String postId) {
    _updatePostLocally(postId, (post) => post.copyWith(comments: post.comments + 1));
  }

  // --- HELPERS ---

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

  // NEW: Update all posts by a specific author (for Follow actions)
  void _updatePostsByAuthorLocally(String authorId, Post Function(Post) transform) {
    state.whenData((posts) {
      state = AsyncValue.data(posts.map((post) {
        if (post.author.id == authorId) {
          return transform(post);
        }
        return post;
      }).toList());
    });
  }
}

// Main Provider
final feedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<Post>>>((ref) {
  final feedRepo = ref.watch(feedRepositoryProvider);
  final connectionRepo = ref.watch(connectionRepositoryProvider);
  return FeedNotifier(feedRepo, connectionRepo);
});

// Bookmarks Provider
final bookmarkedFeedProvider = Provider<AsyncValue<List<Post>>>((ref) {
  final feedState = ref.watch(feedProvider);
  return feedState.whenData((posts) => posts.where((p) => p.isBookmarked).toList());
});