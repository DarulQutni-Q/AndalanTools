import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:andalan_tools/core/utils/file_service.dart';

class PdfLockService {
  /// Encrypts and password-protects a PDF file using 256-bit AES encryption.
  static Future<String?> lockPdf({
    required String inputPath,
    required String password,
    String? ownerPassword,
  }) async {
    if (password.isEmpty) return null;

    try {
      final File file = File(inputPath);
      if (!await file.exists()) return null;

      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      final PdfSecurity security = document.security;
      security.algorithm = PdfEncryptionAlgorithm.aesx256Bit;
      security.userPassword = password;
      security.ownerPassword = (ownerPassword != null && ownerPassword.isNotEmpty)
          ? ownerPassword
          : password;

      final List<int> securedBytes = document.saveSync();
      document.dispose();

      final String outputPath = await FileService.generateTempPath('.pdf');
      await FileService.writeBytes(outputPath, securedBytes);

      return outputPath;
    } catch (e) {
      return null;
    }
  }
}
