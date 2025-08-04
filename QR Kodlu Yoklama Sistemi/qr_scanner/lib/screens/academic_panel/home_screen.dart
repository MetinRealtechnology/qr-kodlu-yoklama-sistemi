import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../../screens/login_screen.dart';
import '../../screens/academic_panel/courses_screen.dart';
import '../../screens/academic_panel/session_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _sonOturum;
  String adSoyad = '';
  int dersSayisi = 0;

  @override
  void initState() {
    super.initState();
    _fetchAkademisyenVerileri();
  }

  Future<void> _fetchAkademisyenVerileri() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dbRef = FirebaseDatabase.instance.ref();

    // Akademisyenin adSoyad bilgisi
    final userSnapshot = await dbRef.child('kullanicilar/${user.uid}').get();
    if (userSnapshot.exists) {
      final userData = userSnapshot.value as Map;
      adSoyad = userData['adSoyad'] ?? '';
    }

    // Akademisyene ait ders sayısı
    final dersSnapshot = await dbRef.child('dersler').get();
    int sayac = 0;
    if (dersSnapshot.exists) {
      final dersler = dersSnapshot.value as Map;
      dersler.forEach((key, value) {
        if ((value as Map)['akademisyenUid'] == user.uid) {
          sayac++;
        }
      });
    }
    dersSayisi = sayac;

    final oturumSnapshot = await dbRef.child('oturumlar').get();
    List<Map<String, dynamic>> oturumlar = [];

    if (oturumSnapshot.exists) {
      for (final child in oturumSnapshot.children) {
        final data = Map<String, dynamic>.from(child.value as Map);
        if (data['akademisyenUid'] == user.uid) {
          final tarihStr = data['tarih'] ?? '';
          final saatStr = data['saat'] ?? '';
          try {
            final dateTime = DateFormat('yyyy-MM-dd HH:mm').parse('$tarihStr $saatStr');
            data['datetime'] = dateTime;
            oturumlar.add(data);
          } catch (_) {
            continue;
          }
        }
      }

      if (oturumlar.isNotEmpty) {
        oturumlar.sort((a, b) => b['datetime'].compareTo(a['datetime']));
        _sonOturum = oturumlar.first;
      }
    }

    setState(() {});
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CoursesScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SessionListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.blueGrey.shade900,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Akademisyen Paneli',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: _signOut,
                    child: const Text(
                      'Çıkış',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş Geldiniz, $adSoyad',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistemde kayıtlı $dersSayisi dersiniz bulunuyor.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Oluşturulan Son Oturum',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _sonOturum == null
                      ? const Text("Henüz oturum oluşturmadınız.")
                      : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ders Kodu: ${_sonOturum!['dersKodu'] ?? '-'}"),
                        Text("Oturum ID: ${_sonOturum!['oturumID'] ?? '-'}"),
                        Text("Tarih: ${_sonOturum!['tarih'] ?? '-'}"),
                        Text("Saat: ${_sonOturum!['saat'] ?? '-'}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home, index: 0, label: 'Ana Sayfa'),
            _buildNavItem(icon: Icons.menu_book, index: 1, label: 'Dersler'),
            _buildNavItem(icon: Icons.add, index: 2, label: 'Oturumlar'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.amber : Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.amber : Colors.white70,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
