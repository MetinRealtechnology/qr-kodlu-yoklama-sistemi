import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CoursesAddScreen extends StatefulWidget {
  const CoursesAddScreen({super.key});

  @override
  State<CoursesAddScreen> createState() => _CoursesAddScreenState();
}

class _CoursesAddScreenState extends State<CoursesAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dersAdiController = TextEditingController();
  final _dersKoduController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  bool _isLoading = false;

  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    final dersKodu = _dersKoduController.text.trim();
    final dersAdi = _dersAdiController.text.trim();

    final dersRef = _database.child('dersler/$dersKodu');

    await dersRef.set({
      'dersAdi': dersAdi,
      'dersKodu': dersKodu,
      'akademisyenUid': currentUser.uid,
    });

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ders başarıyla eklendi.')),
    );

    Navigator.pop(context);
  }


  @override
  void dispose() {
    _dersAdiController.dispose();
    _dersKoduController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Ekle'),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _dersAdiController,
                  decoration: const InputDecoration(
                    labelText: 'Ders Adı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dersKoduController,
                  decoration: const InputDecoration(
                    labelText: 'Ders Kodu',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                  onPressed: _addCourse,
                  icon: const Icon(Icons.save),
                  label: const Text('Dersi Kaydet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade900,
                    minimumSize: const Size.fromHeight(50),
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
