import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/models/user_model.dart';

class ConnectionRepository {
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

  // Matches connections.py: @router.post("/follow/{user_id}")
  Future<void> toggleFollow(String userId) async {
    try {
      final options = await _getOptions();
      await _dio.post('/connections/follow/$userId', options: options);
    } catch (e) {
      throw Exception("Failed to update follow status: $e");
    }
  }

  // Matches connections.py: @router.get("/recommendations")
  Future<List<User>> getRecommendations() async {
    try {
      final options = await _getOptions();
      final response = await _dio.get('/connections/recommendations', options: options);

      // Backend returns List<dict>
      return (response.data as List).map((json) => User.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}