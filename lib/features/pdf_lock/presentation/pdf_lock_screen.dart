import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import 'package:andalan_tools/core/theme/theme.dart';
import '../domain/pdf_lock_service.dart';

class PdfLockScreen extends StatefulWidget {
  const PdfLockScreen({super.key});

  @override
  State<PdfLockScreen> createState() => _PdfLockScreenState();
}

class _PdfLockScreenState extends State<PdfLockScreen> {
  String? _selectedPdfPath;
  String? _selectedPdfName;
  int _fileSizeBytes = 0;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isProcessing = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'PDFs',
      extensions: <String>['pdf'],
      mimeTypes: <String>['application/pdf'],
      uniformTypeIdentifiers: <String>['com.adobe.pdf'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file != null) {
      final f = File(file.path);
      int size = 0;
      try {
        size = await f.length();
      } catch (_) {}

      setState(() {
        _selectedPdfPath = file.path;
        _selectedPdfName = file.name.isNotEmpty ? file.name : file.path.split('/').last;
        _fileSizeBytes = size;
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedPdfPath = null;
      _selectedPdfName = null;
      _fileSizeBytes = 0;
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  Future<void> _lockPdf() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (_selectedPdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih file PDF terlebih dahulu.')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kata sandi perlindungan.')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final outputPath = await PdfLockService.lockPdf(
      inputPath: _selectedPdfPath!,
      password: password,
    );

    setState(() {
      _isProcessing = false;
    });

    if (!mounted) return;

    if (outputPath != null) {
      _showSuccessDialog(outputPath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengunci PDF. Pastikan file tidak rusak.')),
      );
    }
  }

  void _showSuccessDialog(String path) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('PDF Berhasil Dikunci 🔒'),
        content: Text(
          'File PDF telah dienkripsi dengan kata sandi:\n\n${path.split('/').last}\n\n'
          'Gunakan kata sandi yang Anda buat untuk membuka file ini di perangkat mana pun.',
        ),
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
                    subject: 'Protected PDF from Andalan Tools',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lock & Protect PDF'),
        actions: [
          if (_selectedPdfPath != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Ganti Dokumen',
              onPressed: _isProcessing ? null : _clearSelection,
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_selectedPdfPath == null) ...[
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 56,
                          color: AppTheme.dividerColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enkripsi PDF dengan kata sandi (AES-256).\nSemua proses berlangsung 100% offline.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _pickPdf,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Pilih File PDF'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.activeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.picture_as_pdf, color: AppTheme.activeText),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedPdfName ?? 'PDF Document',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatBytes(_fileSizeBytes),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _pickPdf,
                            child: const Text('Ganti'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'PENGATURAN KATA SANDI',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Baru',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Kata Sandi',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.security, color: AppTheme.successText, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Enkripsi militer AES 256-bit. File PDF hanya bisa dibuka oleh orang yang memiliki kata sandi.',
                            style: TextStyle(color: AppTheme.successText, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _lockPdf,
                      child: const Text('Kunci & Enkripsi PDF'),
                    ),
                  ),
                ],
              ],
            ),
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
                      'MENGENKRIPSI DOKUMEN...',
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
