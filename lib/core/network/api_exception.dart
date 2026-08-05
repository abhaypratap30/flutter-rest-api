import 'dart:io';
import 'package:dio/dio.dart';

/// Base Exception class for all API & Network layer failures.
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException(this.message, {this.statusCode, this.data});

  /// Converts technical exception into user-friendly message for UI display.
  String toUserFriendlyMessage() {
    return message;
  }

  @override
  String toString() => '$runtimeType: $message (StatusCode: $statusCode)';

  /// Map DioException or general Exception into specific ApiException subclass.
  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiTimeoutException('Connection timed out. Please check your internet connection.');

      case DioExceptionType.connectionError:
        return const NoInternetException('No internet connection available. Please verify your network.');

      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        final responseData = response?.data;

        final extractedMessage = _extractServerMessage(responseData) ??
            _getDefaultMessageForStatus(statusCode);

        switch (statusCode) {
          case 400:
            return BadRequestException(extractedMessage, data: responseData);
          case 401:
            return UnauthorizedException(extractedMessage, data: responseData);
          case 403:
            return ForbiddenException(extractedMessage, data: responseData);
          case 404:
            return NotFoundException(extractedMessage, data: responseData);
          case 409:
            return ConflictException(extractedMessage, data: responseData);
          case 422:
            return UnprocessableEntityException(extractedMessage, data: responseData);
          case 500:
          case 502:
          case 503:
          case 504:
            return ServerException(extractedMessage, statusCode: statusCode, data: responseData);
          default:
            return UnknownApiException(extractedMessage, statusCode: statusCode, data: responseData);
        }

      case DioExceptionType.cancel:
        return const RequestCancelledException('The request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException('Security certificate verification failed.');

      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return const NoInternetException('Unable to reach server. Please check network.');
        }
        return UnknownApiException(
          error.message ?? 'An unexpected error occurred. Please try again.',
        );
    }
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message') && data['message'] is String) {
        return data['message'] as String;
      }
      if (data.containsKey('error') && data['error'] is String) {
        return data['error'] as String;
      }
      if (data.containsKey('errors') && data['errors'] is List) {
        return (data['errors'] as List).join(', ');
      }
    }
    return null;
  }

  static String _getDefaultMessageForStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input parameters.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'Access denied. You do not have permission for this resource.';
      case 404:
        return 'Requested resource was not found.';
      case 409:
        return 'Conflict detected with existing server resource.';
      case 422:
        return 'Validation failed. Please verify your data.';
      case 500:
        return 'Internal server error. Please try again later.';
      default:
        return 'Server error occurred ($statusCode).';
    }
  }
}

// Subclasses for explicit type catching
class NoInternetException extends ApiException {
  const NoInternetException([super.message = 'No internet connection.', dynamic data])
      : super(statusCode: 0, data: data);
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException([super.message = 'Request timeout elapsed.', dynamic data])
      : super(statusCode: 408, data: data);
}

class BadRequestException extends ApiException {
  const BadRequestException(super.message, {super.data}) : super(statusCode: 400);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, {super.data}) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(super.message, {super.data}) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message, {super.data}) : super(statusCode: 404);
}

class ConflictException extends ApiException {
  const ConflictException(super.message, {super.data}) : super(statusCode: 409);
}

class UnprocessableEntityException extends ApiException {
  const UnprocessableEntityException(super.message, {super.data}) : super(statusCode: 422);
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode = 500, super.data});
}

class NetworkException extends ApiException {
  const NetworkException(super.message, {super.statusCode, super.data});
}

class RequestCancelledException extends ApiException {
  const RequestCancelledException(super.message) : super(statusCode: -1);
}

class UnknownApiException extends ApiException {
  const UnknownApiException(super.message, {super.statusCode, super.data});
}
