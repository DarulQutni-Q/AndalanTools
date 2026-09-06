import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:share_plus/share_plus.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:andalan_tools/core/theme/theme.dart';
import '../providers/image_converter_provider.dart';
import 'package:andalan_tools/core/utils/image_processor.dart';

class ImageConverterScreen extends ConsumerWidget {
  const ImageConverterScreen({super.key});

  Future<void> _pickFromGallery(WidgetRef ref) async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      ref.read(imageConverterProvider.notifier).addImages(images.map((e) => e.path).toList());
    }
  }

  Future<void> _pickFromFiles(WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final validPaths = result.files.where((f) => f.path != null).map((f) => f.path!).toList();
      if (validPaths.isNotEmpty) {
        ref.read(imageConverterProvider.notifier).addImages(validPaths);
      }
    }
  }

  void _showPickerSourceModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 8),
                child: Text(
                  'Pilih Sumber Gambar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: Color(0xFF4F46E5)),
                ),
                title: const Text('Galeri Foto (Photos)'),
                subtitle: const Text('Pilih foto langsung dari galeri foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery(ref);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder_open_outlined, color: Color(0xFF0EA5E9)),
                ),
                title: const Text('File Manager (Files)'),
                subtitle: const Text('Cari gambar dari folder penyimpanan'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromFiles(ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageConverterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Format Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () => _showPickerSourceModal(context, ref),
          ),
          if (state.originalPaths.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => ref.read(imageConverterProvider.notifier).clearAll(),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: state.originalPaths.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.photo_library_outlined, size: 36, color: Color(0xFF4F46E5)),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Belum Ada Gambar Dipilih',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pilih foto dari Galeri HP atau File Manager untuk dikonversi formatnya.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => _pickFromGallery(ref),
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Buka Galeri Foto'),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: () => _pickFromFiles(ref),
                                icon: const Icon(Icons.folder_open_outlined),
                                label: const Text('Buka File Manager'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.originalPaths.length,
                        itemBuilder: (context, index) {
                          final path = state.originalPaths[index];
                          final bool isConverted = state.convertedPaths.length > index;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox(
                              height: 100,
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(File(path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          path.split('/').last,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (isConverted) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.successBg,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Converted',
                                              style: TextStyle(
                                                color: AppTheme.successText,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        ]
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppTheme.warningText),
                                    onPressed: () => ref.read(imageConverterProvider.notifier).removeImage(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              _buildBottomActionBar(context, ref, state),
            ],
          ),
          if (state.isConverting)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryText),
                    SizedBox(height: 16),
                    Text(
                      'CONVERTING...',
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

  Widget _buildBottomActionBar(BuildContext context, WidgetRef ref, ImageConverterState state) {
    final bool canConvert = state.originalPaths.isNotEmpty && state.convertedPaths.isEmpty;
    final bool canShare = state.convertedPaths.isNotEmpty;

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
                Text('Target Format', style: Theme.of(context).textTheme.bodyMedium),
                DropdownButton<TargetImageFormat>(
                  value: state.selectedFormat,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  items: TargetImageFormat.values.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(
                        f.name.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(imageConverterProvider.notifier).setTargetFormat(val);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Builder(
                builder: (btnCtx) => ElevatedButton(
                  onPressed: canConvert
                      ? () => ref.read(imageConverterProvider.notifier).convertImages()
                      : (canShare
                          ? () {
                              final box = btnCtx.findRenderObject() as RenderBox?;
                              final origin = box != null
                                  ? box.localToGlobal(Offset.zero) & box.size
                                  : Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2);
                              SharePlus.instance.share(
                                ShareParams(
                                  files: state.convertedPaths.map((p) => XFile(p)).toList(),
                                  subject: 'Converted Images',
                                  sharePositionOrigin: origin,
                                ),
                              );
                            }
                          : null),
                  child: Text(canShare ? 'Share Converted Images' : 'Convert Images'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

