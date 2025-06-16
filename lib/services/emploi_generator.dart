import 'package:cloud_firestore/cloud_firestore.dart';

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
    final Map<String, Set<String>> profOccupation = {};   // {jour-heure: [profId]}

    // 🧹 Supprime tous les anciens emplois
    final anciensEmplois = await _db.collection('emplois').get();
    for (final doc in anciensEmplois.docs) {
      await doc.reference.delete();
    }

    // 🔄 Parcours de chaque module à planifier
    for (final module in modules.docs) {
      final data = module.data();
      final classeId = data['classe'];   // ✅ ID correct (réel) de la classe
      final profId = data['prof'];       // ✅ ID correct du professeur
      final volume = data['volume_horaire'];
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
              salleOccupation[cleOccupation]!.add(salleId);
              break;
            }
          }

          // ✅ Vérifie si le prof est disponible
          profOccupation.putIfAbsent(cleOccupation, () => <String>{});
          if (salleChoisie != null &&
              !profOccupation[cleOccupation]!.contains(profId)) {
            profOccupation[cleOccupation]!.add(profId);

            // 📥 Enregistre le créneau dans Firestore
            await _db.collection('emplois').add({
              'classe': classeId,
              'jour': jour,
              'heure': heure,
              'salle': salleChoisie,
              'module': module.id,
              'prof': profId,
            });

            heuresRestantes -= 2;
            if (heuresRestantes <= 0) break;
          }
        }
        if (heuresRestantes <= 0) break;
      }
    }
  }

  /// 📤 Récupère l'emploi du temps d'une classe au format affichable
  Future<Map<String, Map<String, String>>> getEmploisParClasse(String classeId) async {
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
