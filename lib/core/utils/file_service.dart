import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  /// Generates a temporary file path with the given extension.
  /// Example extension: '.pdf' or '.jpg'
  static Future<String> generateTempPath(String extension) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${tempDir.path}/andalan_$timestamp$extension';
  }

  /// Writes bytes to the specified path.
  static Future<File> writeBytes(String path, List<int> bytes) async {
    final file = File(path);
    return await file.writeAsBytes(bytes);
  }
}
