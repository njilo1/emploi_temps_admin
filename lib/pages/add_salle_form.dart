import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/confirmation_dialog.dart';

class AddSalleForm extends StatefulWidget {
  final VoidCallback? onSalleAdded;
  
  const AddSalleForm({Key? key, this.onSalleAdded}) : super(key: key);

  @override
  State<AddSalleForm> createState() => _AddSalleFormState();
}

class _AddSalleFormState extends State<AddSalleForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _capaciteController = TextEditingController();
  bool _disponible = true;
  bool _isLoading = false;

  void _resetForm() {
    _nomController.clear();
    _capaciteController.clear();
    setState(() {
      _disponible = true;
    });
    _formKey.currentState!.reset();
  }

  void _navigateToList() {
    Navigator.pushNamed(context, '/liste_salles');
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
        'capacite': int.tryParse(_capaciteController.text.trim()) ?? 0,
        'disponible': _disponible,
      };

      await ApiService.addSalle(data);

      if (mounted) {
        // Afficher le popup de confirmation
        await ConfirmationDialog.showSuccessDialog(
          context: context,
          title: '✅ Salle enregistrée avec succès',
          entityType: 'salle',
          onViewList: _navigateToList,
          onAddNew: _resetForm,
        );

        // Notifier le parent pour rafraîchir la liste
        widget.onSalleAdded?.call();
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
                    "Ajouter une salle",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: "Nom de la salle",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.room),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Le nom de la salle est obligatoire";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _capaciteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Capacité",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La capacité est obligatoire";
                  }
                  final capacite = int.tryParse(value);
                  if (capacite == null || capacite <= 0) {
                    return "La capacité doit être un nombre positif";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              
              SwitchListTile(
                value: _disponible,
                title: const Text("Salle disponible"),
                subtitle: const Text("La salle peut être utilisée pour les cours"),
                onChanged: (value) => setState(() => _disponible = value),
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
    _capaciteController.dispose();
    super.dispose();
  }
}
