import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import 'package:andalan_tools/core/theme/theme.dart';
import 'package:andalan_tools/core/widgets/ios_widgets.dart';
import '../domain/vault_service.dart';
import '../domain/biometric_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool _isLoading = true;
  bool _isBiometricEnabled = false;
  bool _isAuthenticated = false;
  List<VaultItem> _items = [];
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initVault();
  }

  Future<void> _initVault() async {
    setState(() => _isLoading = true);
    final bioEnabled = await VaultService.isBiometricEnabled();
    _isBiometricEnabled = bioEnabled;

    if (bioEnabled) {
      _isAuthenticated = false;
    } else {
      _isAuthenticated = true;
    }

    await _loadItems();
    setState(() => _isLoading = false);

    // Auto prompt authentication if enabled
    if (bioEnabled && !_isAuthenticated) {
      _promptAuthentication();
    }
  }

  Future<void> _loadItems() async {
    final items = await VaultService.getVaultItems();
    setState(() => _items = items);
  }

  Future<void> _promptAuthentication() async {
    HapticFeedback.lightImpact();
    final success = await BiometricService.authenticate(
      reason: 'Buka Brankas Dokumen Privat Anda',
    );
    if (success && mounted) {
      HapticFeedback.mediumImpact();
      setState(() => _isAuthenticated = true);
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    await VaultService.setBiometricEnabled(value);
    setState(() => _isBiometricEnabled = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? 'Proteksi Face ID / Biometrik diaktifkan!'
              : 'Proteksi biometrik dinonaktifkan.'),
        ),
      );
    }
  }

  Future<void> _deleteItem(VaultItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Berkas?'),
        content: Text('Apakah Anda yakin ingin menghapus "${item.name}" dari brankas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await VaultService.deleteItem(item.path);
      await _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berkas telah dihapus dari brankas.')),
        );
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'image':
      case 'jpg':
      case 'png':
        return Icons.image_outlined;
      case 'docx':
      case 'doc':
        return Icons.description_outlined;
      default:
        return Icons.picture_as_pdf_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasColor,
      appBar: AppBar(
        title: const Text('Brankas & Riwayat'),
        actions: [
          if (_isAuthenticated)
            IconButton(
              icon: Icon(
                _isBiometricEnabled ? Icons.fingerprint : Icons.lock_open_rounded,
                color: _isBiometricEnabled ? AppTheme.successText : AppTheme.secondaryText,
              ),
              tooltip: 'Pengaturan Kunci',
              onPressed: () => _showSettingsSheet(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (!_isAuthenticated ? _buildLockView() : _buildVaultContentView()),
    );
  }

  // -------------------------------------------------------------
  // Lock View (iOS Biometric Gate)
  // -------------------------------------------------------------
  Widget _buildLockView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: IosGlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppTheme.primaryText,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.lock_outline_rounded, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Brankas Terkunci',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: AppTheme.primaryText),
              ),
              const SizedBox(height: 6),
              const Text(
                'Autentikasi Face ID atau kata sandi diperlukan untuk melihat berkas privat Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppTheme.secondaryText, height: 1.4),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _promptAuthentication,
                  icon: const Icon(Icons.fingerprint, size: 20),
                  label: const Text('Buka dengan Face ID'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Unlocked Content View
  // -------------------------------------------------------------
  Widget _buildVaultContentView() {
    final filtered = _items.where((item) {
      if (_selectedFilter != 'Semua') {
        if (_selectedFilter == 'PDF' && item.type != 'pdf') return false;
        if (_selectedFilter == 'Gambar' && item.type != 'image') return false;
        if (_selectedFilter == 'Word' && item.type != 'docx') return false;
      }
      if (_searchQuery.isNotEmpty) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Search bar & Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Cari berkas di brankas...',
                  hintStyle: const TextStyle(fontSize: 13.5, color: AppTheme.secondaryText),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppTheme.secondaryText),
                  filled: true,
                  fillColor: AppTheme.subtleFill,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ['Semua', 'PDF', 'Gambar', 'Word'].map((f) {
                    final isSelected = _selectedFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryAccent,
                        backgroundColor: AppTheme.surfaceColor,
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : AppTheme.dividerColor,
                          width: 1,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedFilter = f);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // List View
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.folder_special_outlined, size: 34, color: AppTheme.secondaryText),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Brankas Masih Kosong',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryText),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Hasil konversi dari fitur-fitur Andalan Tools dapat disimpan ke brankas lokal ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final typeIcon = _getTypeIcon(item.type);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: IosBouncyCard(
                        onTap: () => OpenFilex.open(item.path),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppTheme.subtleFill,
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(color: AppTheme.dividerColor.withOpacity(0.6), width: 0.8),
                              ),
                              child: Icon(typeIcon, color: AppTheme.primaryText, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.primaryText),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${_formatBytes(item.sizeBytes)} • ${_formatDate(item.createdAt)}',
                                    style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.secondaryText),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              onSelected: (action) {
                                if (action == 'open') {
                                  OpenFilex.open(item.path);
                                } else if (action == 'share') {
                                  SharePlus.instance.share(
                                    ShareParams(
                                      files: [XFile(item.path)],
                                      subject: item.name,
                                    ),
                                  );
                                } else if (action == 'delete') {
                                  _deleteItem(item);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'open',
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility_outlined, size: 18),
                                      SizedBox(width: 10),
                                      Text('Buka'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'share',
                                  child: Row(
                                    children: [
                                      Icon(Icons.share_outlined, size: 18),
                                      SizedBox(width: 10),
                                      Text('Bagikan'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                      SizedBox(width: 10),
                                      Text('Hapus', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pengaturan Keamanan Brankas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.primaryText),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kunci akses brankas secara otomatis setiap kali aplikasi dibuka.',
                style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
              ),
              const SizedBox(height: 20),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Kunci dengan Face ID / Sandi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: const Text('Gunakan proteksi biometrik perangkat', style: TextStyle(fontSize: 12.5)),
                value: _isBiometricEnabled,
                activeColor: AppTheme.primaryAccent,
                onChanged: (val) {
                  Navigator.pop(ctx);
                  _toggleBiometric(val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
