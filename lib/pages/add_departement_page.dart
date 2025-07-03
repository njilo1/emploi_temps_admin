import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Département ajouté avec succès')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur lors de l\'ajout : $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'chef'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
