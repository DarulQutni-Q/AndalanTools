import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'dart:ui';

import 'package:andalan_tools/core/utils/file_service.dart';
import '../domain/ocr_service.dart';

class PdfEditorState {
  final String? originalPdfPath;
  final bool isLoading;
  final String? error;
  final String? extractedText;
  final String? outputPdfPath;
  final int pageCount;
  final List<int> selectedPages; // Used for split/delete

  PdfEditorState({
    this.originalPdfPath,
    this.isLoading = false,
    this.error,
    this.extractedText,
    this.outputPdfPath,
    this.pageCount = 0,
    this.selectedPages = const [],
  });

  PdfEditorState copyWith({
    String? originalPdfPath,
    bool? isLoading,
    String? error,
    String? extractedText,
    String? outputPdfPath,
    int? pageCount,
    List<int>? selectedPages,
  }) {
    return PdfEditorState(
      originalPdfPath: originalPdfPath ?? this.originalPdfPath,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      extractedText: extractedText,
      outputPdfPath: outputPdfPath, // Can be null to clear
      pageCount: pageCount ?? this.pageCount,
      selectedPages: selectedPages ?? this.selectedPages,
    );
  }
}

class PdfEditorNotifier extends StateNotifier<PdfEditorState> {
  PdfEditorNotifier() : super(PdfEditorState());
  final OcrService _ocrService = OcrService();

  Future<void> loadPdfDetails(String path) async {
    state = state.copyWith(isLoading: true, originalPdfPath: path, error: null, outputPdfPath: null, selectedPages: []);
    try {
      final File pdfFile = File(path);
      final List<int> bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      final int count = document.pages.count;
      document.dispose();
      
      state = state.copyWith(isLoading: false, pageCount: count);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Failed to load PDF details: \$e");
    }
  }

  void clearPdf() {
    state = PdfEditorState();
  }
  
  void togglePageSelection(int pageIndex) {
    final currentSelection = List<int>.from(state.selectedPages);
    if (currentSelection.contains(pageIndex)) {
      currentSelection.remove(pageIndex);
    } else {
      currentSelection.add(pageIndex);
    }
    state = state.copyWith(selectedPages: currentSelection);
  }
  
  void clearPageSelection() {
    state = state.copyWith(selectedPages: []);
  }

  Future<void> performOcrOnPdf(String pdfPath) async {
    state = state.copyWith(isLoading: true, error: null, extractedText: null);
    try {
      final File pdfFile = File(pdfPath);
      final List<int> bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      String text = PdfTextExtractor(document).extractText();
      
      if (text.trim().isEmpty) {
        text = "[No text found or this is a scanned PDF. Rendering to image for OCR is required for scanned PDFs.]";
      }

      document.dispose();
      state = state.copyWith(isLoading: false, extractedText: text);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<void> deleteSelectedPages() async {
    if (state.originalPdfPath == null || state.selectedPages.isEmpty) return;
    
    state = state.copyWith(isLoading: true, error: null, outputPdfPath: null);
    try {
      final File pdfFile = File(state.originalPdfPath!);
      final List<int> bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Sort in descending order to avoid index shifting issues when removing
      final pagesToRemove = List<int>.from(state.selectedPages)..sort((a, b) => b.compareTo(a));
      
      for (int pageIndex in pagesToRemove) {
        if (pageIndex >= 0 && pageIndex < document.pages.count) {
           document.pages.removeAt(pageIndex);
        }
      }
      
      final outputPath = await FileService.generateTempPath('.pdf');
      await FileService.writeBytes(outputPath, await document.save());
      
      document.dispose();
      
      state = state.copyWith(
        isLoading: false, 
        outputPdfPath: outputPath, 
        originalPdfPath: outputPath, // Update preview to new file
        selectedPages: [], // Clear selection
      );
      
      // Reload details for new count
      loadPdfDetails(outputPath);
      
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Failed to delete pages: \$e");
    }
  }
  
  Future<void> splitPdf() async {
     if (state.originalPdfPath == null || state.selectedPages.isEmpty) return;
    
    state = state.copyWith(isLoading: true, error: null, outputPdfPath: null);
    try {
      final File pdfFile = File(state.originalPdfPath!);
      final List<int> bytes = await pdfFile.readAsBytes();
      final PdfDocument originalDoc = PdfDocument(inputBytes: bytes);
      
      final PdfDocument newDoc = PdfDocument();
      
      final pagesToExtract = List<int>.from(state.selectedPages)..sort();
      
      for (int pageIndex in pagesToExtract) {
        if (pageIndex >= 0 && pageIndex < originalDoc.pages.count) {
           final PdfPage templatePage = originalDoc.pages[pageIndex];
           newDoc.pages.add().graphics.drawPdfTemplate(templatePage.createTemplate(), const Offset(0, 0));
        }
      }
      
      final outputPath = await FileService.generateTempPath('.pdf');
      await FileService.writeBytes(outputPath, await newDoc.save());
      
      originalDoc.dispose();
      newDoc.dispose();
      
      state = state.copyWith(
        isLoading: false, 
        outputPdfPath: outputPath, 
        selectedPages: [], // Clear selection
      );
      
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Failed to split PDF: \$e");
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}

final pdfEditorProvider = StateNotifierProvider<PdfEditorNotifier, PdfEditorState>((ref) {
  return PdfEditorNotifier();
});
