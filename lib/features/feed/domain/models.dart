/// Represents the type of content in a post
enum PostContentType { text, image, carousel, video }

/// Domain model for a User
class User {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final String headline;
  final String location;
  final bool isVerified;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.headline,
    required this.location,
    this.isVerified = false,
  });
}

/// Domain model for a Feed Post
class Post {
  final String id;
  final User author;
  final String content;
  final PostContentType type;
  final List<String> mediaUrls;
  final DateTime timestamp;

  final int upvotes;
  final int comments;
  final int reposts;

  final bool isLiked;
  final bool isBookmarked;
  final bool isFollowing;

  const Post({
    required this.id,
    required this.author,
    required this.content,
    required this.type,
    this.mediaUrls = const [],
    required this.timestamp,
    this.upvotes = 0,
    this.comments = 0,
    this.reposts = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.isFollowing = false,
  });

  Post copyWith({
    String? id,
    User? author,
    String? content,
    PostContentType? type,
    List<String>? mediaUrls,
    DateTime? timestamp,
    int? upvotes,
    int? comments,
    int? reposts,
    bool? isLiked,
    bool? isBookmarked,
    bool? isFollowing,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      timestamp: timestamp ?? this.timestamp,
      upvotes: upvotes ?? this.upvotes,
      comments: comments ?? this.comments,
      reposts: reposts ?? this.reposts,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

/// Domain model for a Comment
class Comment {
  final String id;
  final String postId; // The ID of the root post
  final User author;
  final String content;
  final DateTime timestamp;

  final int upvotes;
  final int replyCount; // Number of replies to this comment
  final bool isLiked;
  final bool isBookmarked;

  // Threading logic
  final String parentCommentId; // "0" if top-level, otherwise the ID of the comment being replied to

  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.timestamp,
    this.upvotes = 0,
    this.replyCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.parentCommentId = "0",
  });

  Comment copyWith({
    String? id,
    String? postId,
    User? author,
    String? content,
    DateTime? timestamp,
    int? upvotes,
    int? replyCount,
    bool? isLiked,
    bool? isBookmarked,
    String? parentCommentId,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      author: author ?? this.author,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      upvotes: upvotes ?? this.upvotes,
      replyCount: replyCount ?? this.replyCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      parentCommentId: parentCommentId ?? this.parentCommentId,
    );
  }
}