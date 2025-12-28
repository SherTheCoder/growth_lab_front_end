import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growth_lab/core/models/user_model.dart';
import '../../data/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final user = await _repository.restoreSession();
      state = AsyncValue.data(user);
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e) {
      // FIX: Reset to "Logged Out" (null) instead of "Error".
      // This prevents the MainWrapper from rebuilding/disposing the LoginScreen.
      state = const AsyncValue.data(null);
      rethrow;
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
      await _repository.completeSignup(email, phone, password, firstName, lastName);
      // Keep them on Auth screen (null) but stop loading spinner
      state = const AsyncValue.data(null);
    } catch (e) {
      // FIX: Reset to data(null) here too
      state = const AsyncValue.data(null);
      rethrow;
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