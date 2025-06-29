import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EntityListPage extends StatefulWidget {
  final String collectionName;
  final List<String> fieldsToShow;

  const EntityListPage({
    Key? key,
    required this.collectionName,
    required this.fieldsToShow,
  }) : super(key: key);

  @override
  State<EntityListPage> createState() => _EntityListPageState();
}

class _EntityListPageState extends State<EntityListPage> {

  /// Fonction de suppression d'un document
  Future<void> _deleteEntity(String docId) async {
    switch (widget.collectionName) {
      case 'classes':
        await ApiService.deleteClasse(docId);
        break;
      case 'filieres':
        await ApiService.deleteFiliere(docId);
        break;
      case 'professeurs':
        await ApiService.deleteProfesseur(docId);
        break;
      case 'salles':
        await ApiService.deleteSalle(docId);
        break;
      case 'modules':
        await ApiService.deleteModule(docId);
        break;
      default:
        break;
    }
    setState(() {});
  }

  Future<List<dynamic>> _fetchEntities() {
    switch (widget.collectionName) {
      case 'classes':
        return ApiService.fetchClasses();
      case 'filieres':
        return ApiService.fetchFilieres();
      case 'professeurs':
        return ApiService.fetchProfesseurs();
      case 'salles':
        return ApiService.fetchSalles();
      case 'modules':
        return ApiService.fetchModules();
      default:
        return Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste : ${widget.collectionName}'),
      ),
      body: FutureBuilder<List<dynamic>>( 
        future: _fetchEntities(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!;

          if (docs.isEmpty) {
            return const Center(child: Text("Aucun élément trouvé"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index] as Map<String, dynamic>;
              final docId = data['id']?.toString() ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    fieldsToShow.map((f) => data[f]?.toString() ?? '').join(' - '),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Confirmation"),
                          content: const Text("Supprimer cet élément ?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Annuler"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Supprimer"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _deleteEntity(docId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Élément supprimé')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
