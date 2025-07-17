import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/emploi_table.dart';

class EmploiGlobalPage extends StatefulWidget {
  const EmploiGlobalPage({super.key});

  @override
  State<EmploiGlobalPage> createState() => _EmploiGlobalPageState();
}

class _EmploiGlobalPageState extends State<EmploiGlobalPage> {
  List<Map<String, dynamic>> _departements = [];
  Set<int> _departementsSelectionnes = {};
  Map<String, Map<String, Map<String, String>>> _emploiParClasse = {};
  bool _isLoading = false;
  String? _message;
  Map<String, dynamic>? _resultatGlobal;

  @override
  void initState() {
    super.initState();
    _chargerDepartements();
  }

  Future<void> _chargerDepartements() async {
    try {
      final departements = await ApiService.fetchDepartements();
      setState(() {
        _departements = departements.map((d) => {
          'id': d['id'],
          'nom': d['nom'],
          'code': d['code'],
        }).toList();
      });
      print('🏢 Départements chargés: ${_departements.length} départements trouvés');
    } catch (e) {
      print('❌ Erreur lors du chargement des départements: $e');
      setState(() {
        _departements = [];
      });
    }
  }

  Future<void> _genererEmploiGlobal() async {
    if (_departementsSelectionnes.isEmpty) {
      setState(() {
        _message = "❌ Veuillez sélectionner au moins un département";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
      _emploiParClasse = {};
      _resultatGlobal = null;
    });

    try {
      print('🔄 Génération d\'emploi pour les départements: $_departementsSelectionnes');
      
      final resultat = await ApiService.generateEmploisParDepartements(_departementsSelectionnes.toList());
      
      setState(() {
        _resultatGlobal = resultat;
        _message = "✅ Emploi global généré avec succès !";
      });
      
      print('📅 Emploi global généré: ${resultat['departements']?.length ?? 0} départements');
    } catch (e) {
      print('❌ Erreur lors de la génération: $e');
      setState(() {
        _message = "❌ Erreur : $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleDepartement(int departementId) {
    setState(() {
      if (_departementsSelectionnes.contains(departementId)) {
        _departementsSelectionnes.remove(departementId);
      } else {
        _departementsSelectionnes.add(departementId);
      }
    });
  }

  Map<String, Map<String, String>> _convertEmploiData(dynamic emploiData) {
    if (emploiData is Map) {
      Map<String, Map<String, String>> result = {};
      emploiData.forEach((key, value) {
        if (key is String && value is Map) {
          Map<String, String> innerMap = {};
          value.forEach((innerKey, innerValue) {
            if (innerKey is String) {
              innerMap[innerKey] = innerValue?.toString() ?? '';
            }
          });
          result[key] = innerMap;
        }
      });
      return result;
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emploi Global par Départements'),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header avec icône
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                        Icons.business,
                        size: 40,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Génération d'emploi global",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sélectionnez les départements et générez l'emploi du temps global",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sélection des départements
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.checklist, color: Colors.teal.shade700),
                        const SizedBox(width: 8),
                        Text(
                          "Sélection des départements",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (_departements.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _departements.map((departement) {
                          final isSelected = _departementsSelectionnes.contains(departement['id']);
                          return GestureDetector(
                            onTap: () => _toggleDepartement(departement['id']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.teal.shade100 : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.teal.shade300 : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isSelected ? Colors.teal.shade700 : Colors.grey.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    departement['nom'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.teal.shade700 : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bouton de génération
              if (!_isLoading)
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
                      Text(
                        "Actions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Bouton Générer automatiquement
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(colors: [Colors.teal.shade500, Colors.teal.shade600]),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.shade400,
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _genererEmploiGlobal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Générer emploi global",
                                style: const TextStyle(
                                  fontSize: 13,
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

              const SizedBox(height: 20),

              // Message de statut
              if (_message != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _message!.startsWith("✅") ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _message!.startsWith("✅") ? Colors.green.shade200 : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _message!.startsWith("✅") ? Icons.check_circle : Icons.error,
                        color: _message!.startsWith("✅") ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _message!,
                          style: TextStyle(
                            color: _message!.startsWith("✅") ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Affichage des résultats
              if (_resultatGlobal != null && _resultatGlobal!['departements'] != null)
                ...(_resultatGlobal!['departements'] as List).map((departement) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 2,
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête du département avec design amélioré
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.teal.shade100, Colors.teal.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            border: Border(
                              bottom: BorderSide(color: Colors.teal.shade200, width: 2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade600,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.business,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Département ${departement['nom']}",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${(departement['classes'] as List).length} classe(s)",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.teal.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Classes du département avec séparation claire
                        ...(departement['classes'] as List).asMap().entries.map((entry) {
                          final index = entry.key;
                          final classe = entry.value;
                          final isLast = index == (departement['classes'] as List).length - 1;
                          
                          return Container(
                            margin: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 20,
                              bottom: isLast ? 20 : 0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // En-tête de la classe
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.shade200, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade600,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.school,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Classe ${classe['nom']}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Emploi du temps avec design amélioré
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200, width: 1),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: EmploiTable(emploiData: _convertEmploiData(classe['emplois'])),
                                  ),
                                ),
                                
                                // Séparateur entre les classes (sauf pour la dernière)
                                if (!isLast)
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.grey.shade300,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
