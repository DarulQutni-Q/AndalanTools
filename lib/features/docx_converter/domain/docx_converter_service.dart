import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:andalan_tools/core/utils/file_service.dart';

class DocxConverterService {
  static Future<String?> convertDocxToPdf(String inputPath) async {
    try {
      final file = File(inputPath);
      final bytes = await file.readAsBytes();
      
      // Extract text using docx_to_text
      final text = docxToText(bytes);
      
      if (text.isEmpty) return null;

      // Create PDF
      final pdf = pw.Document();

      // We split the text into manageable chunks if it's too long, 
      // but pw.Text inside pw.MultiPage handles pagination automatically.
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Text(
                text,
                style: const pw.TextStyle(
                  fontSize: 12,
                  lineSpacing: 1.5,
                ),
              ),
            ];
          },
        ),
      );

      final outputPath = await FileService.generateTempPath('.pdf');
      await FileService.writeBytes(outputPath, await pdf.save());

      return outputPath;
    } catch (e) {
      debugPrint("Error converting Docx to PDF: $e");
      return null;
    }
  }
}
