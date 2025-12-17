import 'dart:io';
import '../../../core/models/user_model.dart';
import '../domain/models.dart';

class FeedRepository {
  // MOCK: Fetch Posts
  Future<List<Post>> fetchPosts() async {
    await Future.delayed(const Duration(seconds: 1)); // Fake loading

    return [
      Post(
        id: '1',
        author: const User(
            id: 'u1',
            name: 'GrowthLab Official',
            username: '@growthlab',
            avatarUrl: 'https://i.pravatar.cc/150?u=growth',
            headline: 'Community',
            location: 'Global',
            isVerified: true
        ),
        content: "Welcome to the new GrowthLab! We've updated our look with a fresh Teal & Navy theme. Let us know what you think! 🚀 #update #design",
        type: PostContentType.text,
        timestamp: DateTime.now(),
        upvotes: 1240,
        comments: 45,
        isLiked: true,
        isBookmarked: false,
        isFollowing: true,
      ),
      Post(
        id: '2',
        author: const User(
            id: 'u2',
            name: 'Sarah Connor',
            username: '@sarah_tech',
            avatarUrl: 'https://i.pravatar.cc/150?u=sarah',
            headline: 'AI Researcher',
            location: 'San Francisco',
            isVerified: false
        ),
        content: "Just finished a marathon coding session. The sunrise is beautiful today.",
        type: PostContentType.image,
        mediaUrls: ['https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&w=800&q=80'],
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        upvotes: 89,
        comments: 12,
        isLiked: false,
        isBookmarked: true,
        isFollowing: false,
      ),
      Post(
        id: '3',
        author: const User(
          id: 'u3',
          name: 'David Miller',
          username: '@davidm',
          avatarUrl: 'https://i.pravatar.cc/150?u=david',
          headline: 'Founder @ StartUp',
          location: 'Berlin',
        ),
        content: "Looking for co-founders for a new fintech project. DM me if interested!",
        type: PostContentType.text,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        upvotes: 34,
        comments: 5,
        isLiked: false,
        isBookmarked: false,
        isFollowing: false,
      ),
    ];
  }

  // MOCK: Add Post
  Future<Post> addPost(Post post) async {
    await Future.delayed(const Duration(seconds: 1));
    // Return the post as if the backend created it successfully
    return post.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
  }

  // MOCK: Upload Media
  Future<String> uploadMedia(File file) async {
    await Future.delayed(const Duration(seconds: 1));
    return "https://picsum.photos/400/300"; // Return a dummy image URL
  }

  // MOCK: Interactions (Do nothing, just simulate success)
  Future<void> toggleLike(String postId) async {}
  Future<void> toggleBookmark(String postId) async {}
  Future<void> toggleFollow(String postId) async {}
  Future<void> incrementCommentCount(String postId) async {}

  // MOCK: Comments
  Future<List<Comment>> fetchComments(String postId) async { return []; }
  Future<List<Comment>> fetchReplies(String commentId) async { return []; }
  Future<List<Comment>> fetchRepliesByUser(String userId) async { return []; }

  Future<Comment> addComment(String postId, String content, String parentId, User author) async {
    return Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      author: author,
      content: content,
      timestamp: "12",
      replyCount: 2,
      parentCommentId: parentId, upvotes: 0,
    );
  }
  Future<void> toggleCommentLike(String commentId) async {}
  Future<void> toggleCommentBookmark(String commentId) async {}
}