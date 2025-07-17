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
    // Définir une largeur fixe pour chaque colonne (augmentée pour éviter les coupures)
    const double columnWidth = 190.0;
    const double hourColumnWidth = 110.0;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 0,
        dataRowMinHeight: 100, // Augmenté pour plus d'espace
        dataRowMaxHeight: 100, // Augmenté pour plus d'espace
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade200, width: 1),
          verticalInside: BorderSide(color: Colors.grey.shade200, width: 1),
          top: BorderSide(color: Colors.grey.shade300, width: 2),
          bottom: BorderSide(color: Colors.grey.shade300, width: 2),
          left: BorderSide(color: Colors.grey.shade300, width: 2),
          right: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        columns: [
          DataColumn(
            label: Container(
              width: hourColumnWidth,
              height: 60, // Augmenté pour plus d'espace
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue.shade100, // Uniformisé avec les autres colonnes
                border: Border(
                  right: BorderSide(color: Colors.teal.shade300, width: 2),
                ),
              ),
              child: Text(
                'Heure',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue.shade800),
              ),
            ),
          ),
          ...jours.asMap().entries.map((entry) {
            final index = entry.key;
            final jour = entry.value;
            final isLast = index == jours.length - 1;
            
            return DataColumn(
              label: Container(
                width: columnWidth,
                height: 60, // Augmenté pour plus d'espace
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  border: Border(
                    right: isLast ? BorderSide.none : BorderSide(color: Colors.blue.shade200, width: 1),
                  ),
                ),
                child: Text(
                  jour,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue.shade800),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
        ],
        rows: heures.map((heure) {
          final isPause = heure.contains('Pause') || heure.contains('pause');
          return DataRow(
            cells: [
              DataCell(
                Container(
                  width: hourColumnWidth,
                  height: 100, // Augmenté pour plus d'espace
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100, // Uniformisé avec les autres colonnes
                    border: Border(
                      right: BorderSide(color: Colors.teal.shade300, width: 2),
                    ),
                  ),
                  child: Text(
                    isPause ? 'Pause' : heure,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontStyle: isPause ? FontStyle.italic : FontStyle.normal,
                      color: isPause ? Colors.grey[600] : Colors.blue[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ...jours.asMap().entries.map((entry) {
                final index = entry.key;
                final jour = entry.value;
                final isLast = index == jours.length - 1;
                final contenu = emploiData[jour]?[heure] ?? '';
                
                return DataCell(
                  Container(
                    width: columnWidth,
                    height: 100, // Augmenté pour plus d'espace
                    padding: const EdgeInsets.all(10), // Augmenté pour plus d'espace
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: contenu.isNotEmpty ? Colors.blue.shade50 : Colors.grey.shade50, // Uniformisé
                      border: Border(
                        right: isLast ? BorderSide.none : BorderSide(color: Colors.grey.shade200, width: 1),
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
