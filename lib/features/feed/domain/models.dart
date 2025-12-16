import 'package:growth_lab/core/models/user_model.dart';

/// Represents the type of content in a post
enum PostContentType { text, image, carousel, video }

/// Domain model for a User


/// Domain model for a Feed Post
// ... inside lib/features/feed/domain/models.dart

// 1. Update PostContentType to handle String parsing if needed,
// or you can handle it inside the Post.fromJson

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

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      // Ensure the 'author' field in JSON is a full user object, or adapt accordingly
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String,
      // Simple parsing assuming backend sends "text", "image", etc.
      type: PostContentType.values.firstWhere(
              (e) => e.name == (json['type'] as String),
          orElse: () => PostContentType.text
      ),
      mediaUrls: (json['media_urls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      timestamp: DateTime.parse(json['timestamp'] as String),
      upvotes: json['upvotes'] ?? 0,
      comments: json['comments'] ?? 0,
      reposts: json['reposts'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isBookmarked: json['is_bookmarked'] ?? false,
      isFollowing: json['is_following'] ?? false,
    );
  }

  // Optional: toJson if you need to send a full post object back (rare for feeds)
  // copyWith remains the same...
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
  final String postId;
  final User author;
  final String content;
  final DateTime timestamp;

  final int upvotes;
  final int replyCount;
  final bool isLiked;
  final bool isBookmarked;
  final String parentCommentId;

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

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      upvotes: json['upvotes'] ?? 0,
      replyCount: json['reply_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isBookmarked: json['is_bookmarked'] ?? false,
      parentCommentId: json['parent_comment_id']?.toString() ?? "0",
    );
  }

  // copyWith remains the same...
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