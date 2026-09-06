import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:andalan_tools/core/utils/file_service.dart';

enum CompressionLevel {
  low,      // Ringan (Lossless/High Quality)
  balanced, // Seimbang (Recommended)
  high,     // Maksimal (Compact)
}

class CompressionResult {
  final String outputPath;
  final int originalSizeBytes;
  final int compressedSizeBytes;

  CompressionResult({
    required this.outputPath,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
  });

  double get savingsPercentage {
    if (originalSizeBytes <= 0) return 0;
    final diff = originalSizeBytes - compressedSizeBytes;
    if (diff <= 0) return 0;
    return (diff / originalSizeBytes) * 100;
  }
}

class PdfCompressorService {
  /// Compresses a PDF file according to the chosen compression level.
  static Future<CompressionResult?> compressPdf({
    required String inputPath,
    CompressionLevel level = CompressionLevel.balanced,
  }) async {
    try {
      final inputFile = File(inputPath);
      if (!await inputFile.exists()) return null;

      final originalBytes = await inputFile.readAsBytes();
      final originalSize = originalBytes.length;

      // Map level to Syncfusion Compression Level
      PdfCompressionLevel syncLevel;
      switch (level) {
        case CompressionLevel.low:
          syncLevel = PdfCompressionLevel.normal;
          break;
        case CompressionLevel.balanced:
          syncLevel = PdfCompressionLevel.aboveNormal;
          break;
        case CompressionLevel.high:
          syncLevel = PdfCompressionLevel.best;
          break;
      }

      // Load PDF document
      final PdfDocument document = PdfDocument(inputBytes: originalBytes);
      document.compressionLevel = syncLevel;

      // Re-draw pages to optimize streams and flatten fonts
      final PdfDocument compressedDoc = PdfDocument();
      compressedDoc.compressionLevel = syncLevel;

      for (int i = 0; i < document.pages.count; i++) {
        final sourcePage = document.pages[i];
        final template = sourcePage.createTemplate();
        
        final newPage = compressedDoc.pages.add();
        newPage.graphics.drawPdfTemplate(
          template,
          const Offset(0, 0),
          Size(newPage.size.width, newPage.size.height),
        );
      }

      final List<int> compressedBytes = await compressedDoc.save();
      document.dispose();
      compressedDoc.dispose();

      // Write output
      final outputPath = await FileService.generateTempPath('.pdf');
      await FileService.writeBytes(outputPath, compressedBytes);

      final finalSize = compressedBytes.length;

      return CompressionResult(
        outputPath: outputPath,
        originalSizeBytes: originalSize,
        compressedSizeBytes: finalSize,
      );
    } catch (e) {
      debugPrint("Error compressing PDF: $e");
      return null;
    }
  }
}
