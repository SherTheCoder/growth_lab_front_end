import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/models/user_model.dart';
import '../domain/models.dart';
import 'dart:io';

class FeedRepository {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));
  final _storage = const FlutterSecureStorage();

  // Upload Media Method
  Future<String> uploadMedia(File file) async {
    try {
      final options = await _getOptions();

      String fileName = file.path.split('/').last;

      // Create FormData for file upload
      // Adjust "file" to match the key your backend expects (e.g., 'image', 'media')
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      // Assuming your endpoint is '/upload'. Change this to your actual endpoint.
      final response = await _dio.post('/upload', data: formData, options: options);

      // Assuming backend returns JSON like: { "url": "https://..." }
      // If it returns a plain string, use: return response.data.toString();
      return response.data['url'];
    } catch (e) {
      throw Exception("Failed to upload media: $e");
    }
  }

  // Helper to get headers with Auth Token
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
      // Assumes GET /posts returns a list of post objects
      final response = await _dio.get('/posts', options: options);

      return (response.data as List)
          .map((json) => Post.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch posts: $e");
    }
  }

  Future<Post> addPost(Post post) async {
    try {
      final options = await _getOptions();
      // We send the content and type. The backend should handle ID, timestamp, and author.
      final response = await _dio.post('/posts', data: {
        'content': post.content,
        'type': post.type.name,
        'media_urls': post.mediaUrls,
      }, options: options);

      return Post.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to create post: $e");
    }
  }

  // --- INTERACTIONS ---

  Future<void> toggleLike(String postId) async {
    try {
      final options = await _getOptions();
      await _dio.post('/posts/$postId/like', options: options);
    } catch (e) {
      throw Exception("Failed to like post: $e");
    }
  }

  Future<void> toggleBookmark(String postId) async {
    try {
      final options = await _getOptions();
      await _dio.post('/posts/$postId/bookmark', options: options);
    } catch (e) {
      throw Exception("Failed to bookmark post: $e");
    }
  }

  Future<void> toggleFollow(String postId) async {
    try {
      final options = await _getOptions();
      // Assuming you follow the AUTHOR of the post
      await _dio.post('/posts/$postId/follow_author', options: options);
    } catch (e) {
      throw Exception("Failed to follow user: $e");
    }
  }

  Future<void> incrementCommentCount(String postId) async {
    // Usually handled by the backend automatically when a comment is added.
    // We can leave this empty or remove it if the UI updates optimistically.
  }

  // --- COMMENTS ---

  Future<List<Comment>> fetchComments(String postId) async {
    try {
      final options = await _getOptions();
      final response = await _dio.get('/posts/$postId/comments', options: options);

      return (response.data as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } catch (e) {
      // Return empty list on error or handle differently
      return [];
    }
  }

  Future<List<Comment>> fetchReplies(String commentId) async {
    try {
      final options = await _getOptions();
      final response = await _dio.get('/comments/$commentId/replies', options: options);

      return (response.data as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Comment>> fetchRepliesByUser(String userId) async {
    try {
      final options = await _getOptions();
      final response = await _dio.get('/users/$userId/replies', options: options);

      return (response.data as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Comment> addComment(String postId, String content, String parentId, User author) async {
    try {
      final options = await _getOptions();
      // parentId "0" means top-level comment
      final response = await _dio.post('/posts/$postId/comments', data: {
        'content': content,
        'parent_comment_id': parentId == "0" ? null : parentId,
      }, options: options);

      return Comment.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to add comment: $e");
    }
  }

  Future<void> toggleCommentLike(String commentId) async {
    try {
      final options = await _getOptions();
      await _dio.post('/comments/$commentId/like', options: options);
    } catch (e) {
      throw Exception("Failed to like comment: $e");
    }
  }

  Future<void> toggleCommentBookmark(String commentId) async {
    try {
      final options = await _getOptions();
      await _dio.post('/comments/$commentId/bookmark', options: options);
    } catch (e) {
      throw Exception("Failed to bookmark comment: $e");
    }
  }
}