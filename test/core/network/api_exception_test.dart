import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rest_api/core/network/api_exception.dart';

void main() {
  group('ApiException unit tests', () {
    test('converts connectionTimeout to ApiTimeoutException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final exception = ApiException.fromDioException(dioErr);
      expect(exception, isA<ApiTimeoutException>());
      expect(exception.toUserFriendlyMessage(), contains('timed out'));
    });

    test('converts connectionError to NoInternetException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      final exception = ApiException.fromDioException(dioErr);
      expect(exception, isA<NoInternetException>());
      expect(exception.toUserFriendlyMessage(), contains('No internet'));
    });

    test('converts 401 response to UnauthorizedException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {'message': 'Invalid credentials'},
        ),
      );

      final exception = ApiException.fromDioException(dioErr);
      expect(exception, isA<UnauthorizedException>());
      expect(exception.message, equals('Invalid credentials'));
    });

    test('converts 404 response to NotFoundException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );

      final exception = ApiException.fromDioException(dioErr);
      expect(exception, isA<NotFoundException>());
    });

    test('converts 500 response to ServerException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );

      final exception = ApiException.fromDioException(dioErr);
      expect(exception, isA<ServerException>());
    });
  });
}
