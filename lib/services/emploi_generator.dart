import 'package:cloud_firestore/cloud_firestore.dart';

class EmploiGenerator {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<String> tranchesHoraires = [
    '07H30 - 10H15',
    '10H30 - 13H15',
    '13H15 - 14H00', // Pause
    '14H00 - 16H45',
    '17H00 - 19H45',
  ];

  final List<String> joursSemaine = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
  ];

  /// 🔁 Génère automatiquement un emploi du temps optimisé
  Future<void> genererEmploisAutomatiquement() async {
    final modules = await _db.collection('modules').get();
    final salles = await _db.collection('salles').where('disponible', isEqualTo: true).get();
    final classes = await _db.collection('classes').get();

    final Map<String, int> effectifClasse = {
      for (final c in classes.docs) c.id: (c.data()['effectif'] as num?)?.toInt() ?? 0,
    };

    final Map<String, Set<String>> salleOccupation = {};
    final Map<String, Set<String>> profOccupation = {};

    // Supprimer les anciens emplois
    final anciensEmplois = await _db.collection('emplois').get();
    for (final doc in anciensEmplois.docs) {
      await doc.reference.delete();
    }

    for (final module in modules.docs) {
      final data = module.data();
      final String classeId = data['classe'];
      final String profId = data['prof'];
      final int volume = (data['volume_horaire'] as num?)?.toInt() ?? 3;
      int heuresRestantes = volume;

      for (final jour in joursSemaine) {
        for (final heure in tranchesHoraires) {
          if (heure.contains("Pause")) continue;

          final cle = '$jour-$heure';

          // 🔍 Salle disponible compatible avec l’effectif
          String? salleChoisie;
          for (final salle in salles.docs) {
            final salleData = salle.data();
            final salleId = salle.id;
            final int capacite = (salleData['effectif'] as num?)?.toInt() ?? 0;

            if (capacite >= (effectifClasse[classeId] ?? 0)) {
              salleOccupation.putIfAbsent(cle, () => {});
              if (!salleOccupation[cle]!.contains(salleId)) {
                salleChoisie = salleId;
                salleOccupation[cle]!.add(salleId);
                break;
              }
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

  /// 📊 Récupère un emploi du temps lisible pour une classe
  Future<Map<String, Map<String, String>>> getEmploisParClasse(String classeId) async {
    final emploisSnap = await _db.collection('emplois').where('classe', isEqualTo: classeId).get();
    final modulesSnap = await _db.collection('modules').get();
    final profsSnap = await _db.collection('professeurs').get();
    final sallesSnap = await _db.collection('salles').get();

    final modulesMap = {for (var m in modulesSnap.docs) m.id: m.data()['nom'] ?? 'Module inconnu'};
    final profsMap = {for (var p in profsSnap.docs) p.id: p.data()['nom'] ?? 'Professeur inconnu'};
    final sallesMap = {for (var s in sallesSnap.docs) s.id: s.data()['nom'] ?? 'Salle inconnue'};

    Map<String, Map<String, String>> emploi = {};

    for (final doc in emploisSnap.docs) {
      final data = doc.data();
      final String jour = data['jour'];
      final String heure = data['heure'];
      final String moduleId = data['module'];
      final String salleId = data['salle'];
      final String profId = data['prof'];

      final moduleNom = modulesMap[moduleId] ?? 'Module';
      final salleNom = sallesMap[salleId] ?? 'Salle';
      final profNom = profsMap[profId] ?? 'Professeur';

      final contenu = "$moduleNom – $salleNom – $profNom";

      emploi.putIfAbsent(jour, () => {});
      emploi[jour]![heure] = contenu;
    }

    return emploi;
  }

  /// 📥 Importe un emploi du temps depuis un JSON structuré
  Future<void> importerDepuisJson(Map<String, dynamic> data) async {
    final emplois = data['emplois'] as List<dynamic>?;
    if (emplois == null) return;

    final classes = await _db.collection('classes').get();
    final salles = await _db.collection('salles').get();
    final modules = await _db.collection('modules').get();
    final profs = await _db.collection('professeurs').get();

    final classesMap = {for (var c in classes.docs) c.data()['nom']: c.id};
    final sallesMap = {for (var s in salles.docs) s.data()['nom']: s.id};
    final modulesMap = {for (var m in modules.docs) m.data()['nom']: m.id};
    final profsMap = {for (var p in profs.docs) p.data()['nom']: p.id};

    // 🧹 Supprimer anciens emplois
    final anciens = await _db.collection('emplois').get();
    for (final doc in anciens.docs) {
      await doc.reference.delete();
    }

    for (final e in emplois) {
      final String? classeId = classesMap[e['classe']];
      final String? moduleId = modulesMap[e['module']];
      final String? profId = profsMap[e['prof']];
      final String? salleId = sallesMap[e['salle']];
      final jour = e['jour'];
      final heure = e['heure'];

      if ([classeId, moduleId, profId, salleId, jour, heure].contains(null)) {
        print("⚠️ Entrée ignorée : $e");
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
    }
  }
}
