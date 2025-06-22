import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';

/// Service permettant d'importer un planning depuis un fichier Excel
class ExcelImporter {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Lit le fichier [path], insère les emplois dans Firestore et renvoie
  /// le nombre d'entrées importées.
  Future<int> importFile(String path) async {
    final bytes = File(path).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    // Collecte des entrées sous forme de Map<String, String>
    final List<Map<String, String>> lignes = [];
    for (final table in excel.tables.values) {
      for (var rowIndex = 1; rowIndex < table.maxRows; rowIndex++) {
        final row = table.row(rowIndex);
        if (row.isEmpty) continue;
        final classe = row[0]?.value?.toString();
        final jour = row.length > 1 ? row[1]?.value?.toString() : null;
        final heure = row.length > 2 ? row[2]?.value?.toString() : null;
        final module = row.length > 3 ? row[3]?.value?.toString() : null;
        final prof = row.length > 4 ? row[4]?.value?.toString() : null;
        final salle = row.length > 5 ? row[5]?.value?.toString() : null;
        if ([classe, jour, heure, module, prof, salle].contains(null)) continue;
        lignes.add({
          'classe': classe!,
          'jour': jour!,
          'heure': heure!,
          'module': module!,
          'prof': prof!,
          'salle': salle!,
        });
      }
    }

    if (lignes.isEmpty) return 0;

    // Récupération des références Firestore
    final classes = await _db.collection('classes').get();
    final salles = await _db.collection('salles').get();
    final modules = await _db.collection('modules').get();
    final profs = await _db.collection('professeurs').get();

    final classesMap = {for (var c in classes.docs) c.data()['nom']: c.id};
    final sallesMap = {for (var s in salles.docs) s.data()['nom']: s.id};
    final modulesMap = {for (var m in modules.docs) m.data()['nom']: m.id};
    final profsMap = {for (var p in profs.docs) p.data()['nom']: p.id};

    // Nettoyage des anciens emplois
    final anciens = await _db.collection('emplois').get();
    for (final doc in anciens.docs) {
      await doc.reference.delete();
    }

    int count = 0;
    for (final e in lignes) {
      final classeId = classesMap[e['classe']];
      final moduleId = modulesMap[e['module']];
      final profId = profsMap[e['prof']];
      final salleId = sallesMap[e['salle']];
      final jour = e['jour'];
      final heure = e['heure'];

      if ([classeId, moduleId, profId, salleId, jour, heure].contains(null)) {
        continue;
      }

      await _db.collection('emplois').add({
        'classe': classeId,
        'jour': jour,
        'heure': heure,
        'module': moduleId,
        'prof': profId,
        'salle': salleId,
      });
      count++;
    }
    return count;
  }
}
