import '../../feed/domain/models.dart'; // Reusing User model

// Mock user for successful login
final _mockUser = User(
  id: 'me',
  name: 'Anoptional Handle',
  username: '@anoptionalhandle',
  avatarUrl: 'https://i.pravatar.cc/150?u=me',
  headline: 'Product Designer',
  location: 'Singapore',
  isVerified: true,
);

class AuthRepository {
  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API
    if (email.isNotEmpty && password.isNotEmpty) {
      return _mockUser;
    }
    throw Exception("Invalid credentials");
  }

  Future<void> sendVerificationEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<User?> completeSignup(String email, String phone, String password, String firstName, String lastName) async {
    await Future.delayed(const Duration(seconds: 1));
    // Return a new user object based on input
    return User(
      id: 'new_user',
      name: "$firstName $lastName",
      username: "@${firstName.toLowerCase()}",
      avatarUrl: 'https://i.pravatar.cc/150?u=new',
      headline: 'New Member',
      location: 'Unknown',
    );
  }
}