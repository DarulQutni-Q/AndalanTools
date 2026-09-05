import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/docx_converter_service.dart';

class DocxConverterState {
  final String? inputDocxPath;
  final String? outputPdfPath;
  final bool isConverting;
  final String? error;

  DocxConverterState({
    this.inputDocxPath,
    this.outputPdfPath,
    this.isConverting = false,
    this.error,
  });

  DocxConverterState copyWith({
    String? inputDocxPath,
    String? outputPdfPath,
    bool? isConverting,
    String? error,
  }) {
    return DocxConverterState(
      inputDocxPath: inputDocxPath ?? this.inputDocxPath,
      outputPdfPath: outputPdfPath, // Can clear
      isConverting: isConverting ?? this.isConverting,
      error: error, // Can clear
    );
  }
}

class DocxConverterNotifier extends StateNotifier<DocxConverterState> {
  DocxConverterNotifier() : super(DocxConverterState());

  void setInputFile(String path) {
    state = state.copyWith(inputDocxPath: path, outputPdfPath: null, error: null);
  }

  void clearFiles() {
    state = DocxConverterState();
  }

  Future<void> convertToPdf() async {
    if (state.inputDocxPath == null) return;
    
    state = state.copyWith(isConverting: true, error: null);
    
    try {
      final pdfPath = await DocxConverterService.convertDocxToPdf(state.inputDocxPath!);
      
      if (pdfPath != null) {
        state = state.copyWith(isConverting: false, outputPdfPath: pdfPath);
      } else {
        state = state.copyWith(isConverting: false, error: "Failed to extract text or create PDF.");
      }
    } catch (e) {
      state = state.copyWith(isConverting: false, error: e.toString());
    }
  }
}

final docxConverterProvider = StateNotifierProvider<DocxConverterNotifier, DocxConverterState>((ref) {
  return DocxConverterNotifier();
});
