import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:andalan_tools/core/utils/file_service.dart';

class DocxConverterService {
  /// Converts a .docx file into a structured PDF document preserving
  /// headings, tables, and embedded images from `word/media/`.
  static Future<String?> convertDocxToPdf(String inputPath) async {
    try {
      final file = File(inputPath);
      final bytes = await file.readAsBytes();

      final pdf = pw.Document();
      final List<pw.Widget> widgets = [];

      try {
        final archive = ZipDecoder().decodeBytes(bytes);

        // 1. Extract all media images from word/media/
        final Map<String, Uint8List> mediaMap = {};
        for (final file in archive) {
          if (file.isFile && file.name.startsWith('word/media/')) {
            final filename = file.name.split('/').last;
            mediaMap[filename] = Uint8List.fromList(file.content as List<int>);
          }
        }

        // 2. Locate and parse word/document.xml
        ArchiveFile? docXmlFile;
        for (final file in archive) {
          if (file.name == 'word/document.xml') {
            docXmlFile = file;
            break;
          }
        }

        if (docXmlFile != null) {
          final xmlContent = String.fromCharCodes(docXmlFile.content as List<int>);
          final document = xml.XmlDocument.parse(xmlContent);

          // Iterate through body elements (paragraphs and tables)
          final body = document.findAllElements('w:body').firstOrNull;
          if (body != null) {
            int imageIndex = 0;
            final mediaList = mediaMap.values.toList();

            for (final child in body.children.whereType<xml.XmlElement>()) {
              if (child.name.local == 'p') {
                // Check if this paragraph contains a drawing/image
                final drawings = child.findAllElements('w:drawing');
                if (drawings.isNotEmpty && imageIndex < mediaList.length) {
                  final imgBytes = mediaList[imageIndex++];
                  widgets.add(
                    pw.Container(
                      margin: const pw.EdgeInsets.symmetric(vertical: 8),
                      alignment: pw.Alignment.center,
                      child: pw.Image(
                        pw.MemoryImage(imgBytes),
                        height: 180,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  );
                }

                // Extract paragraph text
                final texts = child.findAllElements('w:t').map((e) => e.innerText).join();
                if (texts.trim().isEmpty) continue;

                // Check for heading styles
                final isHeading = child.findAllElements('w:pStyle').any((e) {
                  final val = e.getAttribute('w:val')?.toLowerCase() ?? '';
                  return val.contains('heading') || val.contains('title');
                });

                if (isHeading) {
                  widgets.add(
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
                      child: pw.Text(
                        texts,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                    ),
                  );
                } else {
                  widgets.add(
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Text(
                        texts,
                        style: const pw.TextStyle(
                          fontSize: 11.5,
                          lineSpacing: 1.4,
                          color: PdfColors.black,
                        ),
                      ),
                    ),
                  );
                }
              } else if (child.name.local == 'tbl') {
                // Table Element
                final rows = child.findAllElements('w:tr');
                if (rows.isNotEmpty) {
                  final tableRows = <pw.TableRow>[];
                  for (final tr in rows) {
                    final cells = tr.findAllElements('w:tc');
                    final cellWidgets = <pw.Widget>[];

                    for (final tc in cells) {
                      final cellText = tc.findAllElements('w:t').map((e) => e.innerText).join(' ');
                      cellWidgets.add(
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            cellText,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      );
                    }

                    if (cellWidgets.isNotEmpty) {
                      tableRows.add(pw.TableRow(children: cellWidgets));
                    }
                  }

                  if (tableRows.isNotEmpty) {
                    widgets.add(
                      pw.Container(
                        margin: const pw.EdgeInsets.symmetric(vertical: 10),
                        child: pw.Table(
                          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
                          children: tableRows,
                        ),
                      ),
                    );
                  }
                }
              }
            }

            // Append any remaining images that were in media/ but not bound inline
            while (imageIndex < mediaList.length) {
              final imgBytes = mediaList[imageIndex++];
              widgets.add(
                pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 8),
                  alignment: pw.Alignment.center,
                  child: pw.Image(
                    pw.MemoryImage(imgBytes),
                    height: 180,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              );
            }
          }
        }
      } catch (parseError) {
        debugPrint("Advanced OpenXML parse fallback: $parseError");
      }

      // Fallback: If no structured elements were parsed, fallback to docxToText
      if (widgets.isEmpty) {
        final text = docxToText(bytes);
        if (text.isEmpty) return null;

        widgets.add(
          pw.Text(
            text,
            style: const pw.TextStyle(
              fontSize: 12,
              lineSpacing: 1.5,
            ),
          ),
        );
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (pw.Context context) => widgets,
        ),
      );

      final outputPath = await FileService.generateTempPath('.pdf');
      await FileService.writeBytes(outputPath, await pdf.save());

      return outputPath;
    } catch (e) {
      debugPrint("Error converting Docx to PDF: $e");
      return null;
    }
  }
}
