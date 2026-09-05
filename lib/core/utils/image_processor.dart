import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:andalan_tools/core/utils/file_service.dart';

enum TargetImageFormat { png, jpg, webp, heic }

class ImageProcessor {
  /// Compresses an image for PDF generation.
  static Future<String?> compressForPdf(String originalPath, int quality) async {
    final targetPath = await FileService.generateTempPath('.jpg');
    
    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      targetPath,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    return compressedFile?.path ?? originalPath; // fallback to original if compression fails
  }

  /// Converts an image to the specified target format.
  static Future<String?> convertToFormat(String originalPath, TargetImageFormat format) async {
    CompressFormat compressFormat;
    String extension;
    
    switch (format) {
      case TargetImageFormat.png:
        compressFormat = CompressFormat.png;
        extension = '.png';
        break;
      case TargetImageFormat.webp:
        compressFormat = CompressFormat.webp;
        extension = '.webp';
        break;
      case TargetImageFormat.heic:
        compressFormat = CompressFormat.heic;
        extension = '.heic';
        break;
      case TargetImageFormat.jpg:
      default:
        compressFormat = CompressFormat.jpeg;
        extension = '.jpg';
        break;
    }

    final targetPath = await FileService.generateTempPath(extension);

    final XFile? convertedFile = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      targetPath,
      quality: 90, // default high quality for conversion
      format: compressFormat,
    );

    return convertedFile?.path;
  }
}
