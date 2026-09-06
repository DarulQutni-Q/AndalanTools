import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class VaultItem {
  final String path;
  final String name;
  final int sizeBytes;
  final DateTime createdAt;
  final String type; // 'pdf', 'image', 'docx'

  VaultItem({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.createdAt,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'name': name,
    'sizeBytes': sizeBytes,
    'createdAt': createdAt.toIso8601String(),
    'type': type,
  };

  factory VaultItem.fromJson(Map<String, dynamic> json) => VaultItem(
    path: json['path'] as String,
    name: json['name'] as String,
    sizeBytes: json['sizeBytes'] as int? ?? 0,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    type: json['type'] as String? ?? 'pdf',
  );
}

class VaultService {
  static Future<Directory> _getVaultDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory('${appDir.path}/vault');
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    return vaultDir;
  }

  static Future<File> _getIndexFile() async {
    final vaultDir = await _getVaultDirectory();
    return File('${vaultDir.path}/vault_index.json');
  }

  static Future<File> _getSettingsFile() async {
    final vaultDir = await _getVaultDirectory();
    return File('${vaultDir.path}/vault_settings.json');
  }

  /// Get all saved items in the vault
  static Future<List<VaultItem>> getVaultItems() async {
    try {
      final indexFile = await _getIndexFile();
      if (!await indexFile.exists()) return [];

      final content = await indexFile.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);

      final items = <VaultItem>[];
      for (final json in jsonList) {
        final item = VaultItem.fromJson(json as Map<String, dynamic>);
        // Verify file still exists
        if (await File(item.path).exists()) {
          items.add(item);
        }
      }

      // Sort by newest first
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    } catch (e) {
      debugPrint("Error reading vault index: $e");
      return [];
    }
  }

  /// Save a file to the vault
  static Future<VaultItem?> saveToVault({
    required String sourcePath,
    required String name,
    required String type,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      final vaultDir = await _getVaultDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = sourcePath.split('.').last;
      final destinationPath = '${vaultDir.path}/${timestamp}_$name';

      await sourceFile.copy(destinationPath);
      final destFile = File(destinationPath);
      final size = await destFile.length();

      final newItem = VaultItem(
        path: destinationPath,
        name: name.endsWith('.$extension') ? name : '$name.$extension',
        sizeBytes: size,
        createdAt: DateTime.now(),
        type: type,
      );

      final currentItems = await getVaultItems();
      currentItems.insert(0, newItem);

      final indexFile = await _getIndexFile();
      await indexFile.writeAsString(
        jsonEncode(currentItems.map((e) => e.toJson()).toList()),
      );

      return newItem;
    } catch (e) {
      debugPrint("Error saving to vault: $e");
      return null;
    }
  }

  /// Delete an item from the vault
  static Future<bool> deleteItem(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      final currentItems = await getVaultItems();
      currentItems.removeWhere((item) => item.path == path);

      final indexFile = await _getIndexFile();
      await indexFile.writeAsString(
        jsonEncode(currentItems.map((e) => e.toJson()).toList()),
      );

      return true;
    } catch (e) {
      debugPrint("Error deleting vault item: $e");
      return false;
    }
  }

  /// Check if biometric lock is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final file = await _getSettingsFile();
      if (!await file.exists()) return false;
      final content = await file.readAsString();
      final map = jsonDecode(content);
      return map['biometric_enabled'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Set biometric lock enabled
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final file = await _getSettingsFile();
      await file.writeAsString(jsonEncode({'biometric_enabled': enabled}));
    } catch (e) {
      debugPrint("Error saving vault settings: $e");
    }
  }
}
