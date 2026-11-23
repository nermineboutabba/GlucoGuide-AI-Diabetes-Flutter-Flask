import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/local_storage.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'glucose_history_provider.dart';

final apiServiceProvider = Provider((ref) => ApiService());
final localStorageProvider = Provider((ref) => LocalStorage());

final authServiceProvider = Provider((ref) {
  return AuthService(ref.read(apiServiceProvider));
});

class AuthState {
  final bool isLoading;
  final String? error;
  final String? token;

  AuthState({this.isLoading = false, this.error, this.token});

  AuthState copyWith({bool? isLoading, String? error, String? token}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;
  final Ref ref;

  AuthNotifier(this.authService, this.ref) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await authService.login(email, password);

      await ref.read(localStorageProvider).saveUser(
        response['token'],
        response['email'],
        response['first_name'],
        response['last_name'],
      );

      await ref.read(glucoseHistoryProvider.notifier).loadFromBackend(
        response['email'],
        ref.read(apiServiceProvider),
      );

      state = state.copyWith(
        isLoading: false,
        token: response['token'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register(
      String firstName,
      String lastName,
      String email,
      String password,
      String confirmPassword,
      ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await authService.register(
        firstName,
        lastName,
        email,
        password,
        confirmPassword,
      );

      state = state.copyWith(isLoading: false);

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final authProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref,
  );
});