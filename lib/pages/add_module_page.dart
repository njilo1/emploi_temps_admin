import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Page permettant d'ajouter ou de modifier un module (cours)
class AddModulePage extends StatefulWidget {
  final String? moduleId;
  const AddModulePage({Key? key, this.moduleId}) : super(key: key);

  @override
  State<AddModulePage> createState() => _AddModulePageState();
}

class _AddModulePageState extends State<AddModulePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  String? _selectedTranche;
  String? _selectedJour;
  String? _selectedClasseId;
  String? _selectedSalleId;
  String? _selectedProfId;

  final _horaires = const [
    '07H30 - 10H15',
    '10H30 - 13H15',
    '13H15 - 14H00',
    '14H00 - 16H45',
    '17H00 - 19H45',
  ];

  final _jours = const [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.moduleId != null) {
      _loadModule();
    }
  }

  Future<void> _loadModule() async {
    final doc = await FirebaseFirestore.instance
        .collection('modules')
        .doc(widget.moduleId)
        .get();
    final data = doc.data();
    if (data != null) {
      _nomController.text = data['nom'] ?? '';
      _selectedTranche = data['heure'];
      _selectedJour = data['jour'];
      _selectedClasseId = data['classe'];
      _selectedSalleId = data['salle'];
      _selectedProfId = data['prof'];
      setState(() {});
    }
  }

  Future<void> _saveModule() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nom': _nomController.text.trim(),
        'heure': _selectedTranche,
        'jour': _selectedJour,
        'classe': _selectedClasseId,
        'salle': _selectedSalleId,
        'prof': _selectedProfId,
      };
      try {
        if (widget.moduleId == null) {
          await FirebaseFirestore.instance.collection('modules').add(data);
        } else {
          await FirebaseFirestore.instance
              .collection('modules')
              .doc(widget.moduleId)
              .update(data);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleId == null
            ? 'Ajouter un module'
            : 'Modifier le module'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom du module'),
                validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTranche,
                decoration: const InputDecoration(labelText: 'Tranche horaire'),
                items: _horaires
                    .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTranche = v),
                validator: (v) => v == null ? 'Choisir une tranche' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedJour,
                decoration: const InputDecoration(labelText: 'Jour'),
                items: _jours
                    .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedJour = v),
                validator: (v) => v == null ? 'Choisir un jour' : null,
              ),
              const SizedBox(height: 16),
              FutureBuilder<QuerySnapshot>(
                future:
                    FirebaseFirestore.instance.collection('classes').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final classes = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: _selectedClasseId,
                    decoration: const InputDecoration(labelText: 'Classe'),
                    items: classes
                        .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text((c.data() as Map<String, dynamic>)['nom'] ?? '')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedClasseId = v),
                    validator: (v) => v == null ? 'Choisir une classe' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<QuerySnapshot>(
                future:
                    FirebaseFirestore.instance.collection('salles').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final salles = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: _selectedSalleId,
                    decoration: const InputDecoration(labelText: 'Salle'),
                    items: salles
                        .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text((s.data() as Map<String, dynamic>)['nom'] ?? '')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSalleId = v),
                    validator: (v) => v == null ? 'Choisir une salle' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('professeurs')
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final profs = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: _selectedProfId,
                    decoration: const InputDecoration(labelText: 'Professeur'),
                    items: profs
                        .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text((p.data() as Map<String, dynamic>)['nom'] ?? ''),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedProfId = v),
                    validator: (v) => v == null ? 'Choisir un professeur' : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveModule,
                child: const Text('Enregistrer'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }
}
