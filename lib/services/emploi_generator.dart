import 'package:cloud_firestore/cloud_firestore.dart';

class EmploiGenerator {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Créneaux horaires conformes au planning officiel
  final List<String> tranchesHoraires = [
    '07H30 - 10H15',
    '10H30 - 13H15',
    '13H30 - 16H15',
    '16H30 - 19H15',
  ];

  final List<String> joursSemaine = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
  ];

  /// Génère automatiquement un emploi du temps respectant les créneaux
  Future<void> genererEmploisAutomatiquement() async {
    final modules = await _db.collection('modules').get();
    final salles = await _db.collection('salles')
        .where('disponible', isEqualTo: true)
        .get();

    final Map<String, Set<String>> salleOccupation = {};
    final Map<String, Set<String>> profOccupation = {};

    // 🔁 Nettoyage des anciens emplois
    final anciensEmplois = await _db.collection('emplois').get();
    for (final doc in anciensEmplois.docs) {
      await doc.reference.delete();
    }

    for (final module in modules.docs) {
      final data = module.data();
      final String classeId = data['classe'];
      final String profId = data['prof'];
      final int volume = (data['volume_horaire'] as num).toInt();

      int heuresRestantes = volume;

      for (final jour in joursSemaine) {
        for (final heure in tranchesHoraires) {
          final cle = '$jour-$heure';

          String? salleChoisie;
          for (final salle in salles.docs) {
            final salleId = salle.id;
            salleOccupation.putIfAbsent(cle, () => {});
            if (!salleOccupation[cle]!.contains(salleId)) {
              salleChoisie = salleId;
              salleOccupation[cle]!.add(salleId);
              break;
            }
          }

          profOccupation.putIfAbsent(cle, () => {});
          if (salleChoisie != null && !profOccupation[cle]!.contains(profId)) {
            profOccupation[cle]!.add(profId);

            await _db.collection('emplois').add({
              'classe': classeId,
              'jour': jour,
              'heure': heure,
              'salle': salleChoisie,
              'module': module.id,
              'prof': profId,
            });

            heuresRestantes -= 3;
            if (heuresRestantes <= 0) break;
          }
        }
        if (heuresRestantes <= 0) break;
      }
    }
  }

  /// Récupération des emplois du temps d’une classe (format lisible)
  Future<Map<String, Map<String, String>>> getEmploisParClasse(String classeId) async {
    final emploisSnap = await _db
        .collection('emplois')
        .where('classe', isEqualTo: classeId)
        .get();

    final modulesSnap = await _db.collection('modules').get();
    final profsSnap = await _db.collection('professeurs').get();
    final sallesSnap = await _db.collection('salles').get();

    final modulesMap = {
      for (var m in modulesSnap.docs) m.id: m.data()['nom'] ?? 'Module'
    };
    final profsMap = {
      for (var p in profsSnap.docs) p.id: p.data()['nom'] ?? 'Professeur'
    };
    final sallesMap = {
      for (var s in sallesSnap.docs) s.id: s.data()['nom'] ?? 'Salle'
    };

    Map<String, Map<String, String>> emploi = {};

    for (final doc in emploisSnap.docs) {
      final data = doc.data();
      final jour = data['jour'];
      final heure = data['heure'];
      final moduleId = data['module'];
      final salleId = data['salle'];
      final profId = data['prof'];

      final moduleNom = modulesMap[moduleId] ?? 'Module';
      final salleNom = sallesMap[salleId] ?? 'Salle';
      final profNom = profsMap[profId] ?? 'Prof';

      final contenu = "$moduleNom – Salle $salleNom – $profNom";

      emploi.putIfAbsent(jour, () => {});
      emploi[jour]![heure] = contenu;
    }

    return emploi;
  }
}
