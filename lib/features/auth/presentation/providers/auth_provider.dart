import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growth_lab/core/models/user_model.dart';


// Uncomment real ones when testing with real backend
import '../../data/auth_repository.dart';
// import '../../data/mock_auth_repo.dart';


final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _checkLoginStatus(); // Check for existing token on startup
  }

  Future<void> _checkLoginStatus() async {
    try {
      final user = await _repository.restoreSession();
      state = AsyncValue.data(user);
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  // ... login and signUp methods remain similar, just ensuring they call the updated repository methods ...
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      // For demo purposes, we auto-login after "verification"
      final user = await _repository.completeSignup(email, phone, password, firstName, lastName);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});