import 'dart:io';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:andalan_tools/core/utils/file_service.dart';

class PdfMergerService {
  /// Merges multiple PDF files into a single output PDF document.
  static Future<String?> mergePdfs(List<String> pdfPaths) async {
    if (pdfPaths.length < 2) return null;

    try {
      final PdfDocument outputDoc = PdfDocument();
      outputDoc.pageSettings.margins.all = 0;

      for (final String path in pdfPaths) {
        final File file = File(path);
        if (!await file.exists()) continue;

        final List<int> bytes = await file.readAsBytes();
        final PdfDocument sourceDoc = PdfDocument(inputBytes: bytes);

        for (int i = 0; i < sourceDoc.pages.count; i++) {
          final PdfPage sourcePage = sourceDoc.pages[i];
          final Size sourceSize = sourcePage.size;

          outputDoc.pageSettings.size = sourceSize;
          final PdfPage newPage = outputDoc.pages.add();

          newPage.graphics.drawPdfTemplate(
            sourcePage.createTemplate(),
            Offset.zero,
            newPage.getClientSize(),
          );
        }

        sourceDoc.dispose();
      }

      if (outputDoc.pages.count == 0) {
        outputDoc.dispose();
        return null;
      }

      final List<int> mergedBytes = outputDoc.saveSync();
      outputDoc.dispose();

      final String outputPath = await FileService.generateTempPath('.pdf');
      await FileService.writeBytes(outputPath, mergedBytes);

      return outputPath;
    } catch (e) {
      return null;
    }
  }
}
