import 'package:flutter/material.dart';
import 'package:andalan_tools/core/theme/theme.dart';
import 'package:andalan_tools/features/image_to_pdf/presentation/main_canvas_screen.dart';
import 'package:andalan_tools/features/pdf_editor/presentation/pdf_editor_screen.dart';
import 'package:andalan_tools/features/image_converter/presentation/image_converter_screen.dart';
import 'package:andalan_tools/features/docx_converter/presentation/docx_converter_screen.dart';
import 'package:andalan_tools/features/pdf_merger/presentation/pdf_merger_screen.dart';
import 'package:andalan_tools/features/pdf_lock/presentation/pdf_lock_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Andalan Tools'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildToolCard(
              context,
              title: 'Image to PDF',
              subtitle: 'Scan, crop, compress, and combine images into a PDF.',
              icon: Icons.picture_as_pdf_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainCanvasScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildToolCard(
              context,
              title: 'PDF Merger',
              subtitle: 'Gabungkan 2 atau lebih dokumen PDF menjadi satu file utuh.',
              icon: Icons.call_merge_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PdfMergerScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildToolCard(
              context,
              title: 'Lock & Protect PDF',
              subtitle: 'Enkripsi dan amankan file PDF dengan kata sandi AES 256-bit.',
              icon: Icons.lock_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PdfLockScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildToolCard(
              context,
              title: 'PDF Editor & OCR',
              subtitle: 'Extract text, reorder, and delete pages from existing PDFs.',
              icon: Icons.document_scanner_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PdfEditorScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildToolCard(
              context,
              title: 'Image Format Converter',
              subtitle: 'Convert between PNG, JPG, WebP, and HEIC.',
              icon: Icons.transform_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImageConverterScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildToolCard(
              context,
              title: 'Docx to PDF',
              subtitle: 'Extract text from Word documents into PDF.',
              icon: Icons.description_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DocxConverterScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.activeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.activeText, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, color: AppTheme.dividerColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
