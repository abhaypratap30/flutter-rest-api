import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_rest_api/core/models/auth_model.dart';
import 'package:flutter_rest_api/core/models/user_model.dart';
import 'package:flutter_rest_api/core/network/api_client.dart';
import 'package:flutter_rest_api/core/network/api_response.dart';
import 'package:flutter_rest_api/core/repositories/auth_repository.dart';
import 'package:flutter_rest_api/core/services/storage_service.dart';

class MockApiClient extends Mock implements IApiClient {}
class MockStorageService extends Mock implements IStorageService {}

void main() {
  late MockApiClient mockApiClient;
  late MockStorageService mockStorageService;
  late AuthRepository authRepository;

  setUp(() {
    mockApiClient = MockApiClient();
    mockStorageService = MockStorageService();
    authRepository = AuthRepository(
      apiClient: mockApiClient,
      storageService: mockStorageService,
    );
  });

  group('AuthRepository Unit Tests', () {
    const loginRequest = LoginRequest(username: 'emilys', password: 'emilyspass');
    const mockUser = UserModel(
      id: 1,
      firstName: 'Emily',
      lastName: 'Smith',
      email: 'emily@example.com',
      username: 'emilys',
    );
    const mockTokens = AuthTokens(accessToken: 'access_123', refreshToken: 'refresh_123');
    const mockAuthResponse = AuthResponse(user: mockUser, tokens: mockTokens);

    test('login success saves tokens and user data', () async {
      when(() => mockApiClient.post<AuthResponse>(
            any(),
            data: any(named: 'data'),
            decoder: any(named: 'decoder'),
          )).thenAnswer((_) async => ApiResult.success(mockAuthResponse));

      when(() => mockStorageService.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});

      when(() => mockStorageService.saveUserData(any())).thenAnswer((_) async {});

      final result = await authRepository.login(loginRequest);

      expect(result.isSuccess, isTrue);
      expect(result.data?.user.username, equals('emilys'));
      verify(() => mockStorageService.saveTokens(accessToken: 'access_123', refreshToken: 'refresh_123')).called(1);
    });

    test('logout clears tokens and storage', () async {
      when(() => mockStorageService.clearAll()).thenAnswer((_) async {});

      final result = await authRepository.logout();

      expect(result.isSuccess, isTrue);
      verify(() => mockStorageService.clearAll()).called(1);
    });
  });
}
