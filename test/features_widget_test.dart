import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:andalan_tools/core/theme/theme.dart';
import 'package:andalan_tools/features/pdf_merger/presentation/pdf_merger_screen.dart';
import 'package:andalan_tools/features/pdf_lock/presentation/pdf_lock_screen.dart';

void main() {
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
}
