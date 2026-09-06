import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import 'package:andalan_tools/core/theme/theme.dart';
import 'package:andalan_tools/core/widgets/ios_widgets.dart';
import '../domain/pdf_compressor_service.dart';
import '../domain/exif_cleaner_service.dart';

enum ToolTab { compressPdf, cleanExif }

class CompressAndCleanScreen extends StatefulWidget {
  const CompressAndCleanScreen({super.key});

  @override
  State<CompressAndCleanScreen> createState() => _CompressAndCleanScreenState();
}

class _CompressAndCleanScreenState extends State<CompressAndCleanScreen> {
  ToolTab _activeTab = ToolTab.compressPdf;

  // PDF Compress State
  String? _selectedPdfPath;
  String? _selectedPdfName;
  int _pdfOriginalSize = 0;
  CompressionLevel _compressionLevel = CompressionLevel.balanced;
  bool _isCompressing = false;
  CompressionResult? _compressionResult;

  // EXIF Clean State
  List<String> _selectedImagePaths = [];
  bool _isInspecting = false;
  ExifReport? _exifReport;
  bool _isCleaning = false;
  List<String> _cleanedImagePaths = [];

  // -------------------------------------------------------------
  // PDF Methods
  // -------------------------------------------------------------
  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
        final file = result.files.single;
        setState(() {
          _selectedPdfPath = file.path!;
          _selectedPdfName = file.name;
          _pdfOriginalSize = file.size;
          _compressionResult = null;
        });
      }
    } catch (e) {
      debugPrint("Error picking PDF: $e");
    }
  }

  Future<void> _startCompression() async {
    if (_selectedPdfPath == null) return;
    setState(() => _isCompressing = true);

    final result = await PdfCompressorService.compressPdf(
      inputPath: _selectedPdfPath!,
      level: _compressionLevel,
    );

    setState(() {
      _isCompressing = false;
      _compressionResult = result;
    });

    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengompresi PDF. Silakan coba file lain.')),
      );
    }
  }

  // -------------------------------------------------------------
  // EXIF Methods
  // -------------------------------------------------------------
  Future<void> _pickImages(ImageSource source) async {
    try {
      List<String> paths = [];
      if (source == ImageSource.gallery) {
        final picker = ImagePicker();
        final images = await picker.pickMultiImage();
        paths = images.map((e) => e.path).toList();
      } else {
        final result = await FilePicker.pickFiles(
          type: FileType.image,
          allowMultiple: true,
        );
        if (result != null) {
          paths = result.files.where((f) => f.path != null).map((f) => f.path!).toList();
        }
      }

      if (paths.isNotEmpty) {
        setState(() {
          _selectedImagePaths = paths;
          _cleanedImagePaths = [];
          _isInspecting = true;
        });

        // Inspect the first image for sample report
        final report = await ExifCleanerService.inspectImage(paths.first);
        setState(() {
          _exifReport = report;
          _isInspecting = false;
        });
      }
    } catch (e) {
      debugPrint("Error picking images for EXIF: $e");
    }
  }

  Future<void> _cleanExif() async {
    if (_selectedImagePaths.isEmpty) return;
    setState(() => _isCleaning = true);

    final cleaned = await ExifCleanerService.cleanMultipleImages(_selectedImagePaths);

    setState(() {
      _isCleaning = false;
      _cleanedImagePaths = cleaned;
    });

    if (cleaned.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cleaned.length} foto berhasil dibersihkan dari metadata EXIF!'),
          backgroundColor: AppTheme.successText,
        ),
      );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasColor,
      appBar: AppBar(
        title: const Text('Kompres & Bersih EXIF'),
      ),
      body: Column(
        children: [
          // iOS Segmented Control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: IosSegmentedControl<ToolTab>(
              groupValue: _activeTab,
              children: const {
                ToolTab.compressPdf: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Kompresi PDF', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                ),
                ToolTab.cleanExif: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Bersihkan EXIF', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                ),
              },
              onValueChanged: (tab) {
                if (tab != null) setState(() => _activeTab = tab);
              },
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _activeTab == ToolTab.compressPdf
                  ? _buildCompressPdfView()
                  : _buildCleanExifView(),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // View 1: Kompresi PDF
  // -------------------------------------------------------------
  Widget _buildCompressPdfView() {
    return SingleChildScrollView(
      key: const ValueKey('compress_view'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedPdfPath == null)
            IosBouncyCard(
              onTap: _pickPdf,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.subtleFill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.dividerColor, width: 0.8),
                    ),
                    child: const Icon(Icons.picture_as_pdf_outlined, size: 28, color: AppTheme.primaryText),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Berkas PDF',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pilih file PDF yang ukurannya ingin dikompresi agar lebih hemat ruang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                  ),
                ],
              ),
            )
          else ...[
            // File Info Card
            IosBouncyCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.subtleFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.dividerColor, width: 0.8),
                    ),
                    child: const Icon(Icons.description_outlined, color: AppTheme.primaryText, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPdfName ?? 'Dokumen PDF',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Ukuran saat ini: ${_formatBytes(_pdfOriginalSize)}',
                          style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.secondaryText),
                    onPressed: () => setState(() {
                      _selectedPdfPath = null;
                      _compressionResult = null;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Compression Level Selector
            const Text(
              'Tingkat Kompresi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 10),
            IosSegmentedControl<CompressionLevel>(
              groupValue: _compressionLevel,
              children: const {
                CompressionLevel.low: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Ringan', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
                CompressionLevel.balanced: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Seimbang', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
                CompressionLevel.high: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Maksimal', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
              },
              onValueChanged: (val) {
                if (val != null) setState(() => _compressionLevel = val);
              },
            ),
            const SizedBox(height: 24),

            // Process Button
            ElevatedButton(
              onPressed: _isCompressing ? null : _startCompression,
              child: _isCompressing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Mulai Kompresi PDF'),
            ),

            // Result Display
            if (_compressionResult != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.dividerColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x04000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: AppTheme.primaryText, size: 24),
                        const SizedBox(width: 10),
                        const Text(
                          'Kompresi Berhasil',
                          style: TextStyle(color: AppTheme.primaryText, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryText,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${_compressionResult!.savingsPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ukuran Awal: ${_formatBytes(_compressionResult!.originalSizeBytes)}',
                          style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                        ),
                        Text(
                          'Ukuran Baru: ${_formatBytes(_compressionResult!.compressedSizeBytes)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryText, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => OpenFilex.open(_compressionResult!.outputPath),
                            icon: const Icon(Icons.visibility_outlined, size: 18),
                            label: const Text('Buka'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Builder(
                            builder: (btnCtx) => ElevatedButton.icon(
                              onPressed: () {
                                final box = btnCtx.findRenderObject() as RenderBox?;
                                final origin = box != null
                                    ? box.localToGlobal(Offset.zero) & box.size
                                    : Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2);
                                SharePlus.instance.share(
                                  ShareParams(
                                    files: [XFile(_compressionResult!.outputPath)],
                                    subject: 'PDF Dikompresi',
                                    sharePositionOrigin: origin,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.share_rounded, size: 18),
                              label: const Text('Bagikan'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // View 2: Pembersih EXIF
  // -------------------------------------------------------------
  Widget _buildCleanExifView() {
    return SingleChildScrollView(
      key: const ValueKey('clean_exif_view'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedImagePaths.isEmpty) ...[
            IosBouncyCard(
              onTap: () => _pickImages(ImageSource.gallery),
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.subtleFill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.dividerColor, width: 0.8),
                    ),
                    child: const Icon(Icons.shield_outlined, size: 28, color: AppTheme.primaryText),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Foto dari Galeri',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Hapus jejak lokasi GPS, tipe HP, dan tanggal sebelum foto dibagikan ke publik.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pickImages(ImageSource.camera),
              icon: const Icon(Icons.folder_open_outlined, size: 18),
              label: const Text('Pilih dari File Manager'),
            ),
          ] else ...[
            // Image Status & Privacy Report
            IosBouncyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.photo_library_rounded, color: Color(0xFF059669), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_selectedImagePaths.length} Foto Dipilih',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryText),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.secondaryText),
                        onPressed: () => setState(() {
                          _selectedImagePaths = [];
                          _cleanedImagePaths = [];
                          _exifReport = null;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_isInspecting)
                    const Center(child: CircularProgressIndicator())
                  else if (_exifReport != null && _exifReport!.hasAnyMetadata) ...[
                    const Text(
                      'Metadata Terdeteksi yang Berpotensi Bahaya:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFFD97706)),
                    ),
                    const SizedBox(height: 8),
                    ..._exifReport!.detectedItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item, style: const TextStyle(fontSize: 12.5, color: AppTheme.primaryText))),
                          ],
                        ),
                      ),
                    ),
                  ] else
                    const Text(
                      'Tidak ada metadata sensitif khusus terdeteksi, pembersihan tetap dianjurkan.',
                      style: TextStyle(color: AppTheme.secondaryText, fontSize: 12.5),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _isCleaning ? null : _cleanExif,
              icon: _isCleaning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.cleaning_services_rounded, size: 20),
              label: Text(_isCleaning ? 'Membersihkan...' : 'Bersihkan EXIF Sekarang'),
            ),

            if (_cleanedImagePaths.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.successBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.successText.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_user_rounded, color: AppTheme.successText, size: 26),
                        SizedBox(width: 10),
                        Text(
                          'Foto Sudah Bersih & Aman!',
                          style: TextStyle(color: AppTheme.successText, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Semua koordinat GPS, informasi kamera, dan data identitas telah dihapus.',
                      style: TextStyle(fontSize: 12.5, color: AppTheme.secondaryText),
                    ),
                    const SizedBox(height: 14),
                    Builder(
                      builder: (btnCtx) => ElevatedButton.icon(
                        onPressed: () {
                          final box = btnCtx.findRenderObject() as RenderBox?;
                          final origin = box != null
                              ? box.localToGlobal(Offset.zero) & box.size
                              : Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2);
                          SharePlus.instance.share(
                            ShareParams(
                              files: _cleanedImagePaths.map((p) => XFile(p)).toList(),
                              subject: 'Foto Bersih EXIF',
                              sharePositionOrigin: origin,
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text('Bagikan Foto Bersih'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
