import 'package:flutter/material.dart';
import 'package:andalan_tools/core/theme/theme.dart';
import 'package:andalan_tools/core/widgets/ios_widgets.dart';
import 'package:andalan_tools/features/image_to_pdf/presentation/main_canvas_screen.dart';
import 'package:andalan_tools/features/pdf_editor/presentation/pdf_editor_screen.dart';
import 'package:andalan_tools/features/image_converter/presentation/image_converter_screen.dart';
import 'package:andalan_tools/features/docx_converter/presentation/docx_converter_screen.dart';
import 'package:andalan_tools/features/pdf_merger/presentation/pdf_merger_screen.dart';
import 'package:andalan_tools/features/pdf_lock/presentation/pdf_lock_screen.dart';
import 'package:andalan_tools/features/compress_and_clean/presentation/compress_and_clean_screen.dart';
import 'package:andalan_tools/features/vault/presentation/vault_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasColor,
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            AndalanLogo(size: 24, color: AppTheme.primaryText),
            SizedBox(width: 10),
            Text(
              'Andalan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: AppTheme.primaryText,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: IosHeaderVaultPill(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VaultScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Minimalist Privacy Status Card (No neon dots, no AI clutter)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.dividerColor, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x04000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.subtleFill,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pemrosesan Privat & Lokal',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryText,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Semua berkas diproses di perangkat tanpa koneksi server.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryText,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                'Alat Dokumen',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryText,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 1. Image to PDF
            _buildInteractiveToolCard(
              context,
              title: 'Image to PDF',
              subtitle: 'Scan berkas kamera, crop, dan gabungkan foto jadi dokumen PDF.',
              icon: Icons.picture_as_pdf_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainCanvasScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            // 2. PDF Merger
            _buildInteractiveToolCard(
              context,
              title: 'PDF Merger',
              subtitle: 'Satukan beberapa file PDF menjadi satu dokumen tersusun.',
              icon: Icons.call_merge_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PdfMergerScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            // 3. Lock & Protect PDF
            _buildInteractiveToolCard(
              context,
              title: 'Kunci & Proteksi PDF',
              subtitle: 'Kunci PDF dengan enkripsi password AES 256-bit standar.',
              icon: Icons.lock_outline_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PdfLockScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            // 4. Kompresi PDF & Bersih EXIF
            _buildInteractiveToolCard(
              context,
              title: 'Kompres & Bersih EXIF',
              subtitle: 'Kecilkan ukuran file PDF dan bersihkan metadata lokasi GPS foto.',
              icon: Icons.compress_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CompressAndCleanScreen()),
                );
              },
            ),
            const SizedBox(height: 10),


            // 6. PDF Editor & OCR
            _buildInteractiveToolCard(
              context,
              title: 'PDF Editor & OCR',
              subtitle: 'Ekstrak teks gambar, atur tata urutan, dan hapus halaman PDF.',
              icon: Icons.auto_stories_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PdfEditorScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            // 7. Image Format Converter
            _buildInteractiveToolCard(
              context,
              title: 'Konversi Format Gambar',
              subtitle: 'Konversi format gambar instan antara PNG, JPG, WebP, dan HEIC.',
              icon: Icons.transform_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImageConverterScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            // 8. Docx to PDF
            _buildInteractiveToolCard(
              context,
              title: 'Docx to PDF',
              subtitle: 'Konversi naskah Word (.docx/.doc) dengan tabel & gambar ke PDF.',
              icon: Icons.description_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DocxConverterScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IosBouncyCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: BorderRadius.circular(14),
      backgroundColor: AppTheme.surfaceColor,
      border: Border.all(color: AppTheme.dividerColor, width: 1),
      boxShadow: const [
        BoxShadow(
          color: Color(0x04000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sleek Minimalist Icon Squircle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.subtleFill,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppTheme.dividerColor.withOpacity(0.6), width: 0.8),
            ),
            child: Icon(icon, color: AppTheme.primaryText, size: 22),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.secondaryText,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFA1A1AA),
            size: 20,
          ),
        ],
      ),
    );
  }
}
