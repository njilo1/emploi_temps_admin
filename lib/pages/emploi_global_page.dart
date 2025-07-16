import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/emploi_table.dart';

class EmploiGlobalPage extends StatefulWidget {
  const EmploiGlobalPage({super.key});

  @override
  State<EmploiGlobalPage> createState() => _EmploiGlobalPageState();
}

class _EmploiGlobalPageState extends State<EmploiGlobalPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> _departements = [];
  final Set<int> _selection = {};
  Map<String, dynamic>? _resultat;
  bool _loading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _chargerDepartements();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _chargerDepartements() async {
    final data = await ApiService.fetchDepartements();
    setState(() => _departements = data);
  }

  Future<void> _generer() async {
    if (_selection.isEmpty) return;
    setState(() => _loading = true);
    _animationController.forward();
    try {
      final res = await ApiService.generateEmploisParDepartements(_selection.toList());
      setState(() => _resultat = res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Map<String, Map<String, String>> _convertToTypedMap(dynamic raw) {
    return Map<String, Map<String, String>>.from(
      (raw as Map).map(
            (k, v) => MapEntry(
          k as String,
          Map<String, String>.from(v),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Emploi du temps global'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header animé
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sélection des départements',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cochez un ou plusieurs départements, puis lancez la génération.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Liste des départements
              Expanded(
                flex: 2,
                child: _departements.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: theme.colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun département',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'Ajoutez-en via le menu.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: _departements.length,
                  itemBuilder: (context, index) {
                    final dep = _departements[index];
                    final id = dep['id'] as int;
                    final isSelected = _selection.contains(id);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Material(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              isSelected
                                  ? _selection.remove(id)
                                  : _selection.add(id);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    dep['nom'] ?? '',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Bouton animé
              Hero(
                tag: 'generateButton',
                child: ElevatedButton.icon(
                  onPressed: _loading || _selection.isEmpty ? null : _generer,
                  icon: _loading
                      ? Container(
                    width: 20,
                    height: 20,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.auto_awesome, size: 20),
                  label: Text(
                    _loading ? 'Génération...' : 'Générer l’emploi',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Affichage du résultat
              if (_loading)
                const Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      SizedBox(height: 12),
                      Text('Génération en cours...'),
                    ],
                  ),
                ),
              if (_resultat != null)
                Expanded(
                  flex: 3,
                  child: FadeTransition(
                    opacity: _animationController,
                    child: _buildResultats(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultats() {
    final deps = _resultat!['departements'] as List<dynamic>;
    if (deps.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'Aucun emploi à afficher',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: deps.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: deps.map((d) => Tab(text: d['nom'])).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: deps.map((d) {
                final classes = d['classes'] as List<dynamic>;
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: classes.length,
                  itemBuilder: (_, index) {
                    final c = classes[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.class_, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  c['nom'],
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            EmploiTable(
                              emploiData: _convertToTypedMap(c['emplois']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}