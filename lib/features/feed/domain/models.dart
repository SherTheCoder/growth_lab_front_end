import 'package:growth_lab/core/models/user_model.dart';

enum PostContentType { text, image, video, document, carousel }

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
    // 1. Extract Attachments
    List<String> urls = [];
    PostContentType derivedType = PostContentType.text;

    if (json['attachments'] != null && (json['attachments'] as List).isNotEmpty) {
      final list = json['attachments'] as List;
      final firstAtt = list.first;

      // Determine type from backend "IMAGE", "VIDEO" strings
      final typeStr = firstAtt['postAttachmentType']?.toString().toUpperCase() ?? 'DOCUMENT';
      if (typeStr == 'IMAGE') derivedType = PostContentType.image;
      else if (typeStr == 'VIDEO') derivedType = PostContentType.video;

      // Extract URLs
      urls = list.map((e) => e['postAttachmentUrl'].toString()).toList();
    }

    return Post(
      id: json['id']?.toString() ?? '',
      author: User.fromJson(json['author'] ?? {}),
      // Backend uses 'postContent'
      content: json['postContent'] ?? '',
      type: derivedType,
      mediaUrls: urls,
      timestamp: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      // Backend uses 'likesCount', 'commentsCount'
      upvotes: json['likesCount'] ?? 0,
      comments: json['commentsCount'] ?? 0,
      reposts: json['sharesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isSaved'] ?? false, // Backend uses 'isSaved'
      isFollowing: false, // Not provided by backend yet, default to false
    );
  }

  // copyWith remains the same (omitted for brevity)
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

class Comment {
  final String id;
  final User author;
  final String content;
  final int upvotes;
  final int replyCount;
  final bool isLiked;
  final bool isBookmarked;
  final String timestamp;
  final String postId;
  final String parentCommentId;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.upvotes,
    required this.replyCount,
    this.isLiked = false,
    this.isBookmarked = false,
    required this.timestamp,
    required this.postId,
    this.parentCommentId = "0",
    this.replies = const [],
  });

  // 1. JSON Parsing (Maps API keys to Model keys)
  factory Comment.fromJson(Map<String, dynamic> json) {
    var replyList = <Comment>[];
    if (json['replies'] != null) {
      replyList = (json['replies'] as List)
          .map((r) => Comment.fromJson(r))
          .toList();
    }

    return Comment(
      id: json['id']?.toString() ?? '',
      author: User.fromJson(json['author'] ?? {}),
      content: json['commentContent'] ?? '',         // Map commentContent
      upvotes: json['commentLikeCount'] ?? 0,        // Map commentLikeCount
      replyCount: replyList.length,
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isSaved'] ?? false,
      timestamp: json['createdAt'] ?? '',
      postId: json['postID']?.toString() ?? '',
      parentCommentId: json['parentCommentID']?.toString() ?? "0",
      replies: replyList,
    );
  }

  // 2. CopyWith Method (For Immutable Updates)
  Comment copyWith({
    String? id,
    User? author,
    String? content,
    int? upvotes,
    int? replyCount,
    bool? isLiked,
    bool? isBookmarked,
    String? timestamp,
    String? postId,
    String? parentCommentId,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      replyCount: replyCount ?? this.replyCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      timestamp: timestamp ?? this.timestamp,
      postId: postId ?? this.postId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replies: replies ?? this.replies,
    );
  }
}