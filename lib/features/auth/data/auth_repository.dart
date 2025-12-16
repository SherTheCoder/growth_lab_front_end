import 'package:growth_lab/core/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  // Configure Dio with your backend URL
  // Android Emulator uses 10.0.2.2 instead of localhost
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));
  final _storage = const FlutterSecureStorage();

  Future<User?> login(String email, String password) async {
    try {
      // 1. Send Login Request (usually returns a Token + User)
      // Adjust form-data vs json based on your FastAPI implementation (OAuth2PasswordRequestForm uses form-data)
      final response = await _dio.post('/token', data: {
        'username': email, // FastAPI OAuth2 expects 'username', not 'email'
        'password': password,
      }, options: Options(contentType: Headers.formUrlEncodedContentType));

      // 2. Extract Data
      final accessToken = response.data['access_token'];

      // 3. Store Token securely
      await _storage.write(key: 'auth_token', value: accessToken);

      // 4. Fetch/Return User Profile
      // You often need a separate call to get the user details using the token
      return await _fetchUserProfile(accessToken);

    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  Future<User?> _fetchUserProfile(String token) async {
    try {
      final response = await _dio.get('/users/me', options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ));
      return User.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<void> completeSignup(String email, String phone, String password, String firstName, String lastName) async {
    try {
      // 1. Send Signup Request
      await _dio.post('/users', data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      });

      // 2. Auto-login after signup
      return;
    } catch (e) {
      throw Exception("Signup failed: ${e.toString()}");
    }
  }

  // Optional: Check if user is already logged in when app starts
  Future<User?> restoreSession() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      return await _fetchUserProfile(token);
    }
    return null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}
