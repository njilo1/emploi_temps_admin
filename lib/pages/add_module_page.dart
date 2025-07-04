import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddModulePage extends StatefulWidget {
  final int? moduleId;
  const AddModulePage({Key? key, this.moduleId}) : super(key: key);

  @override
  State<AddModulePage> createState() => _AddModulePageState();
}

class _AddModulePageState extends State<AddModulePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();

  String? _selectedTranche, _selectedJour, _selectedClasse, _selectedSalle, _selectedProf;

  final _horaires = [
    '07H30 - 10H10',
    '10H15 - 12H45',
    '13H00 - 15H30',
    '15H45 - 18H15',
  ];

  final _jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];

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
        _selectedTranche = module['heure'];
        _selectedJour = module['jour'];
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
      'heure': _selectedTranche,
      'jour': _selectedJour,
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Module enregistré avec succès")),
        );
        Navigator.pop(context);
      }
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
        padding: const EdgeInsets.all(16),
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
                value: _selectedTranche,
                items: _horaires.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                decoration: const InputDecoration(labelText: "Tranche horaire"),
                onChanged: (v) => setState(() => _selectedTranche = v),
                validator: (v) => v == null ? "Champ requis" : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedJour,
                items: _jours.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                decoration: const InputDecoration(labelText: "Jour"),
                onChanged: (v) => setState(() => _selectedJour = v),
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
