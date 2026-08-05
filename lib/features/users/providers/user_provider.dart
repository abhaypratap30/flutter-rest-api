import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rest_api/core/models/pagination_model.dart';
import 'package:flutter_rest_api/core/models/user_model.dart';
import 'package:flutter_rest_api/core/providers/core_providers.dart';
import 'package:flutter_rest_api/core/repositories/user_repository.dart';

class UserListState {
  final List<UserModel> users;
  final bool isLoading;
  final bool isFetchingMore;
  final bool hasNextPage;
  final String? errorMessage;
  final PaginationParams params;
  final int totalCount;

  const UserListState({
    this.users = const [],
    this.isLoading = false,
    this.isFetchingMore = false,
    this.hasNextPage = true,
    this.errorMessage,
    this.params = const PaginationParams(),
    this.totalCount = 0,
  });

  UserListState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    bool? isFetchingMore,
    bool? hasNextPage,
    String? errorMessage,
    PaginationParams? params,
    int? totalCount,
  }) {
    return UserListState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      errorMessage: errorMessage,
      params: params ?? this.params,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

final userListProvider = StateNotifierProvider<UserListNotifier, UserListState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserListNotifier(userRepository);
});

class UserListNotifier extends StateNotifier<UserListState> {
  final IUserRepository _userRepository;

  UserListNotifier(this._userRepository) : super(const UserListState()) {
    fetchUsers();
  }

  Future<void> fetchUsers({bool refresh = false}) async {
    if (state.isLoading || state.isFetchingMore) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        params: state.params.copyWith(page: 1),
      );
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    final result = await _userRepository.getUsers(state.params);

    result.when(
      success: (paginated) {
        state = state.copyWith(
          users: paginated.items,
          isLoading: false,
          hasNextPage: paginated.hasNextPage,
          totalCount: paginated.total,
        );
      },
      failure: (msg, code, ex) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: msg,
        );
      },
    );
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || state.isFetchingMore || !state.hasNextPage) return;

    state = state.copyWith(isFetchingMore: true);
    final nextParams = state.params.next();

    final result = await _userRepository.getUsers(nextParams);

    result.when(
      success: (paginated) {
        state = state.copyWith(
          users: [...state.users, ...paginated.items],
          isFetchingMore: false,
          hasNextPage: paginated.hasNextPage,
          params: nextParams,
          totalCount: paginated.total,
        );
      },
      failure: (msg, code, ex) {
        state = state.copyWith(
          isFetchingMore: false,
          errorMessage: msg,
        );
      },
    );
  }

  Future<void> searchUsers(String query) async {
    final newParams = state.params.copyWith(page: 1, searchQuery: query);
    state = state.copyWith(isLoading: true, params: newParams, errorMessage: null);

    final result = await _userRepository.getUsers(newParams);

    result.when(
      success: (paginated) {
        state = state.copyWith(
          users: paginated.items,
          isLoading: false,
          hasNextPage: paginated.hasNextPage,
          totalCount: paginated.total,
        );
      },
      failure: (msg, code, ex) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: msg,
        );
      },
    );
  }

  void setPaginationType(PaginationType type) {
    state = state.copyWith(
      params: state.params.copyWith(page: 1, type: type),
    );
    fetchUsers(refresh: true);
  }

  void removeUserLocal(int id) {
    state = state.copyWith(
      users: state.users.where((u) => u.id != id).toList(),
      totalCount: state.totalCount > 0 ? state.totalCount - 1 : 0,
    );
  }

  void addUserLocal(UserModel user) {
    state = state.copyWith(
      users: [user, ...state.users],
      totalCount: state.totalCount + 1,
    );
  }

  void updateUserLocal(UserModel user) {
    state = state.copyWith(
      users: state.users.map((u) => u.id == user.id ? user : u).toList(),
    );
  }
}

/// Family Provider for Single User Details
final userDetailProvider = FutureProvider.family<UserModel, int>((ref, userId) async {
  final userRepository = ref.watch(userRepositoryProvider);
  final result = await userRepository.getUserById(userId);
  return result.when(
    success: (user) => user,
    failure: (msg, code, ex) => throw Exception(msg),
  );
});
