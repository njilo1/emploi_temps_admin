import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/confirmation_dialog.dart';

/// Page d'ajout d'un département
class AddDepartementPage extends StatefulWidget {
  const AddDepartementPage({Key? key}) : super(key: key);

  @override
  State<AddDepartementPage> createState() => _AddDepartementPageState();
}

class _AddDepartementPageState extends State<AddDepartementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isLoading = false;

  void _resetForm() {
    _nomController.clear();
    _codeController.clear();
    _formKey.currentState!.reset();
  }

  void _navigateToList() {
    Navigator.pushNamed(context, '/liste_departements');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.addDepartement({
        'nom': _nomController.text.trim(),
        'chef': _codeController.text.trim(),
      });

      if (mounted) {
        // Afficher le popup de confirmation
        await ConfirmationDialog.showSuccessDialog(
          context: context,
          title: '✅ Département enregistré avec succès',
          entityType: 'département',
          onViewList: _navigateToList,
          onAddNew: _resetForm,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'ajout : $e'),
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
  void dispose() {
    _nomController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un département'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.add_circle, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Ajouter un département',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du département',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                          hintText: 'Ex: Informatique, Mathématiques...',
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Le nom est obligatoire' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Chef de département',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                          hintText: 'Ex: Dr. Jean Dupont',
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Le chef est obligatoire' : null,
                      ),
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _save,
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
}
