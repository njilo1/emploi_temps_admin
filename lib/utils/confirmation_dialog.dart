import 'package:flutter/material.dart';

class ConfirmationDialog {
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String entityType,
    required VoidCallback onViewList,
    required VoidCallback onAddNew,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Voulez-vous voir la liste ou ajouter un nouveau ?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onViewList();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.list, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text('Voir la liste'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAddNew();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 5),
                  Text('Ajouter un nouveau'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
} 