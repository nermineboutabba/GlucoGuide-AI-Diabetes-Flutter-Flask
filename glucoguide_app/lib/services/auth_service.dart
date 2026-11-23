import 'api_service.dart';

class AuthService {
  final ApiService api;

  AuthService(this.api);

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await api.post('/login', {
      "email": email,
      "password": password,
    });
  }

  Future<void> register(
      String firstName,
      String lastName,
      String email,
      String password,
      String confirmPassword,
      ) async {
    await api.post('/register', {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "password": password,
      "confirm_password": confirmPassword,
    });
  }
}