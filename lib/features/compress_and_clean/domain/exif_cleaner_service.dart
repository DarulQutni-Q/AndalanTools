import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:andalan_tools/core/utils/file_service.dart';

class ExifReport {
  final bool hasGps;
  final bool hasCameraInfo;
  final bool hasTimestamp;
  final List<String> detectedItems;

  ExifReport({
    required this.hasGps,
    required this.hasCameraInfo,
    required this.hasTimestamp,
    required this.detectedItems,
  });

  bool get hasAnyMetadata => hasGps || hasCameraInfo || hasTimestamp || detectedItems.isNotEmpty;
}

class ExifCleanerService {
  /// Inspects an image file and returns detected EXIF privacy elements
  static Future<ExifReport> inspectImage(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null || image.exif.isEmpty) {
        return ExifReport(
          hasGps: false,
          hasCameraInfo: false,
          hasTimestamp: false,
          detectedItems: [],
        );
      }

      final items = <String>[];
      bool hasGps = false;
      bool hasCamera = false;
      bool hasTime = false;

      // Check GPS
      if (image.exif.directories.containsKey('gps')) {
        hasGps = true;
        items.add("Koordinat Lokasi GPS (Privasi Lokasi)");
      }

      // Check Camera / Device
      if (image.exif.hasTag(0x010f) || image.exif.hasTag(0x0110)) {
        hasCamera = true;
        items.add("Tipe & Model Perangkat Kamera");
      }

      // Check Date Time
      if (image.exif.hasTag(0x0132)) {
        hasTime = true;
        items.add("Waktu & Tanggal Pengambilan Foto");
      }

      if (items.isEmpty && !image.exif.isEmpty) {
        items.add("Data Tag EXIF Teknis Lainnya");
      }

      return ExifReport(
        hasGps: hasGps,
        hasCameraInfo: hasCamera,
        hasTimestamp: hasTime,
        detectedItems: items,
      );
    } catch (e) {
      debugPrint("Error inspecting EXIF: $e");
      return ExifReport(
        hasGps: false,
        hasCameraInfo: false,
        hasTimestamp: false,
        detectedItems: [],
      );
    }
  }

  /// Removes all EXIF metadata and saves a pristine, privacy-safe image
  static Future<String?> cleanExif(String inputPath) async {
    try {
      final file = File(inputPath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      // Completely clear all EXIF directories
      image.exif.directories.clear();

      // Encode image without metadata
      final List<int> cleanedBytes;
      final extension = inputPath.toLowerCase().endsWith('.png') ? '.png' : '.jpg';

      if (extension == '.png') {
        cleanedBytes = img.encodePng(image);
      } else {
        cleanedBytes = img.encodeJpg(image, quality: 95);
      }

      final outputPath = await FileService.generateTempPath(extension);
      await FileService.writeBytes(outputPath, cleanedBytes);

      return outputPath;
    } catch (e) {
      debugPrint("Error cleaning EXIF: $e");
      return null;
    }
  }

  /// Batch cleans multiple images
  static Future<List<String>> cleanMultipleImages(List<String> inputPaths) async {
    final results = <String>[];
    for (final path in inputPaths) {
      final cleanPath = await cleanExif(path);
      if (cleanPath != null) {
        results.add(cleanPath);
      }
    }
    return results;
  }
}
