import 'package:flutter/material.dart';
import 'add_entity_page.dart';
import 'entity_list_page.dart';
import 'emploi_page.dart';
import 'planning_import_page.dart';
import 'emploi_global_page.dart';
import 'add_module_page.dart';
import 'module_list_page.dart';
import 'add_filiere_page.dart';
import 'add_departement_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Tableau de bord - Admin'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.schedule, size: 100, color: Colors.teal),
            const SizedBox(height: 20),
            const Text(
              "Bienvenue sur le système d'administration",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Utilise le menu pour naviguer", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EmploiPage()), // ✅ const supprimé ici
                );
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text("Générer Emploi du temps"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Widget drawerItem(
      BuildContext context,
      String title,
      IconData icon,
      Widget Function() pageBuilder,
      ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop(); // Ferme le menu
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => pageBuilder()));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 60),
                SizedBox(height: 10),
                Text("Admin Panel", style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
          drawerItem(context, "Ajouter Classe", Icons.class_,
                  () => const AddEntityPage(collectionName: 'classes')),
          drawerItem(context, "Voir Classes", Icons.list,
                  () => const EntityListPage(
                collectionName: 'classes',
                fieldsToShow: ['nom', 'filiere', 'effectif'],
              )),
          drawerItem(context, "Ajouter Professeur", Icons.person_add,
                  () => const AddEntityPage(collectionName: 'professeurs')),
          drawerItem(context, "Voir Professeurs", Icons.people,
                  () => const EntityListPage(collectionName: 'professeurs', fieldsToShow: ['nom'])),
          drawerItem(context, "Ajouter Salle", Icons.meeting_room,
                  () => const AddEntityPage(collectionName: 'salles')),
          drawerItem(context, "Voir Salles", Icons.domain,
                  () => const EntityListPage(
                collectionName: 'salles',
                fieldsToShow: ['nom', 'capacité', 'disponible'],
              )),
          drawerItem(context, "Ajouter Filière", Icons.school,
                  () => const AddFilierePage()),
          drawerItem(context, "Voir Filières", Icons.view_list,
                  () => const EntityListPage(
                collectionName: 'filieres',
                fieldsToShow: ['nom', 'departement'],
              )),
          drawerItem(context, "Ajouter Département", Icons.apartment,
                  () => const AddDepartementPage()),
          drawerItem(context, "Voir Départements", Icons.apartment,
                  () => const EntityListPage(
                collectionName: 'departements',
                fieldsToShow: ['nom', 'code'],
              )),
          drawerItem(context, "Ajouter Module", Icons.book,
                  () => const AddModulePage()),
          drawerItem(context, "Voir Modules", Icons.book_outlined,
                  () => const ModuleListPage()),

          // ✅ Lien vers l’emploi du temps
          drawerItem(context, "Générer Emploi du Temps", Icons.event_available,
                  () => EmploiPage()), // ✅ const supprimé ici aussi
          drawerItem(context, "Importer Planning", Icons.upload_file,
                  () => const PlanningImportPage()),
          drawerItem(context, "Emploi global", Icons.table_rows,
                  () => const EmploiGlobalPage()),
        ],
      ),
    );
  }
}
