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
    // Définir une largeur fixe pour chaque colonne (augmentée pour meilleure lisibilité)
    const double columnWidth = 180.0;
    const double hourColumnWidth = 100.0;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 0,
        dataRowMinHeight: 90, // Augmenté de 60 à 90
        dataRowMaxHeight: 90, // Augmenté de 60 à 90
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
              height: 50, // Augmenté de 40 à 50
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                border: Border(
                  right: BorderSide(color: Colors.teal.shade200, width: 1),
                ),
              ),
              child: const Text(
                'Heure',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal), // Augmenté de 11 à 13
              ),
            ),
          ),
          ...jours.map((jour) => DataColumn(
            label: Container(
              width: columnWidth,
              height: 50, // Augmenté de 40 à 50
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Text(
                jour,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade800), // Augmenté de 11 à 13
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
                  height: 90, // Augmenté de 60 à 90
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
                      fontSize: 11, // Augmenté de 9 à 11
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
                    height: 90, // Augmenté de 60 à 90
                    padding: const EdgeInsets.all(6), // Augmenté de 3 à 6
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: contenu.isNotEmpty ? Colors.white : Colors.grey.shade50,
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    child: contenu.isNotEmpty
                        ? _buildEmploiContent(contenu)
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

  Widget _buildEmploiContent(String contenu) {
    // Diviser le contenu par les sauts de ligne (\n) - format réel de l'API
    final parts = contenu.split('\n');
    
    if (parts.length >= 3) {
      final module = parts[0].trim();
      final salle = parts[1].trim();
      final prof = parts[2].trim();
      
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Module (nom du cours) - plus visible
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              module,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 3),
          // Salle en gras et foncée
          Text(
            salle,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Plus foncé
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Professeur en bleu
          Text(
            prof,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else if (parts.length == 2) {
      // Fallback pour 2 éléments
      final module = parts[0].trim();
      final salle = parts[1].trim();
      
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Module avec fond coloré
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              module,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 3),
          // Salle en gras et foncée
          Text(
            salle,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Plus foncé
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      // Fallback si le format n'est pas correct
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          contenu,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }
}
