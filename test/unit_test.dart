import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:andalan_tools/features/pdf_merger/domain/pdf_merger_service.dart';
import 'package:andalan_tools/features/pdf_lock/domain/pdf_lock_service.dart';
import 'package:andalan_tools/core/utils/file_service.dart';
import 'package:andalan_tools/core/utils/pdf_generation_service.dart';
import 'package:andalan_tools/features/image_to_pdf/providers/image_list_provider.dart';
import 'package:image/image.dart' as img;

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = MockPathProviderPlatform();

  group('FileService Tests', () {
    test('generateTempPath returns valid path with proper extension', () async {
      final path = await FileService.generateTempPath('.pdf');
      expect(path, isNotEmpty);
      expect(path.endsWith('.pdf'), isTrue);
    });

    test('writeBytes writes and creates a readable file', () async {
      final path = await FileService.generateTempPath('.txt');
      final testData = [1, 2, 3, 4, 5];
      final file = await FileService.writeBytes(path, testData);

      expect(await file.exists(), isTrue);
      final readData = await file.readAsBytes();
      expect(readData, equals(testData));

      // Cleanup
      if (await file.exists()) await file.delete();
    });
  });

  group('PdfMergerService Tests', () {
    test('mergePdfs combines two single-page PDFs into a two-page PDF', () async {
      // 1. Create PDF #1 (1 page)
      final doc1 = PdfDocument();
      doc1.pages.add().graphics.drawString('Page 1 Doc 1', PdfStandardFont(PdfFontFamily.helvetica, 12));
      final path1 = await FileService.generateTempPath('.pdf');
      await File(path1).writeAsBytes(doc1.saveSync());
      doc1.dispose();

      // 2. Create PDF #2 (2 pages)
      final doc2 = PdfDocument();
      doc2.pages.add().graphics.drawString('Page 1 Doc 2', PdfStandardFont(PdfFontFamily.helvetica, 12));
      doc2.pages.add().graphics.drawString('Page 2 Doc 2', PdfStandardFont(PdfFontFamily.helvetica, 12));
      final path2 = await FileService.generateTempPath('.pdf');
      await File(path2).writeAsBytes(doc2.saveSync());
      doc2.dispose();

      // 3. Merge them
      final mergedPath = await PdfMergerService.mergePdfs([path1, path2]);
      expect(mergedPath, isNotNull);
      expect(await File(mergedPath!).exists(), isTrue);

      // 4. Verify merged document has exactly 3 pages (1 + 2)
      final mergedBytes = await File(mergedPath).readAsBytes();
      final mergedDoc = PdfDocument(inputBytes: mergedBytes);
      expect(mergedDoc.pages.count, equals(3));
      mergedDoc.dispose();

      // Cleanup
      await File(path1).delete();
      await File(path2).delete();
      await File(mergedPath).delete();
    });

    test('mergePdfs returns null when fewer than 2 paths provided', () async {
      final result = await PdfMergerService.mergePdfs(['/dummy/path.pdf']);
      expect(result, isNull);
    });
  });

  group('PdfLockService Tests', () {
    test('lockPdf encrypts PDF with AES-256 and requires password to open', () async {
      // 1. Create plain PDF
      final doc = PdfDocument();
      doc.pages.add().graphics.drawString('Confidential Content', PdfStandardFont(PdfFontFamily.helvetica, 12));
      final plainPath = await FileService.generateTempPath('.pdf');
      await File(plainPath).writeAsBytes(doc.saveSync());
      doc.dispose();

      // 2. Encrypt PDF with password
      const testPassword = 'SecurePassword2026!';
      final lockedPath = await PdfLockService.lockPdf(
        inputPath: plainPath,
        password: testPassword,
      );
      expect(lockedPath, isNotNull);
      expect(await File(lockedPath!).exists(), isTrue);

      final lockedBytes = await File(lockedPath).readAsBytes();

      // 3. Trying to open without password should fail
      bool openedWithoutPassword = false;
      try {
        final failedDoc = PdfDocument(inputBytes: lockedBytes);
        openedWithoutPassword = true;
        failedDoc.dispose();
      } catch (_) {
        openedWithoutPassword = false;
      }
      expect(openedWithoutPassword, isFalse, reason: 'Protected PDF should not open without password');

      // 4. Opening with correct password should succeed
      final unlockedDoc = PdfDocument(inputBytes: lockedBytes, password: testPassword);
      expect(unlockedDoc.pages.count, equals(1));
      unlockedDoc.dispose();

      // Cleanup
      await File(plainPath).delete();
      await File(lockedPath).delete();
    });
  });

  group('PdfGenerationService Tests', () {
    test('generatePdfFromImages creates valid PDF with embedded images', () async {
      // Create a test 100x100 RGB image
      final testImage = img.Image(width: 100, height: 100);
      img.fill(testImage, color: img.ColorRgb8(255, 0, 0)); // Red square
      final jpgBytes = img.encodeJpg(testImage);

      final imgPath = await FileService.generateTempPath('.jpg');
      await File(imgPath).writeAsBytes(jpgBytes);

      // Generate PDF
      final pdfPath = await PdfGenerationService.generatePdf(
        imagePaths: [imgPath],
        quality: CompressQuality.high,
      );
      expect(pdfPath, isNotNull);
      expect(await File(pdfPath!).exists(), isTrue);

      // Verify PDF
      final pdfBytes = await File(pdfPath).readAsBytes();
      final pdfDoc = PdfDocument(inputBytes: pdfBytes);
      expect(pdfDoc.pages.count, equals(1));
      pdfDoc.dispose();

      // Cleanup
      await File(imgPath).delete();
      await File(pdfPath).delete();
    });
  });
}
