import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/confirmation_dialog.dart';

class AddModulePage extends StatefulWidget {
  final int? moduleId;
  final VoidCallback? onModuleAdded;
  
  const AddModulePage({Key? key, this.moduleId, this.onModuleAdded}) : super(key: key);

  @override
  State<AddModulePage> createState() => _AddModulePageState();
}

class _AddModulePageState extends State<AddModulePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _volumeHoraireController = TextEditingController();

  int? _selectedClasseId, _selectedProfId;
  List<dynamic> classes = [], profs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.fetchClasses(),
        ApiService.fetchProfesseurs(),
      ]);
      setState(() {
        classes = results[0];
        profs = results[1];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _resetForm() {
    _nomController.clear();
    _volumeHoraireController.clear();
    setState(() {
      _selectedClasseId = null;
      _selectedProfId = null;
    });
    _formKey.currentState!.reset();
  }

  void _navigateToList() {
    Navigator.pushNamed(context, '/liste_modules');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClasseId == null || _selectedProfId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une classe et un professeur'),
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
        'volume_horaire': int.tryParse(_volumeHoraireController.text.trim()) ?? 3,
        'classe': _selectedClasseId,
        'prof': _selectedProfId,
      };

      if (widget.moduleId == null) {
        await ApiService.addModule(data);
      } else {
        await ApiService.updateModule(widget.moduleId!.toString(), data);
      }

      if (mounted) {
        // Afficher le popup de confirmation
        await ConfirmationDialog.showSuccessDialog(
          context: context,
          title: '✅ Module enregistré avec succès',
          entityType: 'module',
          onViewList: _navigateToList,
          onAddNew: _resetForm,
        );

        // Notifier le parent pour rafraîchir la liste
        widget.onModuleAdded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Erreur: $e"),
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
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.add_circle, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  widget.moduleId == null ? "Ajouter un module" : "Modifier le module",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            TextFormField(
                              controller: _nomController,
                              decoration: const InputDecoration(
                                labelText: "Nom du module",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.book),
                                hintText: "Ex: Mathématiques, Informatique...",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Le nom du module est obligatoire";
                                }
                                if (value.trim().length < 2) {
                                  return "Le nom doit contenir au moins 2 caractères";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            
                            TextFormField(
                              controller: _volumeHoraireController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Volume horaire (heures)",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.schedule),
                                hintText: "Ex: 3",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Le volume horaire est obligatoire";
                                }
                                final volume = int.tryParse(value);
                                if (volume == null || volume <= 0) {
                                  return "Le volume horaire doit être un nombre positif";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            
                            DropdownButtonFormField<int>(
                              value: _selectedClasseId,
                              items: classes.map((classe) {
                                return DropdownMenuItem<int>(
                                  value: classe['id'],
                                  child: Text(classe['nom']),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                labelText: "Classe",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.class_),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedClasseId = value;
                                });
                              },
                              validator: (value) =>
                                  value == null ? "Veuillez choisir une classe" : null,
                            ),
                            const SizedBox(height: 15),
                            
                            DropdownButtonFormField<int>(
                              value: _selectedProfId,
                              items: profs.map((prof) {
                                return DropdownMenuItem<int>(
                                  value: prof['id'],
                                  child: Text(prof['nom']),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                labelText: "Professeur",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedProfId = value;
                                });
                              },
                              validator: (value) =>
                                  value == null ? "Veuillez choisir un professeur" : null,
                            ),
                            const SizedBox(height: 20),
                            
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
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _volumeHoraireController.dispose();
    super.dispose();
  }
}
