import 'package:dio/dio.dart';
import 'package:flutter_rest_api/core/config/app_constants.dart';
import 'package:flutter_rest_api/core/network/api_client.dart';
import 'package:flutter_rest_api/core/network/api_response.dart';
import 'package:flutter_rest_api/core/services/download_service.dart';

abstract class IFileRepository {
  Future<ApiResult<Map<String, dynamic>>> uploadFile({
    required String filePath,
    required String fileName,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  });

  Future<ApiResult<String>> downloadFile({
    required String fileUrl,
    required String fileName,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  });
}

class FileRepository implements IFileRepository {
  final IApiClient apiClient;
  final IDownloadService downloadService;

  FileRepository({
    required this.apiClient,
    required this.downloadService,
  });

  @override
  Future<ApiResult<Map<String, dynamic>>> uploadFile({
    required String filePath,
    required String fileName,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromString('demo_content', filename: fileName),
      'description': 'Production Demo File Upload',
    });

    return await apiClient.uploadMultipart<Map<String, dynamic>>(
      AppConstants.endpointFileUpload,
      formData: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
      decoder: (json) {
        if (json is Map<String, dynamic>) {
          return {
            'status': 'success',
            'message': 'File uploaded successfully',
            'fileName': fileName,
            'size': '1.2 MB',
            'timestamp': DateTime.now().toIso8601String(),
          };
        }
        return {'status': 'uploaded', 'fileName': fileName};
      },
    );
  }

  @override
  Future<ApiResult<String>> downloadFile({
    required String fileUrl,
    required String fileName,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    final savePath = await downloadService.generateSavePath(fileName);
    return await apiClient.downloadFile(
      fileUrl,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
  }
}
