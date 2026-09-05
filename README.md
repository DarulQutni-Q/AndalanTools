# Andalan Tools

Offline utility tools.

## Testing on iOS from Linux

1. Push this repository to GitHub/GitLab.
2. Sign up for [Codemagic](https://codemagic.io) and connect your repository.
3. The included `codemagic.yaml` is configured to build an unsigned `.ipa`. Start a build in Codemagic.
4. Download the generated `.ipa` artifact.
5. Use [SideStore](https://sidestore.io/) on your iPhone to install and sign the `.ipa` using your Apple ID.

## Update: Fase 2 (PDF Editor & OCR)
- Added `HomeScreen` as the new entry point.
- Added `PdfEditorScreen` to view PDF files using `syncfusion_flutter_pdfviewer`.
- Added Text Extraction capability using `syncfusion_flutter_pdf`. Note: Full image-based OCR on scanned PDFs requires a rasterization step which is complex on mobile without paid licenses or heavy C++ bindings, so the current implementation extracts text from text-based PDFs directly.
- The UI adheres to the established *Premium Utilitarian Minimalism* style guide.

## Update: Fase 3 (Image Format Converter)
- Added `ImageConverterScreen` to convert images between PNG, JPG, WebP, and HEIC.
- Reusing `flutter_image_compress` as it provides native APIs to encode into all these formats efficiently on iOS without heavy pure-Dart image processing libraries.
- The UI maintains the *Premium Utilitarian Minimalism* style guide.
- Added link to the feature from the `HomeScreen`.

## Update: Fase Tambahan (Bagian 5.5 - Split/Delete PDF Pages)
- Implemented Delete Pages: select one or multiple pages and delete them directly.
- Implemented Split PDF: extract selected pages into a new PDF document.
- Uses `syncfusion_flutter_pdf` for manipulating the document pages and layouting into a new file.
- Uses `SfPdfViewer` controller to track the current page number for page selection.

## Update: Fase Tambahan (Bagian 5.3 - Docx to PDF)
- Added `DocxConverterScreen` to extract text from a `.docx` file and generate a new `.pdf` file.
- Used `docx_to_text` for parsing the docx XML payload to extract string contents.
- Used `pdf` package to layout the extracted text into a proper PDF document.
- Follows PRD constraints indicating that full visual fidelity (preserving exact Word layouts, embedded images) is not expected in MVP.

## Update: Codebase Architecture Refactoring
- **Deepening 1**: Extracted `FileService` to `lib/core/utils` to centralize path generation and file writes, ensuring that hardcoded `tempDir` dependencies are no longer leaked across domain services.
- **Deepening 2**: Extracted `ImageProcessor` to unify the handling of `flutter_image_compress` across multiple features (`PdfGenerationService`, `ImageConverterNotifier`).
- **Deepening 3**: Purged system UI calls (like `openFile()`) from Riverpod `StateNotifier`s. The actual file picking logic is now correctly handled by Presentation screens (`DocxConverterScreen`, `ImageConverterScreen`, `PdfEditorScreen`), which then pass the string paths down to the state handlers. 
