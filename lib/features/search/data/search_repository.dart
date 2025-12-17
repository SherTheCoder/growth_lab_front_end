import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/models/user_model.dart';
import '../../feed/domain/models.dart';

class SearchRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.growthlab.sg/api/v1',
    connectTimeout: const Duration(seconds: 15), // Increased timeout
    receiveTimeout: const Duration(seconds: 15),
  ));

  final _storage = const FlutterSecureStorage();

  Future<Options> _getOptions() async {
    final token = await _storage.read(key: 'auth_token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Matches search.py: @router.get("/users")
  Future<List<User>> searchUsers(String query) async {
    try {
      final options = await _getOptions();
      final response = await _dio.get('/search/users',
          queryParameters: {'q': query, 'size': 20},
          options: options
      );

      // Response wrapper: { "users": [...], "total": ... }
      final List list = response.data['users'];
      return list.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Matches search.py: @router.get("/posts")
  // Useful for Profile Screen to fetch posts by specific author!
  Future<List<Post>> fetchUserPosts(String userId) async {
    try {
      final options = await _getOptions();

      // 1. URL: Dynamic path /users/{id}/posts
      final response = await _dio.get(
        '/users/$userId/posts',
        queryParameters: {
          'page': 1,
          'limit': 20
        },
        options: options,
      );

      // 2. Parse: The API returns { "posts": [ ... ] }
      // We access the 'posts' key first.
      final List list = response.data['posts'];

      // 3. Convert: Since the keys (postContent, author, etc.) match your Model,
      // .fromJson works automatically.
      return list.map((json) => Post.fromJson(json)).toList();

    } catch (e) {
      print("Error fetching user posts: $e");
      return [];
    }
  }
}