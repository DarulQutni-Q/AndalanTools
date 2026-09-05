import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import 'package:andalan_tools/core/theme/theme.dart';
import 'package:andalan_tools/core/utils/pdf_generation_service.dart';
import '../providers/image_list_provider.dart';

class MainCanvasScreen extends ConsumerWidget {
  const MainCanvasScreen({super.key});

  Future<void> _pickImages(WidgetRef ref) async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      ref.read(imageListProvider.notifier).addImages(images.map((e) => e.path).toList());
    }
  }

  Future<void> _scanDocument(BuildContext context, WidgetRef ref) async {
    try {
      dynamic scannedDocs = await FlutterDocScanner().getScanDocuments();
      
      if (scannedDocs != null) {
        List<String> paths = [];
        if (scannedDocs is String) {
          paths = [scannedDocs];
        } else if (scannedDocs is List) {
          paths = scannedDocs.map((e) => e.toString()).toList();
        }
        
        if (paths.isNotEmpty) {
          ref.read(imageListProvider.notifier).addImages(paths);
          return;
        }
      }
    } catch (_) {
      // Document scanner unavailable (e.g. simulator or camera restricted).
      // Provide seamless fallback to standard camera photo capture.
      if (context.mounted) {
        final picker = ImagePicker();
        try {
          final XFile? photo = await picker.pickImage(source: ImageSource.camera);
          if (photo != null) {
            ref.read(imageListProvider.notifier).addImages([photo.path]);
          }
        } catch (err) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kamera tidak tersedia atau izin belum diberikan.')),
            );
          }
        }
      }
    }
  }

  Future<void> _cropImage(BuildContext context, WidgetRef ref, int index, String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppTheme.primaryText,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Crop Image',
          cancelButtonTitle: 'Cancel',
          doneButtonTitle: 'Done',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      ref.read(imageListProvider.notifier).updateImage(index, croppedFile.path);
    }
  }

  Future<void> _generatePdf(BuildContext context, WidgetRef ref) async {
    final images = ref.read(imageListProvider);
    if (images.isEmpty) return;

    ref.read(isProcessingProvider.notifier).state = true;

    final quality = ref.read(compressQualityProvider);
    final pdfPath = await PdfGenerationService.generatePdf(
      imagePaths: images.map((e) => e.path).toList(),
      quality: quality,
    );

    ref.read(isProcessingProvider.notifier).state = false;

    if (pdfPath != null) {
      if (context.mounted) {
        _showSuccessDialog(context, pdfPath);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat PDF. Coba kembali.')),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String path) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Success'),
        content: const Text('PDF generated successfully.'),
        actions: [
          Builder(
            builder: (btnCtx) => TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                final box = btnCtx.findRenderObject() as RenderBox?;
                final origin = box != null
                    ? box.localToGlobal(Offset.zero) & box.size
                    : Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2);
                SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(path)],
                    subject: 'PDF from Andalan Tools',
                    sharePositionOrigin: origin,
                  ),
                );
              },
              child: const Text('Share'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              OpenFilex.open(path);
            },
            child: const Text('Open'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageList = ref.watch(imageListProvider);
    final isProcessing = ref.watch(isProcessingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () => _pickImages(ref),
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: () => _scanDocument(context, ref),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: imageList.isEmpty
                    ? Center(
                        child: Text(
                          'No images selected.\nTap icons above to add.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: imageList.length,
                        onReorder: (oldIndex, newIndex) {
                          ref.read(imageListProvider.notifier).reorderImages(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final image = imageList[index];
                          return Card(
                            key: ValueKey(image.originalPath + index.toString()),
                            margin: const EdgeInsets.only(bottom: 12),
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox(
                              height: 120,
                              child: Row(
                                children: [
                                  // Reorder Handle
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(Icons.drag_indicator, color: AppTheme.dividerColor),
                                  ),
                                  // Image preview
                                  Container(
                                    width: 100,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(File(image.path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Page Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Page ${index + 1}',
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Actions
                                  IconButton(
                                    icon: const Icon(Icons.crop),
                                    onPressed: () => _cropImage(context, ref, index, image.path),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppTheme.warningText),
                                    onPressed: () => ref.read(imageListProvider.notifier).removeImage(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              _buildBottomActionBar(context, ref, imageList.isNotEmpty),
            ],
          ),
          if (isProcessing)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryText),
                    SizedBox(height: 16),
                    Text(
                      'PROCESSING...',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, WidgetRef ref, bool hasImages) {
    final quality = ref.watch(compressQualityProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quality', style: Theme.of(context).textTheme.bodyMedium),
                DropdownButton<CompressQuality>(
                  value: quality,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  items: CompressQuality.values.map((q) {
                    return DropdownMenuItem(
                      value: q,
                      child: Text(
                        q.name.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(compressQualityProvider.notifier).state = val;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasImages ? () => _generatePdf(context, ref) : null,
                child: const Text('Generate PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
