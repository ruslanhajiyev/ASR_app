import 'package:flutter_test/flutter_test.dart';
import 'package:asr_app/services/auth_service.dart';
import 'package:asr_app/services/mock_backend_service.dart';
import 'package:asr_app/models/models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([MockBackendService, FlutterSecureStorage])
import 'auth_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService', () {
    late AuthService authService;
    late MockMockBackendService mockBackend;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockBackend = MockMockBackendService();
      mockStorage = MockFlutterSecureStorage();
      authService = AuthService(
        backend: mockBackend,
        storage: mockStorage,
      );
    });

    test('should register a new user successfully', () async {
      final mockUser = User(
        id: 'user-123',
        username: 'testuser',
        email: 'test@example.com',
      );
      final mockResponse = AuthResponse(
        accessToken: 'token-123',
        user: mockUser,
      );

      when(mockBackend.register(
        username: 'testuser',
        password: 'Password123!',
        email: 'test@example.com',
      )).thenAnswer((_) async => mockResponse);

      when(mockStorage.write(
        key: 'access_token',
        value: 'token-123',
      )).thenAnswer((_) async => {});

      when(mockStorage.write(
        key: 'user_id',
        value: 'user-123',
      )).thenAnswer((_) async => {});

      final result = await authService.register(
        username: 'testuser',
        password: 'Password123!',
        email: 'test@example.com',
      );

      expect(result.user.id, 'user-123');
      expect(result.user.username, 'testuser');
      expect(result.accessToken, 'token-123');
      verify(mockStorage.write(key: 'access_token', value: 'token-123')).called(1);
      verify(mockStorage.write(key: 'user_id', value: 'user-123')).called(1);
    });

    test('should login successfully', () async {
      final mockUser = User(
        id: 'user-123',
        username: 'testuser',
        email: 'test@example.com',
      );
      final mockResponse = AuthResponse(
        accessToken: 'token-123',
        user: mockUser,
      );

      when(mockBackend.login(
        username: 'testuser',
        password: 'Password123!',
      )).thenAnswer((_) async => mockResponse);

      when(mockStorage.write(
        key: 'access_token',
        value: 'token-123',
      )).thenAnswer((_) async => {});

      when(mockStorage.write(
        key: 'user_id',
        value: 'user-123',
      )).thenAnswer((_) async => {});

      final result = await authService.login(
        username: 'testuser',
        password: 'Password123!',
      );

      expect(result.user.id, 'user-123');
      expect(result.accessToken, 'token-123');
      verify(mockStorage.write(key: 'access_token', value: 'token-123')).called(1);
    });

    test('should throw exception on registration failure', () async {
      when(mockBackend.register(
        username: 'testuser',
        password: 'Password123!',
        email: 'test@example.com',
      )).thenThrow(Exception('Registration failed'));

      expect(
        () => authService.register(
          username: 'testuser',
          password: 'Password123!',
          email: 'test@example.com',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception on login failure', () async {
      when(mockBackend.login(
        username: 'testuser',
        password: 'wrongpassword',
      )).thenThrow(Exception('Invalid credentials'));

      expect(
        () => authService.login(
          username: 'testuser',
          password: 'wrongpassword',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should get token from storage', () async {
      when(mockStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'stored-token');

      final token = await authService.getToken();
      expect(token, 'stored-token');
    });

    test('should return null when no token stored', () async {
      when(mockStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);

      final token = await authService.getToken();
      expect(token, isNull);
    });

    test('should get user ID from storage', () async {
      when(mockStorage.read(key: 'user_id'))
          .thenAnswer((_) async => 'user-123');

      final userId = await authService.getUserId();
      expect(userId, 'user-123');
    });

    test('should return null when no user ID stored', () async {
      when(mockStorage.read(key: 'user_id'))
          .thenAnswer((_) async => null);

      final userId = await authService.getUserId();
      expect(userId, isNull);
    });

    test('should check if user is authenticated', () async {
      when(mockStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'token-123');

      final isAuthenticated = await authService.isAuthenticated();
      expect(isAuthenticated, isTrue);
      verify(mockStorage.read(key: 'access_token')).called(greaterThanOrEqualTo(1));
    });

    test('should return false when not authenticated', () async {
      when(mockStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);

      final isAuthenticated = await authService.isAuthenticated();
      expect(isAuthenticated, isFalse);
    });

    test('should logout and clear tokens', () async {
      when(mockStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);
      when(mockStorage.delete(key: 'access_token'))
          .thenAnswer((_) async => {});
      when(mockStorage.delete(key: 'user_id'))
          .thenAnswer((_) async => {});

      await authService.logout();

      verify(mockStorage.delete(key: 'access_token')).called(1);
      verify(mockStorage.delete(key: 'user_id')).called(1);
    });
  });
}
