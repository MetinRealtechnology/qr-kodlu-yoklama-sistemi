import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController adSoyadController = TextEditingController();
  final TextEditingController okulNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController sifreController = TextEditingController();

  String userType = 'ogrenci';

  bool isLoading = false;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: sifreController.text.trim(),
      );

      final uid = userCredential.user!.uid;


      final Map<String, dynamic> userMap = {
        'adSoyad': adSoyadController.text.trim(),
        'email': emailController.text.trim(),
        'tip': userType,
      };

      if (userType == 'ogrenci') {
        userMap['okulNo'] = okulNoController.text.trim();
      }

      await _dbRef.child('kullanicilar/$uid').set(userMap);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Hata oluştu')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              _buildTextField(adSoyadController, 'Ad Soyad'),
              const SizedBox(height: 16),

              if (userType == 'ogrenci') ...[
                _buildTextField(okulNoController, 'Okul Numarası'),
                const SizedBox(height: 16),
              ],
              _buildTextField(emailController, 'E-Posta'),
              const SizedBox(height: 16),
              _buildTextField(sifreController, 'Şifre', isPassword: true),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: userType,
                onChanged: (value) {
                  setState(() {
                    userType = value!;

                    if (userType == 'akademisyen') {
                      okulNoController.clear();
                    }
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Tipi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'ogrenci', child: Text('Öğrenci')),
                  DropdownMenuItem(value: 'akademisyen', child: Text('Akademisyen')),
                ],
              ),
              const SizedBox(height: 32),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: registerUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  'Kayıt Ol',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {

          if (label == 'Okul Numarası' && userType == 'akademisyen') {
            return null;
          }
          return 'Lütfen $label girin';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
    );
  }
}
