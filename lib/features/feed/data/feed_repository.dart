import '../domain/models.dart';

// --- SHARED MOCK DATA STORE ---
final List<Post> _globalPosts = [
  Post(
    id: 'p1',
    author: const User(
        id: 'u1',
        name: 'Sabeen Sohail',
        username: '@sabeen',
        avatarUrl: 'https://i.pravatar.cc/150?u=sabeen',
        headline: 'Founder',
        location: 'Pakistan',
        isVerified: true),
    content: "💙 Insights from the Community...",
    type: PostContentType.text,
    timestamp: DateTime.now().subtract(const Duration(hours: 10)),
    upvotes: 5,
    comments: 2,
    reposts: 0,
  ),
];

final List<Comment> _globalComments = [
Comment(
  id: 'c_new_1',
  postId: 'p1', // ID of the post it belongs to
  author: const User(
    id: 'u_new_1',
    name: 'Sarah Jenkins',
    username: '@sarahj',
    avatarUrl: 'https://i.pravatar.cc/150?u=sarah',
    headline: 'Tech Lead',
    location: 'Canada',
    isVerified: true,
  ),
  content: "This is exactly the kind of innovation we need right now. Great work!",
  timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
  upvotes: 15,
  replyCount: 0,
  isLiked: true,
  isBookmarked: false,
  parentCommentId: "0", // "0" indicates it is a top-level comment
),
Comment(
  id: 'c_new_2',
  postId: 'p1',
  author: const User(
    id: 'u_new_2',
    name: 'David Chen',
    username: '@dchen',
    avatarUrl: 'https://i.pravatar.cc/150?u=david',
    headline: 'Investor',
    location: 'Singapore',
    isVerified: false,
  ),
  content: "Could you elaborate on the second point? I find that fascinating.",
  timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
  upvotes: 3,
  replyCount: 0,
  isLiked: false,
  isBookmarked: true,
  parentCommentId: "c1", // ID of the comment being replied to
)
];

class FeedRepository {
  Future<List<Post>> fetchPosts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_globalPosts);
  }

  Future<Post> addPost(Post post) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _globalPosts.insert(0, post);
    return post;
  }

  // --- NEW: Interaction Methods ---

  Future<void> toggleLike(String postId) async {
    final index = _globalPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _globalPosts[index];
      final isLiked = !post.isLiked;
      _globalPosts[index] = post.copyWith(
        isLiked: isLiked,
        upvotes: post.upvotes + (isLiked ? 1 : -1),
      );
    }
  }

  Future<void> toggleBookmark(String postId) async {
    final index = _globalPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _globalPosts[index];
      _globalPosts[index] = post.copyWith(isBookmarked: !post.isBookmarked);
    }
  }

  Future<void> toggleFollow(String postId) async {
    final index = _globalPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _globalPosts[index];
      _globalPosts[index] = post.copyWith(isFollowing: !post.isFollowing);
    }
  }

  Future<void> incrementCommentCount(String postId) async {
    final index = _globalPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _globalPosts[index];
      _globalPosts[index] = post.copyWith(comments: post.comments + 1);
    }
  }

  // --- Comments Logic ---

  Future<List<Comment>> fetchComments(String postId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _globalComments.where((c) => c.postId == postId && c.parentCommentId == "0").toList();
  }

  Future<List<Comment>> fetchReplies(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _globalComments.where((c) => c.parentCommentId == commentId).toList();
  }

  Future<List<Comment>> fetchRepliesByUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _globalComments.where((c) => c.author.id == userId).toList();
  }

  Future<Comment> addComment(String postId, String content, String parentId, User author) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      author: author,
      content: content,
      timestamp: DateTime.now(),
      parentCommentId: parentId,
      replyCount: 0,
    );
    _globalComments.add(newComment);
    return newComment;
  }
}