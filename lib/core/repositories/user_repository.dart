import 'package:flutter_rest_api/core/config/app_constants.dart';
import 'package:flutter_rest_api/core/models/pagination_model.dart';
import 'package:flutter_rest_api/core/models/user_model.dart';
import 'package:flutter_rest_api/core/network/api_client.dart';
import 'package:flutter_rest_api/core/network/api_response.dart';

abstract class IUserRepository {
  Future<ApiResult<PaginatedResponse<UserModel>>> getUsers(PaginationParams params, {bool useCache = false});
  Future<ApiResult<UserModel>> getUserById(int id);
  Future<ApiResult<UserModel>> createUser(UserModel user);
  Future<ApiResult<UserModel>> updateUser(int id, Map<String, dynamic> updates);
  Future<ApiResult<bool>> deleteUser(int id);
  Future<ApiResult<PaginatedResponse<UserModel>>> searchUsers(String query, PaginationParams params);
}

class UserRepository implements IUserRepository {
  final IApiClient apiClient;

  UserRepository({required this.apiClient});

  @override
  Future<ApiResult<PaginatedResponse<UserModel>>> getUsers(
    PaginationParams params, {
    bool useCache = false,
  }) async {
    final path = (params.searchQuery != null && params.searchQuery!.isNotEmpty)
        ? AppConstants.endpointSearchUsers
        : AppConstants.endpointUsers;

    return await apiClient.get<PaginatedResponse<UserModel>>(
      path,
      queryParameters: params.toQueryParams(),
      useCache: useCache,
      decoder: (json) => PaginatedResponse.fromJson(
        json: json as Map<String, dynamic>,
        key: 'users',
        fromJsonT: (item) => UserModel.fromJson(item),
      ),
    );
  }

  @override
  Future<ApiResult<UserModel>> getUserById(int id) async {
    return await apiClient.get<UserModel>(
      '${AppConstants.endpointUsers}/$id',
      useCache: true,
      decoder: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<UserModel>> createUser(UserModel user) async {
    final payload = user.toJson()..remove('id');
    return await apiClient.post<UserModel>(
      '${AppConstants.endpointUsers}/add',
      data: payload,
      decoder: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<UserModel>> updateUser(int id, Map<String, dynamic> updates) async {
    return await apiClient.put<UserModel>(
      '${AppConstants.endpointUsers}/$id',
      data: updates,
      decoder: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<bool>> deleteUser(int id) async {
    return await apiClient.delete<bool>(
      '${AppConstants.endpointUsers}/$id',
      decoder: (json) {
        if (json is Map<String, dynamic> && json['isDeleted'] == true) {
          return true;
        }
        return true;
      },
    );
  }

  @override
  Future<ApiResult<PaginatedResponse<UserModel>>> searchUsers(
    String query,
    PaginationParams params,
  ) async {
    final updatedParams = params.copyWith(searchQuery: query);
    return getUsers(updatedParams);
  }
}
