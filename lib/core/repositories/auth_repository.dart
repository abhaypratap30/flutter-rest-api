import 'package:flutter_rest_api/core/config/app_constants.dart';
import 'package:flutter_rest_api/core/models/auth_model.dart';
import 'package:flutter_rest_api/core/models/user_model.dart';
import 'package:flutter_rest_api/core/network/api_client.dart';
import 'package:flutter_rest_api/core/network/api_response.dart';
import 'package:flutter_rest_api/core/services/storage_service.dart';

abstract class IAuthRepository {
  Future<ApiResult<AuthResponse>> login(LoginRequest request);
  Future<ApiResult<UserModel>> getCurrentUser();
  Future<ApiResult<bool>> logout();
  Future<bool> isAuthenticated();
}

class AuthRepository implements IAuthRepository {
  final IApiClient apiClient;
  final IStorageService storageService;

  AuthRepository({
    required this.apiClient,
    required this.storageService,
  });

  @override
  Future<ApiResult<AuthResponse>> login(LoginRequest request) async {
    final result = await apiClient.post<AuthResponse>(
      AppConstants.endpointLogin,
      data: request.toJson(),
      decoder: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    if (result.isSuccess && result.data != null) {
      final response = result.data!;
      await storageService.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
      );
      await storageService.saveUserData(response.user.toJson());
    }

    return result;
  }

  @override
  Future<ApiResult<UserModel>> getCurrentUser() async {
    final cachedUserData = await storageService.getUserData();
    if (cachedUserData != null) {
      return ApiResult.success(UserModel.fromJson(cachedUserData));
    }

    final result = await apiClient.get<UserModel>(
      AppConstants.endpointCurrentUser,
      decoder: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (result.isSuccess && result.data != null) {
      await storageService.saveUserData(result.data!.toJson());
    }

    return result;
  }

  @override
  Future<ApiResult<bool>> logout() async {
    await storageService.clearAll();
    return ApiResult.success(true);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await storageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
