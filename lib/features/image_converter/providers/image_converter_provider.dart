
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:andalan_tools/core/utils/image_processor.dart';

class ImageConverterState {
  final List<String> originalPaths;
  final List<String> convertedPaths;
  final bool isConverting;
  final TargetImageFormat selectedFormat;

  ImageConverterState({
    this.originalPaths = const [],
    this.convertedPaths = const [],
    this.isConverting = false,
    this.selectedFormat = TargetImageFormat.jpg,
  });

  ImageConverterState copyWith({
    List<String>? originalPaths,
    List<String>? convertedPaths,
    bool? isConverting,
    TargetImageFormat? selectedFormat,
  }) {
    return ImageConverterState(
      originalPaths: originalPaths ?? this.originalPaths,
      convertedPaths: convertedPaths ?? this.convertedPaths,
      isConverting: isConverting ?? this.isConverting,
      selectedFormat: selectedFormat ?? this.selectedFormat,
    );
  }
}

class ImageConverterNotifier extends StateNotifier<ImageConverterState> {
  ImageConverterNotifier() : super(ImageConverterState());

  void addImages(List<String> paths) {
     state = state.copyWith(
        originalPaths: [...state.originalPaths, ...paths],
        convertedPaths: [], // Reset converted when new items added
      );
  }

  void removeImage(int index) {
    final newOriginals = [...state.originalPaths];
    newOriginals.removeAt(index);
    state = state.copyWith(originalPaths: newOriginals, convertedPaths: []);
  }

  void setTargetFormat(TargetImageFormat format) {
    state = state.copyWith(selectedFormat: format);
  }

  Future<void> convertImages() async {
    if (state.originalPaths.isEmpty) return;
    
    state = state.copyWith(isConverting: true);
    
    List<String> results = [];

    for (int i = 0; i < state.originalPaths.length; i++) {
      final originalPath = state.originalPaths[i];

      try {
        final convertedPath = await ImageProcessor.convertToFormat(originalPath, state.selectedFormat);
        if (convertedPath != null) {
          results.add(convertedPath);
        }
      } catch (e) {
        print("Conversion failed for \$originalPath: \$e");
      }
    }

    state = state.copyWith(
      isConverting: false,
      convertedPaths: results,
    );
  }
  
  void clearAll() {
    state = ImageConverterState();
  }
}

final imageConverterProvider = StateNotifierProvider<ImageConverterNotifier, ImageConverterState>((ref) {
  return ImageConverterNotifier();
});