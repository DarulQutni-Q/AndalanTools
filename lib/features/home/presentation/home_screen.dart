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
        title: const Row(
          children: [
            Text('Andalan Tools'),
            SizedBox(width: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.activeBg,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryAccent,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: AppTheme.primaryAccent),
            tooltip: 'Brankas Dokumen',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VaultScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Privacy & Offline Status Hero Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF34D399),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF34D399),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '100% OFFLINE & PRIVAT',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Semua file diproses langsung di HP tanpa upload ke cloud/server.',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Daftar Fitur',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const Spacer(),
                Text(
                  '8 Alat Tersedia',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 1. Image to PDF
            _buildInteractiveToolCard(
              context,
              title: 'Image to PDF',
              subtitle: 'Scan berkas kamera, crop, kompres, dan gabungkan foto jadi dokumen PDF.',
              tag: 'POPULER',
              tagColor: const Color(0xFFF43F5E),
              gradientColors: const [Color(0xFFFF5E62), Color(0xFFFF9966)],
              icon: Icons.picture_as_pdf_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainCanvasScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // 2. PDF Merger
            _buildInteractiveToolCard(
              context,
              title: 'PDF Merger',
              subtitle: 'Satukan beberapa file dokumen PDF menjadi satu urutan yang rapi.',
              tag: 'GABUNGKAN',
              tagColor: const Color(0xFF6366F1),
              gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              icon: Icons.call_merge_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PdfMergerScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // 3. Lock & Protect PDF
            _buildInteractiveToolCard(
              context,
              title: 'Lock & Protect PDF',
              subtitle: 'Kunci & amankan PDF dengan enkripsi password AES 256-bit standar industri.',
              tag: 'ENKRIPSI',
              tagColor: const Color(0xFF059669),
              gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
              icon: Icons.lock_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PdfLockScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // 4. Kompresi PDF & Bersih EXIF (BARU)
            _buildInteractiveToolCard(
              context,
              title: 'Kompres & Bersih EXIF',
              subtitle: 'Kecilkan ukuran file PDF & hapus data lokasi GPS foto demi privasi.',
              tag: 'HEMAT & PRIVASI',
              tagColor: const Color(0xFF0284C7),
              gradientColors: const [Color(0xFF0284C7), Color(0xFF06B6D4)],
              icon: Icons.compress_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CompressAndCleanScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // 5. Brankas & Riwayat Dokumen (BARU)
            _buildInteractiveToolCard(
              context,
              title: 'Brankas & Riwayat',
              subtitle: 'Simpan riwayat berkas lokal terproteksi biometrik Face ID / Touch ID.',
              tag: 'FACE ID',
              tagColor: const Color(0xFF10B981),
              gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
              icon: Icons.shield_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VaultScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // 6. PDF Editor & OCR
            _buildInteractiveToolCard(
              context,
              title: 'PDF Editor & OCR',
              subtitle: 'Ekstrak teks gambar, atur ulang urutan, serta hapus halaman PDF.',
              tag: 'OCR & EDIT',
              tagColor: const Color(0xFFD97706),
              gradientColors: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
              icon: Icons.auto_stories_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PdfEditorScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // 7. Image Format Converter
            _buildInteractiveToolCard(
              context,
              title: 'Image Format Converter',
              subtitle: 'Konversi format gambar instan antara PNG, JPG, WebP, dan HEIC.',
              tag: 'MULTI-FORMAT',
              tagColor: const Color(0xFF8B5CF6),
              gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA855F7)],
              icon: Icons.transform_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImageConverterScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // 8. Docx to PDF (Enhanced)
            _buildInteractiveToolCard(
              context,
              title: 'Docx to PDF',
              subtitle: 'Konversi naskah Word (.docx/.doc) dengan tabel & gambar ke PDF.',
              tag: 'GAMBAR & TABEL',
              tagColor: const Color(0xFF2563EB),
              gradientColors: const [Color(0xFF2563EB), Color(0xFF3B82F6)],
              icon: Icons.description_rounded,
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
    required String tag,
    required Color tagColor,
    required List<Color> gradientColors,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IosBouncyCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vibrant Gradient Icon Squircle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.32),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          // Text & Tag
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryText,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: tagColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
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
          const SizedBox(width: 10),
          // Arrow Action Pill
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.canvasColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.dividerColor, width: 1),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.secondaryText,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
