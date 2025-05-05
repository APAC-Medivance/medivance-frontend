
import 'package:flutter/material.dart';
import 'package:hajjhealth/view/Form/past_history.dart';
import 'package:hajjhealth/view/Form/family_history.dart';
import 'package:hajjhealth/view/Form/social_history.dart';  

class FormScreen extends StatefulWidget {
  final String formType;

  const FormScreen({Key? key, required this.formType}) : super(key: key);

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F9FF),
      appBar: AppBar(
        title: Text(widget.formType),
        backgroundColor: const Color(0xFFE8F9FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menampilkan form berdasarkan formType
                if (widget.formType == 'Past History') PastHistoryForm(),
                if (widget.formType == 'Family History') FamilyHistoryForm(),
                if (widget.formType == 'Social History') SocialHistoryForm(),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Proses data
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                        // Kembali setelah proses selesai
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.pop(context);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Submit', style: TextStyle(color: Colors.white,),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}