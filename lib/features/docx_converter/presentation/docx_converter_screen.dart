import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

import 'package:andalan_tools/core/theme/theme.dart';
import '../providers/docx_converter_provider.dart';

class DocxConverterScreen extends ConsumerWidget {
  const DocxConverterScreen({super.key});

  Future<void> _pickFile(WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx', 'doc'],
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
      ref.read(docxConverterProvider.notifier).setInputFile(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(docxConverterProvider);

    // Show error snackbar if error occurs
    ref.listen<DocxConverterState>(docxConverterProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: \${next.error}')),
        );
      }
      
      if (next.outputPdfPath != null && next.outputPdfPath != previous?.outputPdfPath) {
        _showSuccessDialog(context, next.outputPdfPath!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Docx to PDF'),
        actions: [
          if (state.inputDocxPath != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(docxConverterProvider.notifier).clearFiles(),
            )
        ],
      ),
      body: Stack(
        children: [
          state.inputDocxPath == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description_outlined, size: 48, color: AppTheme.dividerColor),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _pickFile(ref),
                        child: const Text('Select Docx File'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Disclaimer as specified in PRD
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.warningBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.warningText.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, color: AppTheme.warningText, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Note: This MVP extracts the text from the Docx and writes it to a new PDF. '
                                'Complex formatting, images, and exotic layouts will not be preserved 100%.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.warningText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              const Icon(Icons.description, color: AppTheme.activeText, size: 32),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  state.inputDocxPath!.split('/').last,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: state.isConverting
                            ? null
                            : () => ref.read(docxConverterProvider.notifier).convertToPdf(),
                        child: const Text('Convert to PDF'),
                      ),
                    ],
                  ),
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

  void _showSuccessDialog(BuildContext context, String path) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Conversion Successful'),
        content: const Text('Docx text has been converted to PDF.'),
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
                    subject: 'Shared from Andalan Tools',
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
}
