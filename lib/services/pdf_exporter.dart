import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfExporter {
  Future<void> export(Map<String, Map<String, String>> data, String title) async {
    final doc = pw.Document();
    final jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    final heures = [
      '07H30 - 10H15',
      '10H30 - 13H15',
      '14H00 - 16H45'
    ];

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(),
                      ...jours.map((j) => pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(j),
                          ))
                    ],
                  ),
                  ...heures.map(
                    (h) => pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(4), child: pw.Text(h)),
                        ...jours.map((j) {
                          final text = data[j]?[h] ?? '';
                          return pw.Padding(
                              padding: const pw.EdgeInsets.all(4), child: pw.Text(text));
                        })
                      ],
                    ),
                  )
                ],
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }
}
