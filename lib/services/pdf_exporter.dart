
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfExporter {
  Future<void> exportEmploi(String path, Map<String, Map<String, String>> emploi,
      {String title = 'Emploi du temps'}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              _buildTable(emploi),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      // Web-specific download - we'll handle this differently
      // For now, just save to a file path that works for web
      _downloadPdfWeb(bytes);
    } else {
      // Desktop/mobile file save
      final file = File(path);
      await file.writeAsBytes(bytes);
    }
  }

  void _downloadPdfWeb(Uint8List bytes) {
    // Web download implementation
    // This will be implemented when needed for web
    print('PDF download for web not yet implemented');
  }

  pw.Widget _buildTable(Map<String, Map<String, String>> data) {
    final jours = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
    ];
    final heures = [
      '07H30 - 10H00',
      '10H15 - 12H45',
      '13H00 - 15H45',
      '16H00 - 18H15',
    ];

    return pw.Table.fromTextArray(
      headers: ['Heure', ...jours],
      data: heures.map((h) {
        return [
          h,
          ...jours.map((j) => data[j]?[h] ?? '').toList(),
        ];
      }).toList(),
    );
  }
}