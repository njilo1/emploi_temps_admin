import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class EmploiGenerator {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ⏰ Tranches horaires pour les cours
  final List<String> tranchesHoraires = [
    '07:30 - 09:30',
    '09:45 - 11:45',
    '12:00 - 14:00',
    '14:15 - 16:15',
    '16:30 - 18:30',
  ];

  // 📆 Jours de la semaine
  final List<String> joursSemaine = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
  ];

  /// 🔁 Génère automatiquement les emplois du temps dans Firestore
  Future<void> genererEmploisAutomatiquement() async {
    final classes = await _db.collection('classes').get();
    final modules = await _db.collection('modules').get();
    final salles = await _db
        .collection('salles')
        .where('disponible', isEqualTo: true)
        .get();
    final professeurs = await _db.collection('professeurs').get();

    final Map<String, Set<String>> salleOccupation = {}; // {jour-heure: [salleId]}
    final Map<String, Set<String>> profOccupation = {}; // {jour-heure: [profId]}
    final Map<String, Set<String>> classeOccupation = {}; // {jour-heure: [classeId]}

    // 🧹 Supprime tous les anciens emplois
    final anciensEmplois = await _db.collection('emplois').get();
    for (final doc in anciensEmplois.docs) {
      await doc.reference.delete();
    }

    // 🔄 Parcours de chaque module à planifier
    for (final module in modules.docs) {
      final data = module.data();
      final rawClasse = data['classe'];
      final rawProf = data['prof'];
      final classeId = rawClasse is DocumentReference ? rawClasse.id : rawClasse;
      final profId = rawProf is DocumentReference ? rawProf.id : rawProf;
      final int volume = (data['volume_horaire'] as num).toInt();
      int heuresRestantes = volume;

      for (final jour in joursSemaine) {
        for (final heure in tranchesHoraires) {
          final cleOccupation = '$jour-$heure';

          // ✅ Vérifie si une salle est disponible
          String? salleChoisie;
          for (final salle in salles.docs) {
            final salleId = salle.id;
            salleOccupation.putIfAbsent(cleOccupation, () => <String>{});
            if (!salleOccupation[cleOccupation]!.contains(salleId)) {
              salleChoisie = salleId;
              break;
            }
          }
          // ✅ Vérifie si le prof et la classe sont disponibles

          // ✅ Vérifie si le prof et la classe sont disponibles
          profOccupation.putIfAbsent(cleOccupation, () => <String>{});
          classeOccupation.putIfAbsent(cleOccupation, () => <String>{});

          if (salleChoisie != null &&
              !profOccupation[cleOccupation]!.contains(profId) &&
              !classeOccupation[cleOccupation]!.contains(classeId)) {
            salleOccupation[cleOccupation]!.add(salleChoisie);
            profOccupation[cleOccupation]!.add(profId);
            classeOccupation[cleOccupation]!.add(classeId);

            // 📥 Enregistre le créneau dans Firestore
            await _db.collection('emplois').add({
              'classe': classeId,
              'jour': jour,
              'heure': heure,
              'salle': salleChoisie,
              'module': module.id,
              'prof': profId,
            });

            debugPrint(
                'Créneau réservé: classe $classeId, module ${module.id}, salle $salleChoisie, $jour $heure');

            heuresRestantes -= 2;
            if (heuresRestantes <= 0) break;
          } else {
            debugPrint('Collision détectée pour $classeId le $jour à $heure');
          }
        }
        if (heuresRestantes <= 0) break;
      }
    }
  } 

  /// Importe un planning à partir d'un JSON
  Future<void> importFromJson(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      final className = entry.key.replaceAll('_', ' ');
      final clsSnap = await _db
          .collection('classes')
          .where('nom', isEqualTo: className)
          .limit(1)
          .get();
      if (clsSnap.docs.isEmpty) continue;
      final classeId = clsSnap.docs.first.id;
      final jours = Map<String, dynamic>.from(entry.value);
      for (final jourEntry in jours.entries) {
        final jour = jourEntry.key;
        final heures = Map<String, dynamic>.from(jourEntry.value);
        for (final heureEntry in heures.entries) {
          final heure = heureEntry.key;
          final detail = heureEntry.value as String;
          final parts = detail.split(' – ');
          final moduleNom = parts.isNotEmpty ? parts[0].trim() : '';
          final salleNom = parts.length > 1 ? parts[1].replaceFirst('Salle ', '').trim() : '';
          final profNom = parts.length > 2 ? parts[2].trim() : '';

          String moduleId = '';
          String salleId = '';
          String profId = '';

          final modSnap = await _db
              .collection('modules')
              .where('nom', isEqualTo: moduleNom)
              .limit(1)
              .get();
          if (modSnap.docs.isNotEmpty) moduleId = modSnap.docs.first.id;

          final salleSnap = await _db
              .collection('salles')
              .where('nom', isEqualTo: salleNom)
              .limit(1)
              .get();
          if (salleSnap.docs.isNotEmpty) salleId = salleSnap.docs.first.id;

          final profSnap = await _db
              .collection('professeurs')
              .where('nom', isEqualTo: profNom)
              .limit(1)
              .get();
          if (profSnap.docs.isNotEmpty) profId = profSnap.docs.first.id;

          await _db.collection('emplois').add({
            'classe': classeId,
            'jour': jour,
            'heure': heure,
            'salle': salleId,
            'module': moduleId,
            'prof': profId,
          });
        }
      }
    }
  }

  /// 📤 Récupère l'emploi du temps d'une classe au format affichable
  Future<Map<String, Map<String, String>>> getEmploisParClasse(String classeId) async {
    debugPrint('📥 Chargement des emplois pour la classe $classeId');
    final snapshot = await _db
        .collection('emplois')
        .where('classe', isEqualTo: classeId)
        .get();

    Map<String, Map<String, String>> emploi = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final jour = data['jour'];
      final heure = data['heure'];
      final moduleId = data['module'];
      final salleId = data['salle'];
      final profId = data['prof'];

      emploi.putIfAbsent(jour, () => <String, String>{});
      emploi[jour]![heure] = "Module: $moduleId\nSalle: $salleId\nProf: $profId";
    }

    return emploi;
  }
}
