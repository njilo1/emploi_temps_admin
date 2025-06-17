import 'package:flutter/material.dart';

class EmploiTable extends StatelessWidget {
  final List<String> jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
  final List<String> heures = [
    '07H30 - 10H00',
    'Pause 1',
    '10H15 - 12H45',
    'Pause 2',
    '13H00 - 15H30',
    'Pause 3',
    '15H45 - 18H15',
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
          // Si c’est une pause, on affiche une ligne spéciale
          if (heure.startsWith('Pause')) {
            return DataRow(
              color: MaterialStateProperty.all(Colors.grey.shade200),
              cells: [
                DataCell(Text(heure, style: const TextStyle(fontStyle: FontStyle.italic))),
                ...jours.map((_) => const DataCell(Text(''))).toList(),
              ],
            );
          }

          // Sinon, afficher les cours normaux
          return DataRow(
            cells: [
              DataCell(Text(heure)),
              ...jours.map((jour) {
                String contenu = emploiData[jour]?[heure] ?? '';
                return DataCell(Text(contenu));
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }
}
