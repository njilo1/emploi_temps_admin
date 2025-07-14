import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddEntityPage extends StatefulWidget {
  final String collectionName;

  const AddEntityPage({super.key, required this.collectionName});

  @override
  State<AddEntityPage> createState() => _AddEntityPageState();
}

class _AddEntityPageState extends State<AddEntityPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  List<dynamic> _filieres = [];
  List<dynamic> _classes = [];
  List<dynamic> _professeurs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRelatedData();
  }

  Future<void> _loadRelatedData() async {
    try {
      if (widget.collectionName == 'classes') {
        final filieres = await ApiService.fetchFilieres();
        setState(() {
          _filieres = filieres;
        });
      } else if (widget.collectionName == 'modules') {
        final results = await Future.wait([
          ApiService.fetchClasses(),
          ApiService.fetchProfesseurs(),
        ]);
        setState(() {
          _classes = results[0];
          _professeurs = results[1];
        });
      }
    } catch (e) {
      print('Erreur chargement données: $e');
    }
  }

  String _getTitle() {
    switch (widget.collectionName) {
      case 'classes': return 'Nouvelle Classe';
      case 'filieres': return 'Nouvelle Filière';
      case 'professeurs': return 'Nouveau Professeur';
      case 'salles': return 'Nouvelle Salle';
      case 'modules': return 'Nouveau Module';
      case 'departements': return 'Nouveau Département';
      default: return 'Nouvel Élément';
    }
  }

  IconData _getIcon() {
    switch (widget.collectionName) {
      case 'classes': return Icons.class_;
      case 'filieres': return Icons.school;
      case 'professeurs': return Icons.person;
      case 'salles': return Icons.meeting_room;
      case 'modules': return Icons.book;
      case 'departements': return Icons.apartment;
      default: return Icons.add;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header avec icône
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIcon(),
                          size: 32,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getTitle(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Remplissez les informations ci-dessous',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // Formulaire
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Champ nom (toujours présent)
                      _buildTextField(
                        label: "Nom",
                        icon: Icons.edit,
                        onSaved: (value) => _formData['nom'] = value,
                        validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 20),

                      // Champs spécifiques selon le type d'entité
                      if (widget.collectionName == 'classes') ...[
                        _buildDropdownField(
                          label: "Filière",
                          icon: Icons.school,
                          value: _formData['filiere'],
                          items: _filieres.map((filiere) {
                            return DropdownMenuItem<String>(
                              value: filiere['id'].toString(),
                              child: Text(filiere['nom']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _formData['filiere'] = value;
                            });
                          },
                          validator: (value) => value == null ? "Sélectionnez une filière" : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: "Effectif",
                          icon: Icons.people,
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _formData['effectif'] = int.tryParse(value ?? '30'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Champ requis";
                            if (int.tryParse(value) == null) return "Nombre invalide";
                            return null;
                          },
                        ),
                      ],

                      if (widget.collectionName == 'salles') ...[
                        _buildTextField(
                          label: "Capacité",
                          icon: Icons.event_seat,
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _formData['capacite'] = int.tryParse(value ?? '30'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Champ requis";
                            if (int.tryParse(value) == null) return "Nombre invalide";
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildSwitchTile(
                          title: "Disponible",
                          subtitle: "La salle est-elle disponible pour les cours ?",
                          value: _formData['disponible'] ?? true,
                          onChanged: (val) {
                            setState(() => _formData['disponible'] = val);
                          },
                        ),
                      ],

                      if (widget.collectionName == 'modules') ...[
                        _buildDropdownField(
                          label: "Classe",
                          icon: Icons.class_,
                          value: _formData['classe'],
                          items: _classes.map((classe) {
                            return DropdownMenuItem<String>(
                              value: classe['id'].toString(),
                              child: Text(classe['nom']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _formData['classe'] = value;
                            });
                          },
                          validator: (value) => value == null ? "Sélectionnez une classe" : null,
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownField(
                          label: "Professeur",
                          icon: Icons.person,
                          value: _formData['prof'],
                          items: _professeurs.map((prof) {
                            return DropdownMenuItem<String>(
                              value: prof['id'].toString(),
                              child: Text(prof['nom']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _formData['prof'] = value;
                            });
                          },
                          validator: (value) => value == null ? "Sélectionnez un professeur" : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: "Volume horaire (heures)",
                          icon: Icons.schedule,
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _formData['volume_horaire'] = int.tryParse(value ?? '3'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Champ requis";
                            if (int.tryParse(value) == null) return "Nombre invalide";
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: "Jours autorisés (séparés par des virgules)",
                          icon: Icons.calendar_today,
                          onSaved: (value) => _formData['jours'] = value ?? 'Lundi,Mardi,Mercredi,Jeudi,Vendredi,Samedi',
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Champ requis";
                            // Vérifier que les jours sont valides
                            final jours = value!.split(',').map((j) => j.trim()).toList();
                            final joursValides = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
                            for (final jour in jours) {
                              if (!joursValides.contains(jour)) {
                                return "Jour invalide: $jour. Jours valides: ${joursValides.join(', ')}";
                              }
                            }
                            return null;
                          },
                          hintText: "Ex: Lundi,Mardi,Jeudi",
                        ),
                      ],

                      if (widget.collectionName == 'departements') ...[
                        _buildTextField(
                          label: "Chef de département",
                          icon: Icons.person_outline,
                          onSaved: (value) => _formData['chef'] = value,
                          validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Bouton d'ajout
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal.shade600,
                        Colors.teal.shade700,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveEntity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading 
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Ajout en cours...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Ajouter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? hintText,
  }) {
          return TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.teal.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        keyboardType: keyboardType,
        onSaved: onSaved,
        validator: validator,
      );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      dropdownColor: Colors.white,
      icon: Icon(Icons.arrow_drop_down, color: Colors.teal.shade600),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.teal.shade600),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.teal.shade600,
          ),
        ],
      ),
    );
  }

  Future<void> _saveEntity() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
      });

      try {
        switch (widget.collectionName) {
          case 'classes':
            await ApiService.addClasse(_formData);
            break;
          case 'filieres':
            await ApiService.addFiliere(_formData);
            break;
          case 'professeurs':
            await ApiService.addProfesseur(_formData);
            break;
          case 'salles':
            await ApiService.addSalle(_formData);
            break;
          case 'modules':
            await ApiService.addModule(_formData);
            break;
          case 'departements':
            await ApiService.addDepartement(_formData);
            break;
          default:
            break;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text("✅ Ajout réussi !"),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text("❌ Erreur : $e")),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
  }
}
