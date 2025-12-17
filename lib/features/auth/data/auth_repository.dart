import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:growth_lab/core/models/user_model.dart';

class AuthRepository {
  // 1. Live Base URL (Must be HTTPS)
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.growthlab.sg/api/v1',
    connectTimeout: const Duration(seconds: 15), // Increased timeout
    receiveTimeout: const Duration(seconds: 15),
  ));

  final _storage = const FlutterSecureStorage();

  Future<User?> login(String email, String password) async {
    try {
      // 2. Endpoint becomes: https://api.growthlab.sg/api/v1/auth/login
      final response = await _dio.post(
        '/auth/login',
        data: {
          'emailAddress': email,
          'password': password,
        },
      );

      // 3. Parse the specific JSON format you provided
      final data = response.data;
      final accessToken = data['access_token'];

      if (accessToken == null) {
        throw Exception("Server returned success but no token found.");
      }

      // Save token securely
      await _storage.write(key: 'auth_token', value: accessToken);

      // 4. Fetch User Profile immediately after login
      return await _fetchUserProfile(accessToken);

    } on DioException catch (e) {
      // Debugging: Print the exact error to console
      print("Login Error: ${e.type} - ${e.message}");
      if (e.response != null) {
        print("Server Data: ${e.response?.data}");
        if (e.response?.statusCode == 401) {
          throw Exception("Incorrect email or password.");
        }
      }
      throw Exception("Connection failed. Check your internet or server status.");
    } catch (e) {
      throw Exception("Login error: ${e.toString()}");
    }
  }

  Future<User?> _fetchUserProfile(String token) async {
    try {
      // Endpoint: https://api.growthlab.sg/api/v1/auth/me
      final response = await _dio.get('/auth/me', options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ));
      return User.fromJson(response.data);
    } catch (e) {
      print("Profile Fetch Error: $e");
      return null;
    }
  }

  // ... (Keep restoreSession, logout, completeSignup as they were) ...
  Future<User?> restoreSession() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) return await _fetchUserProfile(token);
    return null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<void> completeSignup(String email, String phone, String password, String firstName, String lastName) async {
    try {
      await _dio.post('/auth/register', data: {
        'emailAddress': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phone,
      });
    } catch (e) {
      throw Exception("Signup failed: ${e.toString()}");
    }
  }
}