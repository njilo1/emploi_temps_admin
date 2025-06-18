import 'package:flutter/material.dart';

class EmploiTable extends StatelessWidget {
  final List<String> jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
  final List<String> heures = [
    '07H30 - 10H15',
    '10H30 - 13H15',
    '13H15 - 14H00', // Pause de midi
    '14H00 - 16H45',
    '17H00 - 19H45',
  ];

  final Map<String, Map<String, String>> emploiData;

  EmploiTable({required this.emploiData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: [
          const DataColumn(
            label: Text(
              'Heure',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...jours.map((jour) => DataColumn(
            label: Text(
              jour,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
        ],
        rows: heures.map((heure) {
          final isPause = heure.contains('Pause');
          return DataRow(
            color: isPause
                ? MaterialStateProperty.all(Colors.grey.shade300)
                : null,
            cells: [
              DataCell(Text(isPause ? 'Pause' : heure,
                  style: isPause
                      ? const TextStyle(fontStyle: FontStyle.italic)
                      : null)),
              ...jours.map((jour) {
                final contenu = emploiData[jour]?[heure] ?? '';
                return DataCell(Text(contenu));
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }
}
