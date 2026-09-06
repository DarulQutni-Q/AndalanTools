import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import 'package:andalan_tools/core/theme/theme.dart';
import '../providers/pdf_editor_provider.dart';

class PdfEditorScreen extends ConsumerStatefulWidget {
  const PdfEditorScreen({super.key});

  @override
  ConsumerState<PdfEditorScreen> createState() => _PdfEditorScreenState();
}

class _PdfEditorScreenState extends ConsumerState<PdfEditorScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();

  Future<void> _pickFile(WidgetRef ref) async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
        ref.read(pdfEditorProvider.notifier).loadPdfDetails(result.files.single.path!);
      }
    } catch (e) {
      debugPrint("Error picking PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pdfEditorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Editor'),
        actions: [
          if (state.originalPdfPath != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(pdfEditorProvider.notifier).clearPdf(),
            )
        ],
      ),
      body: state.originalPdfPath == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, size: 48, color: AppTheme.dividerColor),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _pickFile(ref),
                    child: const Text('Open PDF Document'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                SfPdfViewer.file(
                  File(state.originalPdfPath!),
                  controller: _pdfViewerController,
                  canShowScrollHead: false,
                  canShowScrollStatus: false,
                  pageLayoutMode: PdfPageLayoutMode.continuous,
                  onPageChanged: (PdfPageChangedDetails details) {
                    // Optional: keep track of current page
                  },
                ),
                if (state.isLoading)
                  Container(
                    color: Colors.white.withOpacity(0.8),
                    child: const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryText),
                    ),
                  ),
                // Page indicator overlay
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Text(
                      'Page: \${_pdfViewerController.pageNumber} / \${_pdfViewerController.pageCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Selection indicator overlay
                if (state.selectedPages.isNotEmpty)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.activeBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '\${state.selectedPages.length} selected',
                        style: TextStyle(color: AppTheme.activeText, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildActionToolbar(context, ref, state),
                ),
              ],
            ),
    );
  }

  Widget _buildActionToolbar(BuildContext context, WidgetRef ref, PdfEditorState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: const Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToolbarAction(
                  context,
                  icon: state.selectedPages.contains(_pdfViewerController.pageNumber - 1) 
                        ? Icons.check_box 
                        : Icons.check_box_outline_blank,
                  label: 'Select Pg',
                  onTap: () {
                    // Page numbers in controller are 1-based, we need 0-based for internal logic
                    final int currentPageIndex = _pdfViewerController.pageNumber - 1;
                    if (currentPageIndex >= 0) {
                      ref.read(pdfEditorProvider.notifier).togglePageSelection(currentPageIndex);
                    }
                  },
                ),
                _buildToolbarAction(
                  context,
                  icon: Icons.text_snippet_outlined,
                  label: 'Extract Text',
                  onTap: () async {
                    if (state.originalPdfPath != null) {
                      await ref.read(pdfEditorProvider.notifier).performOcrOnPdf(state.originalPdfPath!);
                      final newState = ref.read(pdfEditorProvider);
                      if (context.mounted && newState.extractedText != null) {
                        _showExtractedTextDialog(context, newState.extractedText!);
                      }
                    }
                  },
                ),
                _buildToolbarAction(
                  context,
                  icon: Icons.content_cut_outlined,
                  label: 'Split',
                  onTap: state.selectedPages.isEmpty ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Select pages to split first.')),
                    );
                  } : () async {
                    await ref.read(pdfEditorProvider.notifier).splitPdf();
                    final newState = ref.read(pdfEditorProvider);
                    if (context.mounted && newState.outputPdfPath != null) {
                       _showSuccessDialog(context, newState.outputPdfPath!, "Split successful");
                    }
                  },
                ),
                _buildToolbarAction(
                  context,
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  color: AppTheme.warningText,
                  onTap: state.selectedPages.isEmpty ? () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Select pages to delete first.')),
                    );
                  } : () async {
                      await ref.read(pdfEditorProvider.notifier).deleteSelectedPages();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pages deleted.')),
                        );
                      }
                    },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExtractedTextDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extracted Text'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
              Navigator.pop(context);
            },
            child: const Text('Copy All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showSuccessDialog(BuildContext context, String path, String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title),
        content: Text('Saved to: $path'),
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
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color ?? AppTheme.primaryText, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
