import 'package:flutter/material.dart';


class SocialHistoryForm extends StatefulWidget {
  @override
  _SocialHistoryFormState createState() => _SocialHistoryFormState();
}

class _SocialHistoryFormState extends State<SocialHistoryForm> {
  bool _isSmoker = false;
  bool _isAlcoholic = false;
  final TextEditingController _workPlaceController = TextEditingController();
  final TextEditingController _sanitationStatusController =
      TextEditingController();
  final TextEditingController _ventilationStatusController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Social History:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _workPlaceController,
              decoration: InputDecoration(
                labelText: 'Workplace',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Meals per Day',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Smoker:'),
                Switch(
                  value: _isSmoker,
                  onChanged: (value) {
                    setState(() {
                      _isSmoker = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text('Alcoholic:'),
                Switch(
                  value: _isAlcoholic,
                  onChanged: (value) {
                    setState(() {
                      _isAlcoholic = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _sanitationStatusController,
              decoration: InputDecoration(
                labelText: 'Sanitation Status at Home',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _ventilationStatusController,
              decoration: InputDecoration(
                labelText: 'Ventilation Status at Home',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}