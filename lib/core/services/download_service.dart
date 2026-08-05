import 'dart:io';
import 'package:path_provider/path_provider.dart';

abstract class IDownloadService {
  Future<String> getDownloadDirectoryPath();
  Future<String> generateSavePath(String filename);
}

class DownloadService implements IDownloadService {
  @override
  Future<String> getDownloadDirectoryPath() async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else if (Platform.isIOS || Platform.isMacOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    }
    return dir?.path ?? (await getTemporaryDirectory()).path;
  }

  @override
  Future<String> generateSavePath(String filename) async {
    final baseDir = await getDownloadDirectoryPath();
    final sanitizeFilename = filename.replaceAll(RegExp(r'[^\w\.-]'), '_');
    return '$baseDir/$sanitizeFilename';
  }
}
