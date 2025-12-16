import 'package:growth_lab/core/models/user_model.dart';

class AuthRepository {
  // Simulates a network delay
  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return _getMockUser();
  }

  // Called on app start - returns user to bypass login screen
  Future<User?> restoreSession() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _getMockUser();
  }

  Future<void> completeSignup(String email, String phone, String password, String firstName, String lastName) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> logout() async {
    // In a real app, delete token here
  }

  User _getMockUser() {
    return const User(
      id: 'mock_me',
      name: 'Test User',
      username: '@tester',
      avatarUrl: 'https://i.pravatar.cc/150?u=me', // Random avatar
      headline: 'Flutter Developer & Dreamer',
      location: 'New York, USA',
      isVerified: true,
    );
  }
}