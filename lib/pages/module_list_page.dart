import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_module_page.dart';

class ModuleListPage extends StatefulWidget {
  const ModuleListPage({Key? key}) : super(key: key);

  @override
  State<ModuleListPage> createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> {
  // 🔁 Recharge automatique après ajout/modif
  Future<void> _refresh() async => setState(() {});

  // 🔁 Obtenir le nom d'un élément depuis son ID
  Future<String> _getDocName(String collection, String id) async {
    if (id.isEmpty) return '';
    switch (collection) {
      case 'classes':
        final classes = await ApiService.fetchClasses();
        return classes.firstWhere((c) => c['id'].toString() == id, orElse: () => {})['nom'] ?? '';
      case 'salles':
        final salles = await ApiService.fetchSalles();
        return salles.firstWhere((s) => s['id'].toString() == id, orElse: () => {})['nom'] ?? '';
      case 'professeurs':
        final profs = await ApiService.fetchProfesseurs();
        return profs.firstWhere((p) => p['id'].toString() == id, orElse: () => {})['nom'] ?? '';
      default:
        return '';
    }
  }

  Future<void> _delete(String id) async {
    await ApiService.deleteModule(id);
    await _refresh();
  }

  Future<void> _editJours(String id, String nom, String joursActuels) async {
    final TextEditingController controller = TextEditingController(text: joursActuels);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier les jours pour $nom'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez les jours autorisés séparés par des virgules:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Ex: Lundi,Mardi,Jeudi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jours valides: Lundi, Mardi, Mercredi, Jeudi, Vendredi, Samedi',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await ApiService.updateModule(id, {'jours': result});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Jours mis à jour avec succès !')),
          );
        }
        await _refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Modules'),
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.fetchModules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                ],
              ),
            );
          }

          final modules = snapshot.data ?? [];
          
          if (modules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun module trouvé',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez votre premier module',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Icon(Icons.book, color: Colors.teal.shade700),
                  ),
                  title: Text(
                    module['nom'] ?? 'Sans nom',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: _getDocName('classes', module['classe']?.toString() ?? ''),
                        builder: (context, snapshot) {
                          return Text('Classe: ${snapshot.data ?? 'Inconnue'}');
                        },
                      ),
                      FutureBuilder<String>(
                        future: _getDocName('professeurs', module['prof']?.toString() ?? ''),
                        builder: (context, snapshot) {
                          return Text('Professeur: ${snapshot.data ?? 'Aucun'}');
                        },
                      ),
                      // Afficher le jour spécifique si disponible
                      if (module['jour'] != null && module['jour'].toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            'Jour: ${module['jour']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      // Afficher l'heure spécifique si disponible
                      if (module['heure'] != null && module['heure'].toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            'Heure: ${module['heure']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      // Afficher la salle spécifique si disponible
                      if (module['salle'] != null && module['salle'].toString().isNotEmpty)
                        FutureBuilder<String>(
                          future: _getDocName('salles', module['salle'].toString()),
                          builder: (context, snapshot) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.purple.shade200),
                              ),
                              child: Text(
                                'Salle: ${snapshot.data ?? 'Inconnue'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      Text('Volume horaire: ${module['volume_horaire'] ?? 3}h'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          'Jours autorisés: ${module['jours'] ?? 'Tous les jours'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddModulePage(moduleId: module['id']),
                            ),
                          ).then((_) => _refresh());
                          break;
                        case 'edit_jours':
                          await _editJours(
                            module['id'].toString(),
                            module['nom'] ?? 'Module',
                            module['jours'] ?? 'Lundi,Mardi,Mercredi,Jeudi,Vendredi,Samedi',
                          );
                          break;
                        case 'delete':
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmer la suppression'),
                              content: Text('Voulez-vous vraiment supprimer le module "${module['nom']}" ?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Annuler'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Supprimer'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _delete(module['id'].toString());
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit_jours',
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 20),
                            SizedBox(width: 8),
                            Text('Modifier les jours'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddModulePage()),
          ).then((_) => _refresh());
        },
        backgroundColor: Colors.teal.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
