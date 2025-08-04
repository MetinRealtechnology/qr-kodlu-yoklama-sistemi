import 'package:flutter/material.dart';
import 'package:qr_scanner/models/oturum_model.dart';
import 'package:qr_scanner/services/realtime_database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AttendanceViewScreen extends StatefulWidget {
  final String adSoyad;
  final String okulNo;
  final String email;

  const AttendanceViewScreen({
    super.key,
    required this.adSoyad,
    required this.okulNo,
    required this.email,
  });

  @override
  State<AttendanceViewScreen> createState() => _AttendanceViewScreenState();
}

class _AttendanceViewScreenState extends State<AttendanceViewScreen> {
  List<Oturum> oturumlar = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => isLoading = false);
      return;
    }

    final databaseService = RealtimeDatabaseService();
    final attendanceList = await databaseService.getStudentAttendance(uid);

    // Her oturum için akademisyen adını yükle
    for (var i = 0; i < attendanceList.length; i++) {
      final oturum = attendanceList[i];
      final oturumRef = FirebaseDatabase.instance.ref('oturumlar/${oturum.oturumId}');
      final oturumSnapshot = await oturumRef.get();

      final akademisyenUid = oturumSnapshot.child('akademisyenUid').value?.toString();
      String akademisyenAdi = '-';

      if (akademisyenUid != null && akademisyenUid.isNotEmpty) {
        final kullaniciRef = FirebaseDatabase.instance.ref('kullanicilar/$akademisyenUid');
        final kullaniciSnapshot = await kullaniciRef.get();
        if (kullaniciSnapshot.exists) {
          final data = kullaniciSnapshot.value as Map;
          akademisyenAdi = data['adSoyad'] ?? '-';
        }
      }

      attendanceList[i] = oturum.copyWith(akademisyenAdi: akademisyenAdi);
    }

    setState(() {
      oturumlar = attendanceList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoklamalarım'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ad Soyad: ${widget.adSoyad}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Öğrenci No: ${widget.okulNo}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Email: ${widget.email}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Katıldığı Oturumlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (oturumlar.isEmpty)
              const Center(
                child: Text(
                  'Henüz katıldığınız oturum yok.',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              )
            else
              ...oturumlar.map((oturum) => OturumCard(oturum: oturum)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Yoklamalar'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          }
        },
      ),
    );
  }
}

class OturumCard extends StatelessWidget {
  final Oturum oturum;

  const OturumCard({super.key, required this.oturum});

  @override
  Widget build(BuildContext context) {
    final yoklamaTarihi = oturum.yoklamaTarihi?.isNotEmpty == true ? oturum.yoklamaTarihi : '-';
    final yoklamaSaati = oturum.yoklamaSaati?.isNotEmpty == true ? oturum.yoklamaSaati : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Oturum ID: ${oturum.oturumId}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Ders: ${oturum.dersKodu} - ${oturum.dersAdi}'),
            Text('Oturum Tarihi: ${oturum.oturumTarihi}'),
            Text('Oturum Saati: ${oturum.oturumSaati}'),
            Text('Akademisyen: ${oturum.akademisyenAdi}'),
            const SizedBox(height: 6),
            Text('Yoklama Tarihi: $yoklamaTarihi'),
            Text('Yoklama Saati: $yoklamaSaati'),
          ],
        ),
      ),
    );
  }
}
