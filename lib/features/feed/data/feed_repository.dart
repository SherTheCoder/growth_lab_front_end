import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/models/user_model.dart';
import '../domain/models.dart';

class FeedRepository {
  // 1. Base URL matches 'main.py' prefix (/api/v1)
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.growthlab.sg/api/v1',
    connectTimeout: const Duration(seconds: 15), // Increased timeout
    receiveTimeout: const Duration(seconds: 15),
  ));

  final _storage = const FlutterSecureStorage();

  Future<Options> _getOptions() async {
    final token = await _storage.read(key: 'auth_token');
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // --- POSTS ---

  Future<List<Post>> fetchPosts() async {
    try {
      final options = await _getOptions();
      // Endpoint: /feed/ (defined in feed.py router)
      final response = await _dio.get('/feed/', options: options);

      // Backend returns a paginated wrapper: { "posts": [], "total": 10, ... }
      // We need to extract the list from the "posts" key.
      final List<dynamic> postsJson = response.data['posts'];

      return postsJson.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Failed to fetch posts: $e");
    }
  }

  Future<Post> addPost(Post post) async {
    try {
      final options = await _getOptions();

      // Transform simple mediaUrls list into backend "attachments" schema
      List<Map<String, dynamic>> attachments = [];
      if (post.mediaUrls.isNotEmpty) {
        // Simple logic: if type is video, assume all are video, else image
        String type = post.type == PostContentType.video ? 'video' : 'image';

        attachments = post.mediaUrls.map((url) => {
          'postAttachmentType': type,
          'postAttachmentUrl': url,
          'postAttachmentTitle': 'Upload',
          'postAttachmentDescription': ''
        }).toList();
      }

      // Match 'PostCreate' schema from schemas_init_file.py
      final response = await _dio.post('/feed/posts', data: {
        'postContent': post.content,
        'postVisibility': 'public', // Default visibility
        'postHashTags': [],         // Can implement hashtag extraction later
        'attachments': attachments
      }, options: options);

      return Post.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to create post: $e");
    }
  }

  Future<String> uploadMedia(File file) async {
    if (kIsWeb) {
      throw Exception("Web upload not implemented yet (requires bytes/XFile)");
    }

    try {
      final options = await _getOptions();
      String fileName = file.path.split('/').last;

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      // Endpoint: /feed/upload
      final response = await _dio.post('/feed/upload', data: formData, options: options);

      // Backend returns { "url": "/uploads/posts/..." }
      return response.data['url'];
    } catch (e) {
      throw Exception("Failed to upload media: $e");
    }
  }

  // --- INTERACTIONS ---

  Future<void> toggleLike(String postId) async {
    try {
      final options = await _getOptions();
      // Endpoint: /feed/posts/{id}/like
      await _dio.post('/feed/posts/$postId/like', options: options);
    } catch (e) {
      throw Exception("Failed to like post: $e");
    }
  }

  Future<void> toggleBookmark(String postId) async {
    // Currently no "Save Post" endpoint in the provided feed.py
    // You might need to add one or use a different endpoint if available.
  }

  Future<void> toggleFollow(String postId) async {
    // Logic usually requires Author ID, which we'd get from the UI layer
    // Endpoint: /connections/follow/{user_id} (from connections.py)
    // To implement this properly, we need the user_id, not just post_id
  }

  Future<void> incrementCommentCount(String postId) async {
    // Handled by backend response
  }

  // --- COMMENTS ---

  Future<List<Comment>> fetchComments(String postId) async {
    try {
      final options = await _getOptions();
      // Endpoint: /feed/posts/{id}/comments
      final response = await _dio.get(
        '/feed/posts/$postId/comments',
        queryParameters: {'page': 1, 'limit': 20},
        options: options,
      );

      // FIX: Access the "comments" key first!
      final List list = response.data['comments'];

      return list.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      print("Fetch Comments Error: $e");
      return [];
    }
  }

  Future<Comment> addComment(String postId, String content, String parentId, User author) async {
    try {
      final options = await _getOptions();

      // Match 'CommentCreate' schema
      final data = {
        'commentContent': content,
        'parentCommentID': (parentId == "0" || parentId.isEmpty) ? null : int.parse(parentId)
      };

      final response = await _dio.post('/feed/posts/$postId/comments', data: data, options: options);

      return Comment.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to add comment: $e");
    }
  }

  // Stub methods for replies (backend treats replies same as comments, just with parentID)
  Future<List<Comment>> fetchReplies(String commentId) async { return []; }
  Future<List<Comment>> fetchRepliesByUser(String userId) async { return []; }
  Future<void> toggleCommentLike(String commentId) async {}
  Future<void> toggleCommentBookmark(String commentId) async {}
}