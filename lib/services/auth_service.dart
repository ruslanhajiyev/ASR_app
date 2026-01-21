import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import 'mock_backend_service.dart';
import 'logging_service.dart';

class AuthService {
  final MockBackendService _backend;
  final FlutterSecureStorage _storage;
  final LoggingService _logger = LoggingService();
  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';

  AuthService({
    MockBackendService? backend,
    FlutterSecureStorage? storage,
  })  : _backend = backend ?? MockBackendService(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<AuthResponse> register({
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      await _logger.info(
        category: 'auth',
        message: 'Registration attempt',
        metadata: {'username': username},
      );

      final response = await _backend.register(
        username: username,
        password: password,
        email: email,
      );

      await _saveTokens(response.accessToken, response.user.id);
      
      await _logger.info(
        category: 'auth',
        message: 'Registration successful',
        metadata: {'userId': response.user.id, 'username': username},
      );

      return response;
    } catch (e, stackTrace) {
      await _logger.error(
        category: 'auth',
        message: 'Registration failed',
        metadata: {'username': username},
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      await _logger.info(
        category: 'auth',
        message: 'Login attempt',
        metadata: {'username': username},
      );

      final response = await _backend.login(
        username: username,
        password: password,
      );

      await _saveTokens(response.accessToken, response.user.id);
      
      await _logger.info(
        category: 'auth',
        message: 'Login successful',
        metadata: {'userId': response.user.id, 'username': username},
      );

      return response;
    } catch (e, stackTrace) {
      await _logger.error(
        category: 'auth',
        message: 'Login failed',
        metadata: {'username': username},
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _backend.logout(token);
      }
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userIdKey);
      
      await _logger.info(
        category: 'auth',
        message: 'Logout successful',
      );
    } catch (e, stackTrace) {
      await _logger.error(
        category: 'auth',
        message: 'Logout failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<User?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      return await _backend.getCurrentUser(token);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;

    final user = await getCurrentUser();
    return user != null;
  }

  Future<void> _saveTokens(String token, String userId) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
  }
}

