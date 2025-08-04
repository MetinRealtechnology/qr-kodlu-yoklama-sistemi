import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/academic_panel/session_add_screen.dart';
import '../../screens/academic_panel/session_update_screen.dart';
import '../../screens/academic_panel/session_detail_screen.dart';
import '../../screens/login_screen.dart';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  final dbRef = FirebaseDatabase.instance.ref();
  final String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  late DatabaseReference sessionsRef;
  late DatabaseReference coursesRef;

  int _selectedIndex = 2;


  Map<String, String> dersKoduToDersAdi = {};

  @override
  void initState() {
    super.initState();
    sessionsRef = dbRef.child('oturumlar');
    coursesRef = dbRef.child('dersler');
    _loadCourses();
  }


  Future<void> _loadCourses() async {
    final snapshot = await coursesRef.get();
    if (snapshot.exists) {
      final dataMap = snapshot.value as Map<dynamic, dynamic>;
      final Map<String, String> tempMap = {};
      dataMap.forEach((key, value) {
        if (value != null &&
            value['dersKodu'] != null &&
            value['dersAdi'] != null) {
          tempMap[value['dersKodu']] = value['dersAdi'];
        }
      });

      setState(() {
        dersKoduToDersAdi = tempMap;
      });
    }
  }

  Future<void> _deleteSession(String oturumID) async {
    try {
      await sessionsRef.child(oturumID).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oturum başarıyla silindi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silme işlemi başarısız: $e')),
      );
    }
  }

  void _navigateToUpdateScreen(Map<String, dynamic> oturum) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionUpdateScreen(oturum: oturum),
      ),
    );
  }

  void _navigateToDetailScreen(Map<String, dynamic> oturum) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionDetailScreen(oturum: oturum),
      ),
    );
  }

  void _navigateToAddScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SessionAddScreen()),
    );
  }

  void _onItemTapped(int index) async {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      final userSnapshot = await FirebaseDatabase.instance
          .ref('kullanicilar')
          .child(currentUserUid)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        final userType = userData['tip'] ?? 'ogrenci';

        if (userType == 'akademisyen') {
          Navigator.pushReplacementNamed(context, '/academic_home');
        } else {
          Navigator.pushReplacementNamed(context, '/student_home');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/student_home');
      }
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/courses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Oturum Listesi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Çıkış Yap',
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),



              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: sessionsRef.onValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final dataMap = snapshot.data!.snapshot.value;
                    if (dataMap == null) {

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sistemde kayıtlı oturum yok.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _navigateToAddScreen,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Oturum Ekle',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final Map<dynamic, dynamic> data =
                    dataMap as Map<dynamic, dynamic>;


                    final List<Map<String, dynamic>> mySessions = data.entries
                        .where((e) => e.value['akademisyenUid'] == currentUserUid)
                        .map((e) {
                      final session = Map<String, dynamic>.from(e.value);
                      session['oturumID'] = session['oturumID'] ?? e.key;
                      return session;
                    }).toList();

                    if (mySessions.isEmpty) {

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sistemde kayıtlı oturum yok.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _navigateToAddScreen,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Oturum Ekle',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      );
                    }


                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sistemde kayıtlı ${mySessions.length} oturum listeleniyor.',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _navigateToAddScreen,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Oturum Ekle',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: mySessions.length,
                            itemBuilder: (context, index) {
                              final oturum = mySessions[index];
                              final dersKodu = oturum['dersKodu'] ?? '';
                              final dersAdi =
                                  dersKoduToDersAdi[dersKodu] ?? 'Bilinmeyen Ders';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade700,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dersAdi,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ders Kodu: $dersKodu',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Akademisyen UID: ${oturum['akademisyenUid'] ?? '-'}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Tarih: ${oturum['tarih'] ?? '-'}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Saat: ${oturum['saat'] ?? '-'}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Oturum Kodu: ${oturum['oturumID'] ?? '-'}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                          ),
                                          onPressed: () {
                                            final id = oturum['oturumID'] ?? '';
                                            if (id.isNotEmpty) {
                                              _deleteSession(id);
                                            }
                                          },
                                          child: const Text('Sil'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orangeAccent,
                                          ),
                                          onPressed: () {
                                            _navigateToUpdateScreen(oturum);
                                          },
                                          child: const Text('Düzenle'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                          ),
                                          onPressed: () {
                                            _navigateToDetailScreen(oturum);
                                          },
                                          child: const Text('Detay'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
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
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.amber : Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.amber : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
