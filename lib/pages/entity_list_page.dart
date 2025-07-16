import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EntityListPage extends StatefulWidget {
  final String endpoint;
  final List<String> fieldsToShow;

  const EntityListPage({
    Key? key,
    required this.endpoint,
    required this.fieldsToShow,
  }) : super(key: key);

  @override
  State<EntityListPage> createState() => _EntityListPageState();
}

class _EntityListPageState extends State<EntityListPage> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService.getData(widget.endpoint);
      setState(() {
        _items = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _items = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEntity(dynamic id) async {
    try {
      await ApiService.deleteData('${widget.endpoint}$id/');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Élément supprimé')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste : ${widget.endpoint}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('Aucun élément trouvé'))
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final title = widget.fieldsToShow
              .map((field) => item[field]?.toString() ?? '')
              .join(' - ');

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(title),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Confirmation'),
                      content: const Text('Supprimer cet élément ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await _deleteEntity(item['id']);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
