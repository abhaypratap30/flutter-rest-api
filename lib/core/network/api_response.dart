/// Standardized generic API response model wrapper.
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String message = 'Success', int? statusCode}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode ?? 200,
    );
  }

  factory ApiResponse.failure(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      data: null,
      statusCode: statusCode,
    );
  }
}

/// Paginated API response structure holding data items and metadata.
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int skip;
  final int limit;
  final int page;
  final int totalPages;
  final bool hasNextPage;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
    required this.page,
    required this.totalPages,
    required this.hasNextPage,
  });

  /// Calculates pagination metadata from raw API list response
  factory PaginatedResponse.fromJson({
    required Map<String, dynamic> json,
    required String key,
    required T Function(Map<String, dynamic>) fromJsonT,
  }) {
    final rawList = (json[key] as List<dynamic>?) ?? [];
    final items = rawList.map((e) => fromJsonT(e as Map<String, dynamic>)).toList();
    final total = (json['total'] as int?) ?? items.length;
    final skip = (json['skip'] as int?) ?? 0;
    final limit = (json['limit'] as int?) ?? (items.isEmpty ? 10 : items.length);

    final page = limit > 0 ? (skip ~/ limit) + 1 : 1;
    final totalPages = limit > 0 ? (total / limit).ceil() : 1;
    final hasNextPage = (skip + items.length) < total;

    return PaginatedResponse<T>(
      items: items,
      total: total,
      skip: skip,
      limit: limit,
      page: page,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
    );
  }
}

/// Functional Result Pattern for clean error handling.
sealed class ApiResult<T> {
  const ApiResult();

  factory ApiResult.success(T data) = ApiResultSuccess<T>;
  factory ApiResult.failure(String message, {int? statusCode, Exception? exception}) =
      ApiResultFailure<T>;

  bool get isSuccess => this is ApiResultSuccess<T>;
  bool get isFailure => this is ApiResultFailure<T>;

  T? get data => isSuccess ? (this as ApiResultSuccess<T>).data : null;
  String? get errorMessage => isFailure ? (this as ApiResultFailure<T>).message : null;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode, Exception? exception) failure,
  }) {
    if (this is ApiResultSuccess<T>) {
      return success((this as ApiResultSuccess<T>).data);
    } else {
      final fail = this as ApiResultFailure<T>;
      return failure(fail.message, fail.statusCode, fail.exception);
    }
  }
}

class ApiResultSuccess<T> extends ApiResult<T> {
  @override
  final T data;
  const ApiResultSuccess(this.data);
}

class ApiResultFailure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final Exception? exception;

  const ApiResultFailure(this.message, {this.statusCode, this.exception});
}
