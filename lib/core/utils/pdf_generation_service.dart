import 'package:pdf_combiner/models/merge_input.dart';
import 'package:pdf_combiner/pdf_combiner.dart';
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
      List<String> processedPaths = [];

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
        }
      }

      // Combine to PDF
      final String outputPdfPath = await FileService.generateTempPath('.pdf');
      
      String? finalPath = await PdfCombiner.generatePDFFromDocuments(
        inputs: processedPaths.map((p) => MergeInput.path(p)).toList(),
        outputPath: outputPdfPath,
      );

      return finalPath;
    } catch (e) {
      print("Error generating PDF: \$e");
      return null;
    }
  }
}
