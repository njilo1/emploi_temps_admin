import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/confirmation_dialog.dart';

class AddProfesseurForm extends StatefulWidget {
  final VoidCallback? onProfesseurAdded;
  
  const AddProfesseurForm({Key? key, this.onProfesseurAdded}) : super(key: key);

  @override
  State<AddProfesseurForm> createState() => _AddProfesseurFormState();
}

class _AddProfesseurFormState extends State<AddProfesseurForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  bool _isLoading = false;

  void _resetForm() {
    _nomController.clear();
    _formKey.currentState!.reset();
  }

  void _navigateToList() {
    Navigator.pushNamed(context, '/liste_professeurs');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'nom': _nomController.text.trim(),
      };

      await ApiService.addProfesseur(data);

      if (mounted) {
        // Afficher le popup de confirmation
        await ConfirmationDialog.showSuccessDialog(
          context: context,
          title: '✅ Professeur enregistré avec succès',
          entityType: 'professeur',
          onViewList: _navigateToList,
          onAddNew: _resetForm,
        );

        // Notifier le parent pour rafraîchir la liste
        widget.onProfesseurAdded?.call();
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
                    "Ajouter un professeur",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: "Nom du professeur",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: "Ex: Dr. Jean Dupont",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Le nom du professeur est obligatoire";
                  }
                  if (value.trim().length < 2) {
                    return "Le nom doit contenir au moins 2 caractères";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Enregistrement...' : 'Ajouter'),
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
    super.dispose();
  }
}
