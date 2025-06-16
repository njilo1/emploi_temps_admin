import 'package:flutter/material.dart';

class EmploiTable extends StatelessWidget {
  final List<String> jours = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
  ];
  final List<String> heures = [
    '07:30 - 09:30',
    '09:45 - 11:45',
    '12:00 - 14:00',
    '14:15 - 16:15',
    '16:30 - 18:30',
  ];

  final Map<String, Map<String, String>> emploiData;

  EmploiTable({required this.emploiData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.tealAccent),
        columns: [
          const DataColumn(label: Text('Heure')),
          ...jours.map((jour) => DataColumn(label: Text(jour))),
        ],
        rows: heures.map((heure) {
          return DataRow(
            cells: [
              DataCell(Text(heure)),
              ...jours.map((jour) {
                String valeur = emploiData[jour]?[heure] ?? '';
                return DataCell(Text(valeur));
              }).toList()
            ],
          );
        }).toList(),
      ),
    );
  }
}
