import 'dart:io';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../features/image_to_pdf/providers/image_list_provider.dart';
import 'file_service.dart';
import 'image_processor.dart';

class PdfGenerationService {
  static Future<String?> generatePdf({
    required List<String> imagePaths,
    required CompressQuality quality,
  }) async {
    if (imagePaths.isEmpty) return null;

    try {
      final List<String> processedPaths = [];

      int compressQualityInt;
      switch (quality) {
        case CompressQuality.high:
          compressQualityInt = 90;
          break;
        case CompressQuality.medium:
          compressQualityInt = 70;
          break;
        case CompressQuality.low:
          compressQualityInt = 40;
          break;
      }

      // Compress all images using the ImageProcessor
      for (int i = 0; i < imagePaths.length; i++) {
        final String originalPath = imagePaths[i];
        final String? processedPath = await ImageProcessor.compressForPdf(originalPath, compressQualityInt);
        if (processedPath != null) {
          processedPaths.add(processedPath);
        } else {
          processedPaths.add(originalPath);
        }
      }

      if (processedPaths.isEmpty) return null;

      final PdfDocument document = PdfDocument();
      // Set standard margin to 0 for full-page aesthetic or standard padding
      document.pageSettings.margins.all = 20;

      for (final String path in processedPaths) {
        final File file = File(path);
        if (!await file.exists()) continue;

        final List<int> imageBytes = await file.readAsBytes();
        final PdfBitmap bitmap = PdfBitmap(imageBytes);

        final PdfPage page = document.pages.add();
        final Size pageSize = page.getClientSize();

        final double imgWidth = bitmap.width.toDouble();
        final double imgHeight = bitmap.height.toDouble();

        double scale = 1.0;
        if (imgWidth > pageSize.width || imgHeight > pageSize.height) {
          final double scaleX = pageSize.width / imgWidth;
          final double scaleY = pageSize.height / imgHeight;
          scale = scaleX < scaleY ? scaleX : scaleY;
        }

        final double drawWidth = imgWidth * scale;
        final double drawHeight = imgHeight * scale;
        final double x = (pageSize.width - drawWidth) / 2;
        final double y = (pageSize.height - drawHeight) / 2;

        page.graphics.drawImage(bitmap, Rect.fromLTWH(x, y, drawWidth, drawHeight));
      }

      if (document.pages.count == 0) {
        document.dispose();
        return null;
      }

      final List<int> bytes = document.saveSync();
      document.dispose();

      final String outputPdfPath = await FileService.generateTempPath('.pdf');
      await FileService.writeBytes(outputPdfPath, bytes);

      return outputPdfPath;
    } catch (e) {
      return null;
    }
  }
}
