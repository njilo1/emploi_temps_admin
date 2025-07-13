import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/confirmation_dialog.dart';

class AddFiliereForm extends StatefulWidget {
  final VoidCallback? onFiliereAdded;
  
  const AddFiliereForm({Key? key, this.onFiliereAdded}) : super(key: key);

  @override
  State<AddFiliereForm> createState() => _AddFiliereFormState();
}

class _AddFiliereFormState extends State<AddFiliereForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  bool _isLoading = false;

  void _resetForm() {
    _nomController.clear();
    _formKey.currentState!.reset();
  }

  void _navigateToList() {
    Navigator.pushNamed(context, '/liste_filieres');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        "nom": _nomController.text.trim(),
      };

      await ApiService.addFiliere(data);

      if (mounted) {
        // Afficher le popup de confirmation
        await ConfirmationDialog.showSuccessDialog(
          context: context,
          title: '✅ Filière enregistrée avec succès',
          entityType: 'filière',
          onViewList: _navigateToList,
          onAddNew: _resetForm,
        );

        // Notifier le parent pour rafraîchir la liste
        widget.onFiliereAdded?.call();
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
                    'Ajouter une filière',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la filière',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                  hintText: 'Ex: Informatique, Mathématiques...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom de la filière est obligatoire';
                  }
                  if (value.trim().length < 2) {
                    return 'Le nom doit contenir au moins 2 caractères';
                  }
                  return null;
                },
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
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }
}
