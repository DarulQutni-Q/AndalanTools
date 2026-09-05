import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:share_plus/share_plus.dart';
import 'dart:io';

import 'package:file_selector/file_selector.dart';

import 'package:andalan_tools/core/theme/theme.dart';
import '../providers/image_converter_provider.dart';
import 'package:andalan_tools/core/utils/image_processor.dart';

class ImageConverterScreen extends ConsumerWidget {
  const ImageConverterScreen({Key? key}) : super(key: key);

  Future<void> _pickImages(WidgetRef ref) async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Images',
      extensions: <String>['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'],
    );
    
    final List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    
    if (files.isNotEmpty) {
      ref.read(imageConverterProvider.notifier).addImages(files.map((e) => e.path).toList());
    }
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
            onPressed: () => _pickImages(ref),
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
                        child: Text(
                          'No images selected.\nTap + icon above to add.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
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
                                            child: Text(
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
              child: ElevatedButton(
                onPressed: canConvert
                    ? () => ref.read(imageConverterProvider.notifier).convertImages()
                    : (canShare
                        ? () {
                            Share.shareXFiles(
                              state.convertedPaths.map((p) => XFile(p)).toList(),
                              text: 'Converted Images',
                            );
                          }
                        : null),
                child: Text(canShare ? 'Share Converted Images' : 'Convert Images'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

