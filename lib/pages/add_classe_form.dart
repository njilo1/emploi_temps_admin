import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/confirmation_dialog.dart';

class AddClasseForm extends StatefulWidget {
  final VoidCallback? onClasseAdded;
  
  const AddClasseForm({Key? key, this.onClasseAdded}) : super(key: key);

  @override
  State<AddClasseForm> createState() => _AddClasseFormState();
}

class _AddClasseFormState extends State<AddClasseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _effectifController = TextEditingController();
  int? _selectedFiliereId;
  bool _isLoading = false;

  List<dynamic> _filieres = [];

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des filières: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _resetForm() {
    _nomController.clear();
    _effectifController.clear();
    setState(() {
      _selectedFiliereId = null;
    });
    _formKey.currentState!.reset();
  }

  void _navigateToList() {
    Navigator.pushNamed(context, '/liste_classes');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFiliereId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une filière'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'nom': _nomController.text.trim(),
        'effectif': int.parse(_effectifController.text.trim()),
        'filiere': _selectedFiliereId,
      };

      await ApiService.addClasse(data);

      if (mounted) {
        // Afficher le popup de confirmation
        await ConfirmationDialog.showSuccessDialog(
          context: context,
          title: '✅ Classe enregistrée avec succès',
          entityType: 'classe',
          onViewList: _navigateToList,
          onAddNew: _resetForm,
        );

        // Notifier le parent pour rafraîchir la liste
        widget.onClasseAdded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'ajout: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
              Row(
                children: [
                  const Icon(Icons.add_circle, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Ajouter une classe',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Nom de la classe
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la classe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom de la classe est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Effectif
              TextFormField(
                controller: _effectifController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Effectif',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'effectif est obligatoire';
                  }
                  final effectif = int.tryParse(value);
                  if (effectif == null || effectif <= 0) {
                    return 'L\'effectif doit être un nombre positif';
                  }
                  return null;
                },
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
                  prefixIcon: Icon(Icons.school),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitForm,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Enregistrement...' : 'Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
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
