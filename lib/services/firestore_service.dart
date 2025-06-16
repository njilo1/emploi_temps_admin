import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ajouter une entité (classe, filière, salle, prof)
  Future<void> addData(String collectionPath, Map<String, dynamic> data) async {
    await _db.collection(collectionPath).add(data);
  }

  // Mettre à jour une entité
  Future<void> updateData(String collectionPath, String docId, Map<String, dynamic> data) async {
    await _db.collection(collectionPath).doc(docId).update(data);
  }

  // Supprimer une entité
  Future<void> deleteData(String collectionPath, String docId) async {
    await _db.collection(collectionPath).doc(docId).delete();
  }

  // Lire les données en temps réel
  Stream<QuerySnapshot> getCollectionStream(String collectionPath) {
    return _db.collection(collectionPath).snapshots();
  }
}
