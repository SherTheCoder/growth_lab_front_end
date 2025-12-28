import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:growth_lab/core/models/user_model.dart';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  // 1. Live Base URL
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.growthlab.sg/api/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  final _storage = const FlutterSecureStorage();

  Future<User?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'emailAddress': email,
          'password': password,
        },
      );

      final data = response.data;
      final accessToken = data['access_token'];

      if (accessToken == null) {
        // This is a logic error, not a network error, so generic Exception is fine here.
        throw Exception("Server returned success but no token found.");
      }

      await _storage.write(key: 'auth_token', value: accessToken);
      return await _fetchUserProfile(accessToken);

    } on DioException catch (e) {
      // --- CRITICAL CHANGE ---
      // We print for debugging, but we RETHROW the original DioException
      // so the UI can read the status code (401, 422) and JSON body.
      print("Login Error: ${e.type} - ${e.message}");
      if (e.response != null) {
        print("Server Data: ${e.response?.data}");
      }
      rethrow; // <--- This allows the UI to see the real error
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> _fetchUserProfile(String token) async {
    try {
      final response = await _dio.get('/auth/me', options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ));
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> restoreSession() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) return await _fetchUserProfile(token);
    } catch (e) {
      // If session restore fails (e.g. token expired), we just return null silently
      print("Session restore failed: $e");
    }
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
      // Signup success usually doesn't return a token immediately in some APIs,
      // but if yours does, you could handle it here.
      // For now, we assume success means "Go to Login" or "Check Email".
    } on DioException catch (e) {
      print("Signup Error: ${e.response?.statusCode}");
      print("Signup Data: ${e.response?.data}");
      rethrow; // <--- Critical: Allows UI to catch 422/409 errors
    } catch (e) {
      rethrow;
    }
  }
}