import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
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
      '07H30 - 10H15',
      '10H30 - 13H15',
      '14H00 - 16H45',
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
