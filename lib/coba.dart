import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InputDataPage(),
    );
  }
}

class InputDataPage extends StatefulWidget {
  @override
  _InputDataPageState createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _umurController = TextEditingController();

  // GUNAKAN URL REGION YANG BENAR
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://hajjhealth-app.firebaseio.com',
  );

  void _simpanData() {
    String nama = _namaController.text;
    int umur = int.tryParse(_umurController.text) ?? 0;

    final ref = _database.ref('pengguna');
    String id = ref.push().key!;

    ref.child(id).set({
      'nama': nama,
      'umur': umur,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil disimpan')),
      );
      _namaController.clear();
      _umurController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Input Data ke Firebase')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: _umurController,
              decoration: InputDecoration(labelText: 'Umur'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _simpanData,
              child: Text('Simpan ke Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}