import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'entity_list_page.dart';

class AddClasseForm extends StatefulWidget {
  const AddClasseForm({Key? key}) : super(key: key);

  @override
  State<AddClasseForm> createState() => _AddClasseFormState();
}

class _AddClasseFormState extends State<AddClasseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _effectifController = TextEditingController();
  int? _selectedFiliereId;

  List<dynamic> _filieres = [];
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'nom': _nomController.text.trim(),
      'effectif': int.parse(_effectifController.text.trim()),
      'filiere': _selectedFiliereId,
    };

    setState(() => _isLoading = true);

    try {
      await ApiService.post('/classes/', data);

      if (!mounted) return;
      await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('✅ Élément enregistré avec succès'),
            content:
                const Text('Voulez-vous voir la liste ou ajouter un nouveau ?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EntityListPage(
                        endpoint: 'classes/',
                        fieldsToShow: ['nom', 'filiere', 'effectif'],
                      ),
                    ),
                  );
                },
                child: const Text('Voir la liste'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _formKey.currentState!.reset();
                  _nomController.clear();
                  _effectifController.clear();
                  setState(() => _selectedFiliereId = null);
                },
                child: const Text('Ajouter un nouvel élément'),
              ),
            ],
          ),
        );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFilieres();
  }

  Future<void> _loadFilieres() async {
    try {
      final filieres = await ApiService.fetchFilieres();
      setState(() {
        _filieres = filieres;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajouter une classe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Nom de la classe
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la classe',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 15),

              // Effectif
              TextFormField(
                controller: _effectifController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Effectif',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 15),

              // Liste des filières
              DropdownButtonFormField<int>(
                value: _selectedFiliereId,
                items: _filieres.map((filiere) {
                  return DropdownMenuItem<int>(
                    value: filiere['id'],
                    child: Text(filiere['nom']),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Filière',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedFiliereId = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Veuillez choisir une filière' : null,
              ),

              const SizedBox(height: 20),

              // Bouton Enregistrer
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _effectifController.dispose();
    super.dispose();
  }
}
