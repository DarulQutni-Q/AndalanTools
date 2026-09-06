// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:andalan_tools/core/theme/theme.dart';
import 'package:andalan_tools/features/pdf_merger/presentation/pdf_merger_screen.dart';
import 'package:andalan_tools/features/pdf_lock/presentation/pdf_lock_screen.dart';
import 'package:andalan_tools/features/docx_converter/presentation/docx_converter_screen.dart';
import 'package:andalan_tools/features/image_converter/presentation/image_converter_screen.dart';
import 'package:andalan_tools/features/compress_and_clean/presentation/compress_and_clean_screen.dart';
import 'package:andalan_tools/features/vault/presentation/vault_screen.dart';

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

  testWidgets('PdfMergerScreen renders initial UI components correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const PdfMergerScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and prompt
    expect(find.text('PDF Merger'), findsOneWidget);
    expect(find.text('Belum ada file PDF dipilih.\nMinimal pilih 2 PDF untuk digabung.'), findsOneWidget);
    expect(find.text('Pilih File PDF'), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
  });

  testWidgets('PdfLockScreen renders initial UI components correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const PdfLockScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and prompt
    expect(find.text('Lock & Protect PDF'), findsOneWidget);
    expect(find.text('Enkripsi PDF dengan kata sandi (AES-256).\nSemua proses berlangsung 100% offline.'), findsOneWidget);
    expect(find.text('Pilih File PDF'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('DocxConverterScreen renders initial UI with pick button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DocxConverterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Docx to PDF'), findsOneWidget);
    expect(find.text('Select Docx File'), findsOneWidget);
  });

  testWidgets('ImageConverterScreen renders empty state with Photos gallery and File manager buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ImageConverterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Format Converter'), findsOneWidget);
    expect(find.text('Belum Ada Gambar Dipilih'), findsOneWidget);
    expect(find.text('Buka Galeri Foto'), findsOneWidget);
    expect(find.text('Buka File Manager'), findsOneWidget);
    expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
  });

  testWidgets('ImageConverterScreen tap + icon opens source modal', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ImageConverterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Sumber Gambar'), findsOneWidget);
    expect(find.text('Galeri Foto (Photos)'), findsOneWidget);
    expect(find.text('File Manager (Files)'), findsOneWidget);
  });

  testWidgets('CompressAndCleanScreen renders segmented controls and switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CompressAndCleanScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kompres & Bersih EXIF'), findsOneWidget);
    expect(find.text('Kompresi PDF'), findsOneWidget);
    expect(find.text('Bersihkan EXIF'), findsOneWidget);
    expect(find.text('Pilih Berkas PDF'), findsOneWidget);

    // Switch to Bersihkan EXIF tab
    await tester.tap(find.text('Bersihkan EXIF'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Foto dari Galeri'), findsOneWidget);
    expect(find.text('Pilih dari File Manager'), findsOneWidget);
  });

  testWidgets('VaultScreen renders initial UI components properly', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const VaultScreen(),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();

    expect(find.text('Brankas & Riwayat'), findsOneWidget);
    expect(find.text('Brankas Masih Kosong'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('Gambar'), findsOneWidget);
    expect(find.text('Word'), findsOneWidget);
  });
}

