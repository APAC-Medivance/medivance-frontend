import 'package:flutter/material.dart';

class PastHistoryForm extends StatefulWidget {
  @override
  _PastHistoryFormState createState() => _PastHistoryFormState();
}

class _PastHistoryFormState extends State<PastHistoryForm> {
  final Map<String, List<String>> pastHistory = {
    'Previous Illness': [],
    'Traumatic Disease': [],
    'Vaccine': [],
    'Inherited Disease': [],
  };

  void _showEditDialog(String title) {
    List<TextEditingController> controllers = pastHistory[title]!
        .map((item) => TextEditingController(text: item))
        .toList();

    if (controllers.isEmpty) {
      controllers.add(TextEditingController());
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,  // Atur lebar maksimum
                  minHeight: 200, // Optional
                  maxHeight: 500, // Optional, supaya tidak terlalu tinggi
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (int i = 0; i < controllers.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controllers[i],
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 4),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline,
                                    color: Colors.blue),
                                onPressed: () {
                                  setStateDialog(() {
                                    controllers.add(TextEditingController());
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              pastHistory[title] = controllers
                                  .where((c) => c.text.trim().isNotEmpty)
                                  .map((c) => c.text.trim())
                                  .toList();
                            });
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getSummary(List<String> values) {
    if (values.isEmpty) return 'Tap to add details';
    return values.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Past History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...pastHistory.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(entry.key),
              subtitle: Text(
                _getSummary(entry.value),
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditDialog(entry.key),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
