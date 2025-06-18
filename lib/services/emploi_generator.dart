import 'package:cloud_firestore/cloud_firestore.dart';

class EmploiGenerator {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Tranches horaires selon le modèle de planning
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
    final modulesSnap = await _db.collection('modules').get();
    final sallesSnap = await _db
        .collection('salles')
        .where('disponible', isEqualTo: true)
        .get();
    final classesSnap = await _db.collection('classes').get();

    final effectifsClasse = {
      for (final c in classesSnap.docs) c.id: (c.data()['effectif'] ?? 0) as int
    };
    final capacitesSalles = {
      for (final s in sallesSnap.docs) s.id: (s.data()['capacite'] ?? 0) as int
    };

    final Map<String, Set<String>> salleOccupation = {};
    final Map<String, Set<String>> profOccupation = {};

    // 🧹 Supprimer les anciens emplois
    final anciens = await _db.collection('emplois').get();
    for (final doc in anciens.docs) {
      await doc.reference.delete();
    }

    for (final module in modulesSnap.docs) {
      final data = module.data();
      final jour = data['jour'];
      final heure = data['heure'];
      final classeId = data['classe'];
      final profId = data['prof'];

      final key = '$jour-$heure';

      // Trouver une salle assez grande et libre
      String? salleChoisie;
      for (final salle in sallesSnap.docs) {
        final salleId = salle.id;
        final capacite = capacitesSalles[salleId] ?? 0;
        final effectif = effectifsClasse[classeId] ?? 0;
        salleOccupation.putIfAbsent(key, () => {});
        if (capacite >= effectif && !salleOccupation[key]!.contains(salleId)) {
          salleChoisie = salleId;
          salleOccupation[key]!.add(salleId);
          break;
        }
      }

      profOccupation.putIfAbsent(key, () => {});
      if (salleChoisie != null && !profOccupation[key]!.contains(profId)) {
        profOccupation[key]!.add(profId);
        await _db.collection('emplois').add({
          'classe': classeId,
          'jour': jour,
          'heure': heure,
          'salle': salleChoisie,
          'module': module.id,
          'prof': profId,
        });
      }
    }
  }

  /// 📊 Récupère l'emploi du temps lisible pour une classe
  Future<Map<String, Map<String, String>>> getEmploisParClasse(String classeId) async {
    final emploisSnap = await _db
        .collection('emplois')
        .where('classe', isEqualTo: classeId)
        .get();

    final modulesSnap = await _db.collection('modules').get();
    final profsSnap = await _db.collection('professeurs').get();
    final sallesSnap = await _db.collection('salles').get();

    final modulesMap = {
      for (var m in modulesSnap.docs)
        m.id: m.data()['nom'] ?? 'Module inconnu'
    };
    final profsMap = {
      for (var p in profsSnap.docs)
        p.id: p.data()['nom'] ?? 'Professeur inconnu'
    };
    final sallesMap = {
      for (var s in sallesSnap.docs)
        s.id: s.data()['nom'] ?? 'Salle inconnue'
    };

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

  /// 📥 Importe un emploi du temps depuis un fichier JSON structuré
  Future<void> importerDepuisJson(Map<String, dynamic> data) async {
    final emplois = data['emplois'] as List<dynamic>?;

    if (emplois == null) return;

    // Cartographies nom -> id pour chaque collection
    final classesSnap = await _db.collection('classes').get();
    final modulesSnap = await _db.collection('modules').get();
    final profsSnap = await _db.collection('professeurs').get();
    final sallesSnap = await _db.collection('salles').get();

    final classesMap = {
      for (var c in classesSnap.docs) c.data()['nom']: c.id,
    };
    final modulesMap = {
      for (var m in modulesSnap.docs) m.data()['nom']: m.id,
    };
    final profsMap = {
      for (var p in profsSnap.docs) p.data()['nom']: p.id,
    };
    final sallesMap = {
      for (var s in sallesSnap.docs) s.data()['nom']: s.id,
    };

    // 🧹 Effacer les anciens emplois
    final anciens = await _db.collection('emplois').get();
    for (final doc in anciens.docs) {
      await doc.reference.delete();
    }

    for (final e in emplois) {
      final classeId = classesMap[e['classe']];
      final moduleId = modulesMap[e['module']];
      final profId = profsMap[e['prof']];
      final salleId = sallesMap[e['salle']];
      final jour = e['jour'];
      final heure = e['heure'];

      if ([classeId, moduleId, profId, salleId, jour, heure].contains(null)) {
        // ignore les lignes incomplètes
        print('Entrée ignorée : $e');
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
