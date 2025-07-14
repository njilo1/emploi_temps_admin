import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'module_list_page.dart';
import '../widgets/confirmation_dialog.dart';

class AddModulePage extends StatefulWidget {
  final int? moduleId;
  const AddModulePage({Key? key, this.moduleId}) : super(key: key);

  @override
  State<AddModulePage> createState() => _AddModulePageState();
}

class _AddModulePageState extends State<AddModulePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();

  String? _selectedJour, _selectedHeure, _selectedClasse, _selectedSalle, _selectedProf;

  final _jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
  
  final _horaires = [
    '07H30 - 10H00',
    '10H15 - 12H45',
    '13H00 - 15H30',
    '15H45 - 18H15',
  ];

  List<dynamic> classes = [], salles = [], profs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData().then((_) => loadExistingData());
  }

  Future<void> loadData() async {
    try {
      final results = await Future.wait([
        ApiService.fetchClasses(),
        ApiService.fetchSalles(),
        ApiService.fetchProfesseurs(),
      ]);
      setState(() {
        classes = results[0];
        salles = results[1];
        profs = results[2];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de chargement: $e')));
    }
  }

  Future<void> loadExistingData() async {
    if (widget.moduleId != null) {
      final modules = await ApiService.fetchModules();
      final module = modules.firstWhere((m) => m['id'] == widget.moduleId, orElse: () => null);
      if (module != null) {
        _nomController.text = module['nom'] ?? '';
        _selectedJour = module['jour'] ?? module['jours']?.split(',').first;
        _selectedHeure = module['heure'];
        _selectedClasse = module['classe'].toString();
        _selectedSalle = module['salle'].toString();
        _selectedProf = module['prof'].toString();
      }
    }
  }

  Future<void> saveModule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'nom': _nomController.text.trim(),
      'jour': _selectedJour, // Jour spécifique du cours
      'heure': _selectedHeure, // Heure spécifique du cours
      'jours': _selectedJour, // Jours autorisés (un seul jour)
      'classe': int.parse(_selectedClasse!),
      'salle': int.parse(_selectedSalle!),
      'prof': int.parse(_selectedProf!),
    };

    try {
      if (widget.moduleId == null) {
        await ApiService.addModule(data);
      } else {
        await ApiService.updateModule(widget.moduleId!.toString(), data);
      }

      if (!mounted) return;
      await ConfirmationDialog.showSuccessDialog(
        context: context,
        viewButtonText: 'Voir la liste des modules',
        addButtonText: 'Ajouter un nouveau module',
        onViewList: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ModuleListPage()),
          );
        },
        onAddNew: () {
          _formKey.currentState!.reset();
          _nomController.clear();
          setState(() {
            _selectedJour = null;
            _selectedHeure = null;
            _selectedClasse = null;
            _selectedSalle = null;
            _selectedProf = null;
          });
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Erreur: $e")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget buildDropdown(List<dynamic> items, String? selected, String label, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selected,
      items: items.map((item) {
        final nom = item['nom'] ?? item['code'] ?? 'Inconnu';
        return DropdownMenuItem(value: item['id'].toString(), child: Text(nom));
      }).toList(),
      decoration: InputDecoration(labelText: label.capitalize()),
      onChanged: onChanged,
      validator: (v) => v == null ? "Champ requis" : null,
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleId == null ? "Ajouter un module" : "Modifier le module"),
        leading: const BackButton(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(labelText: "Nom du module"),
                      validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedJour,
                      items: _jours.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      decoration: const InputDecoration(labelText: "Jour du cours"),
                      onChanged: (v) => setState(() => _selectedJour = v),
                      validator: (v) => v == null ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedHeure,
                      items: _horaires.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      decoration: const InputDecoration(labelText: "Heure du cours"),
                      onChanged: (v) => setState(() => _selectedHeure = v),
                      validator: (v) => v == null ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 16),
                    buildDropdown(classes, _selectedClasse, "Classe", (v) => setState(() => _selectedClasse = v)),
                    buildDropdown(salles, _selectedSalle, "Salle", (v) => setState(() => _selectedSalle = v)),
                    buildDropdown(profs, _selectedProf, "Professeur", (v) => setState(() => _selectedProf = v)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: saveModule,
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

extension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
