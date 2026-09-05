import 'package:flutter_riverpod/flutter_riverpod.dart';

// State model for an image page
class ImagePageModel {
  final String path;
  final String originalPath; // to keep track if it was cropped

  ImagePageModel({required this.path, required this.originalPath});

  ImagePageModel copyWith({String? path, String? originalPath}) {
    return ImagePageModel(
      path: path ?? this.path,
      originalPath: originalPath ?? this.originalPath,
    );
  }
}

class ImageListNotifier extends StateNotifier<List<ImagePageModel>> {
  ImageListNotifier() : super([]);

  void addImages(List<String> newPaths) {
    final newModels = newPaths.map((p) => ImagePageModel(path: p, originalPath: p)).toList();
    state = [...state, ...newModels];
  }

  void removeImage(int index) {
    final newState = [...state];
    newState.removeAt(index);
    state = newState;
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newState = [...state];
    final item = newState.removeAt(oldIndex);
    newState.insert(newIndex, item);
    state = newState;
  }

  void updateImage(int index, String newPath) {
    final newState = [...state];
    newState[index] = newState[index].copyWith(path: newPath);
    state = newState;
  }
  
  void clear() {
    state = [];
  }
}

final imageListProvider = StateNotifierProvider<ImageListNotifier, List<ImagePageModel>>((ref) {
  return ImageListNotifier();
});

// Quality selection provider (High, Medium, Low)
enum CompressQuality { high, medium, low }

final compressQualityProvider = StateProvider<CompressQuality>((ref) => CompressQuality.medium);

// Processing state provider
final isProcessingProvider = StateProvider<bool>((ref) => false);
