import 'package:flutter/material.dart';

class EmploiTable extends StatelessWidget {
  final List<String> jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
  
  final Map<String, Map<String, String>> emploiData;

  EmploiTable({required this.emploiData});

  // Extraire toutes les heures uniques des données
  List<String> get heures {
    final Set<String> heuresSet = {};
    for (final jour in emploiData.keys) {
      if (emploiData[jour] != null) {
        heuresSet.addAll(emploiData[jour]!.keys);
      }
    }
    
    // Trier les heures dans l'ordre chronologique
    final List<String> heuresList = heuresSet.toList();
    heuresList.sort((a, b) {
      // Extraire l'heure de début pour le tri
      final heureA = a.split(' - ')[0];
      final heureB = b.split(' - ')[0];
      return heureA.compareTo(heureB);
    });
    
    return heuresList;
  }

  @override
  Widget build(BuildContext context) {
    // Définir une largeur fixe pour chaque colonne
    const double columnWidth = 160.0;
    const double hourColumnWidth = 100.0;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 0,
        dataRowMinHeight: 80,
        dataRowMaxHeight: 80,
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
          verticalInside: BorderSide(color: Colors.grey.shade300, width: 1),
          top: BorderSide(color: Colors.grey.shade400, width: 1),
          bottom: BorderSide(color: Colors.grey.shade400, width: 1),
          left: BorderSide(color: Colors.grey.shade400, width: 1),
          right: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
        columns: [
          DataColumn(
            label: Container(
              width: hourColumnWidth,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                border: Border(
                  right: BorderSide(color: Colors.teal.shade200, width: 1),
                ),
              ),
              child: const Text(
                'Heure',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal),
              ),
            ),
          ),
          ...jours.map((jour) => DataColumn(
            label: Container(
              width: columnWidth,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Text(
                jour,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade800),
                textAlign: TextAlign.center,
              ),
            ),
          )),
        ],
        rows: heures.map((heure) {
          final isPause = heure.contains('Pause') || heure.contains('pause');
          return DataRow(
            cells: [
              DataCell(
                Container(
                  width: hourColumnWidth,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      right: BorderSide(color: Colors.teal.shade200, width: 1),
                    ),
                  ),
                  child: Text(
                    isPause ? 'Pause' : heure,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      fontStyle: isPause ? FontStyle.italic : FontStyle.normal,
                      color: isPause ? Colors.grey[600] : Colors.teal.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ...jours.map((jour) {
                final contenu = emploiData[jour]?[heure] ?? '';
                return DataCell(
                  Container(
                    width: columnWidth,
                    height: 80,
                    padding: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: contenu.isNotEmpty ? Colors.white : Colors.grey.shade50,
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    child: contenu.isNotEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: contenu.split('\n').map((line) {
                              final trimmedLine = line.trim();
                              if (trimmedLine.isEmpty) return const SizedBox.shrink();
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 0.5),
                                child: Text(
                                  trimmedLine,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: trimmedLine.contains('Salle') 
                                        ? FontWeight.w400 
                                        : trimmedLine.contains('Dr.') || trimmedLine.contains('Prof.')
                                            ? FontWeight.w500
                                            : FontWeight.w600,
                                    color: trimmedLine.contains('Salle') 
                                        ? Colors.grey[700]
                                        : trimmedLine.contains('Dr.') || trimmedLine.contains('Prof.')
                                            ? Colors.blue[700]
                                            : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          )
                        : const SizedBox.shrink(),
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }
}
