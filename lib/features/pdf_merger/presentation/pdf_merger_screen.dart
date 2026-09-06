import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import 'package:andalan_tools/core/theme/theme.dart';
import '../domain/pdf_merger_service.dart';

class PdfItem {
  final String path;
  final String name;
  final int sizeInBytes;

  PdfItem({
    required this.path,
    required this.name,
    required this.sizeInBytes,
  });
}

class PdfMergerScreen extends StatefulWidget {
  const PdfMergerScreen({super.key});

  @override
  State<PdfMergerScreen> createState() => _PdfMergerScreenState();
}

class _PdfMergerScreenState extends State<PdfMergerScreen> {
  final List<PdfItem> _pdfList = [];
  bool _isProcessing = false;

  Future<void> _pickPdfs() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final platformFile in result.files) {
          if (platformFile.path == null) continue;
          final filePath = platformFile.path!;
          final fileName = platformFile.name;
          final fileSize = platformFile.size;

          if (!_pdfList.any((item) => item.path == filePath)) {
            setState(() {
              _pdfList.add(
                PdfItem(
                  path: filePath,
                  name: fileName.isNotEmpty ? fileName : filePath.split('/').last,
                  sizeInBytes: fileSize,
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error picking PDFs: $e");
    }
  }

  void _removePdf(int index) {
    setState(() {
      _pdfList.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _pdfList.clear();
    });
  }

  Future<void> _mergePdfs() async {
    if (_pdfList.length < 2) return;

    setState(() {
      _isProcessing = true;
    });

    final paths = _pdfList.map((e) => e.path).toList();
    final outputPath = await PdfMergerService.mergePdfs(paths);

    setState(() {
      _isProcessing = false;
    });

    if (!mounted) return;

    if (outputPath != null) {
      _showSuccessDialog(outputPath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menggabungkan PDF. Pastikan file PDF valid.')),
      );
    }
  }

  void _showSuccessDialog(String path) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('PDF Berhasil Digabung'),
        content: Text('File gabungan tersimpan:\n${path.split('/').last}'),
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
                    subject: 'Merged PDF from Andalan Tools',
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

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final bool canMerge = _pdfList.length >= 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Merger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah PDF',
            onPressed: _isProcessing ? null : _pickPdfs,
          ),
          if (_pdfList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Hapus Semua',
              onPressed: _isProcessing ? null : _clearAll,
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _pdfList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 56,
                              color: AppTheme.dividerColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada file PDF dipilih.\nMinimal pilih 2 PDF untuk digabung.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _pickPdfs,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Pilih File PDF'),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_pdfList.length} File PDF (Urutkan dengan drag)',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                TextButton.icon(
                                  onPressed: _pickPdfs,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Tambah'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ReorderableListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _pdfList.length,
                              onReorder: (oldIndex, newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) newIndex -= 1;
                                  final item = _pdfList.removeAt(oldIndex);
                                  _pdfList.insert(newIndex, item);
                                });
                              },
                              itemBuilder: (context, index) {
                                final item = _pdfList[index];
                                return Card(
                                  key: ValueKey(item.path + index.toString()),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.activeBg,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: AppTheme.activeText,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    subtitle: Text(
                                      _formatBytes(item.sizeInBytes),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: AppTheme.warningText),
                                          onPressed: () => _removePdf(index),
                                        ),
                                        const Icon(Icons.drag_handle, color: AppTheme.secondaryText),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
              if (_pdfList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canMerge ? _mergePdfs : null,
                        child: Text(
                          canMerge ? 'Gabungkan ${_pdfList.length} PDF Menjadi 1' : 'Pilih Minimal 2 File PDF',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryText),
                    SizedBox(height: 16),
                    Text(
                      'MENGGABUNGKAN DOKUMEN...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
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
}
