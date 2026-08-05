import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rest_api/core/providers/core_providers.dart';
import 'package:flutter_rest_api/core/repositories/file_repository.dart';

class FileTransferState {
  final double progress;
  final bool isTransferring;
  final bool isSuccess;
  final String? errorMessage;
  final String? resultPath;

  const FileTransferState({
    this.progress = 0.0,
    this.isTransferring = false,
    this.isSuccess = false,
    this.errorMessage,
    this.resultPath,
  });

  FileTransferState copyWith({
    double? progress,
    bool? isTransferring,
    bool? isSuccess,
    String? errorMessage,
    String? resultPath,
  }) {
    return FileTransferState(
      progress: progress ?? this.progress,
      isTransferring: isTransferring ?? this.isTransferring,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      resultPath: resultPath ?? this.resultPath,
    );
  }
}

final uploadNotifierProvider =
    StateNotifierProvider<UploadNotifier, FileTransferState>((ref) {
  final repository = ref.watch(fileRepositoryProvider);
  return UploadNotifier(repository);
});

class UploadNotifier extends StateNotifier<FileTransferState> {
  final IFileRepository _repository;
  CancelToken? _cancelToken;

  UploadNotifier(this._repository) : super(const FileTransferState());

  Future<void> startUpload(String fileName) async {
    _cancelToken = CancelToken();
    state = const FileTransferState(isTransferring: true, progress: 0.0);

    final result = await _repository.uploadFile(
      filePath: 'demo/path/$fileName',
      fileName: fileName,
      onSendProgress: (sent, total) {
        if (total > 0) {
          state = state.copyWith(progress: sent / total);
        }
      },
      cancelToken: _cancelToken,
    );

    result.when(
      success: (data) {
        state = state.copyWith(
          isTransferring: false,
          isSuccess: true,
          progress: 1.0,
          resultPath: data['fileName']?.toString(),
        );
      },
      failure: (msg, code, ex) {
        state = state.copyWith(
          isTransferring: false,
          isSuccess: false,
          errorMessage: msg,
        );
      },
    );
  }

  void cancel() {
    _cancelToken?.cancel('User cancelled file upload');
    state = const FileTransferState(
      isTransferring: false,
      errorMessage: 'Upload cancelled by user',
    );
  }
}

final downloadNotifierProvider =
    StateNotifierProvider<DownloadNotifier, FileTransferState>((ref) {
  final repository = ref.watch(fileRepositoryProvider);
  return DownloadNotifier(repository);
});

class DownloadNotifier extends StateNotifier<FileTransferState> {
  final IFileRepository _repository;
  CancelToken? _cancelToken;

  DownloadNotifier(this._repository) : super(const FileTransferState());

  Future<void> startDownload(String fileUrl, String fileName) async {
    _cancelToken = CancelToken();
    state = const FileTransferState(isTransferring: true, progress: 0.0);

    final result = await _repository.downloadFile(
      fileUrl: fileUrl,
      fileName: fileName,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          state = state.copyWith(progress: received / total);
        } else {
          // Simulate step progress if total length is unsupplied
          state = state.copyWith(progress: (state.progress + 0.1).clamp(0.0, 0.9));
        }
      },
      cancelToken: _cancelToken,
    );

    result.when(
      success: (path) {
        state = state.copyWith(
          isTransferring: false,
          isSuccess: true,
          progress: 1.0,
          resultPath: path,
        );
      },
      failure: (msg, code, ex) {
        state = state.copyWith(
          isTransferring: false,
          isSuccess: false,
          errorMessage: msg,
        );
      },
    );
  }

  void cancel() {
    _cancelToken?.cancel('User cancelled file download');
    state = const FileTransferState(
      isTransferring: false,
      errorMessage: 'Download cancelled by user',
    );
  }
}
