import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'attendance_view_screen.dart';
import '../../models/oturum_model.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String adSoyad = "";
  String email = "";
  String okulNo = "";
  final TextEditingController _oturumKoduController = TextEditingController();


  List<Oturum> oturumlar = [];

  @override
  void initState() {
    super.initState();
    fetchStudentInfo();
  }

  Future<void> fetchStudentInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseDatabase.instance.ref("kullanicilar/$uid").get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          adSoyad = data['adSoyad']?.toString() ?? '';
          email = data['email']?.toString() ?? '';
          okulNo = data['okulNo']?.toString() ?? '';
        });
        await fetchOturumlarim();
      }
    } catch (e) {
      debugPrint('Öğrenci bilgisi alınamadı: $e');
    }
  }

  Future<void> fetchOturumlarim() async {
    if (okulNo.isEmpty) return;

    try {
      final dbRef = FirebaseDatabase.instance.ref();
      final yoklamaSnapshot = await dbRef.child('yoklamalar').get();

      if (!yoklamaSnapshot.exists || yoklamaSnapshot.value == null) return;

      final tumYoklamalar = Map<dynamic, dynamic>.from(yoklamaSnapshot.value as Map);

      List<Oturum> geciciOturumlar = [];

      for (var oturumKodu in tumYoklamalar.keys) {
        final katilimcilar = Map<dynamic, dynamic>.from(tumYoklamalar[oturumKodu]);

        if (katilimcilar.containsKey(okulNo)) {
          final katilimBilgi = Map<dynamic, dynamic>.from(katilimcilar[okulNo]);


          final oturumSnapshot = await dbRef.child('oturumlar/$oturumKodu').get();
          if (!oturumSnapshot.exists || oturumSnapshot.value == null) continue;
          final oturumData = Map<String, dynamic>.from(oturumSnapshot.value as Map);
          final dersKodu = oturumData['dersKodu']?.toString() ?? '';
          final tarih = oturumData['tarih']?.toString() ?? '';
          final saat = oturumData['saat']?.toString() ?? '';


          final dersSnapshot = await dbRef.child('dersler/$dersKodu').get();
          if (!dersSnapshot.exists || dersSnapshot.value == null) continue;
          final dersData = Map<String, dynamic>.from(dersSnapshot.value as Map);
          final dersAdi = dersData['dersAdi']?.toString() ?? '';
          final akademisyenUid = dersData['akademisyenUid']?.toString() ?? '';


          final akademisyenSnapshot = await dbRef.child('kullanicilar/$akademisyenUid').get();
          if (!akademisyenSnapshot.exists || akademisyenSnapshot.value == null) continue;
          final akademisyenData = Map<String, dynamic>.from(akademisyenSnapshot.value as Map);
          final akademisyenAdi = akademisyenData['adSoyad']?.toString() ?? '';


          final katilmaSaati = katilimBilgi['saat']?.toString() ?? saat;
          final katilmaTarihi = katilimBilgi['tarih']?.toString() ?? tarih;

          geciciOturumlar.add(Oturum(
            oturumId: oturumKodu.toString(),
            dersKodu: dersKodu,
            dersAdi: dersAdi,
            oturumTarihi: tarih,
            oturumSaati: saat,
            akademisyenAdi: akademisyenAdi,
            yoklamaTarihi: katilmaTarihi,
            yoklamaSaati: katilmaSaati,
          ));

        }
      }

      if (mounted) {
        setState(() {
          oturumlar = geciciOturumlar;
        });
      }
    } catch (e) {
      debugPrint('Yoklamalar alınırken hata oluştu: $e');
    }
  }

  @override
  void dispose() {
    _oturumKoduController.dispose();
    super.dispose();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  void _katilOturuma() async {
    final kod = _oturumKoduController.text.trim();

    if (kod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen oturum kodunu giriniz.')),
      );
      return;
    }

    if (kod.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oturum kodu tam 6 haneli olmalıdır.')),
      );
      return;
    }

    try {
      final dbRef = FirebaseDatabase.instance.ref();

      final oturumSnapshot = await dbRef.child('oturumlar/$kod').get();
      if (!oturumSnapshot.exists || oturumSnapshot.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Girilen oturum koduna ait veri bulunamadı.')),
        );
        return;
      }

      final oturumData = Map<String, dynamic>.from(oturumSnapshot.value as Map);
      final dersKodu = oturumData['dersKodu']?.toString();
      final tarih = oturumData['tarih']?.toString();
      final saat = oturumData['saat']?.toString();

      if (dersKodu == null || tarih == null || saat == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oturum verileri eksik.')),
        );
        return;
      }

      final dersSnapshot = await dbRef.child('dersler/$dersKodu').get();
      if (!dersSnapshot.exists || dersSnapshot.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Derse ait veri bulunamadı.')),
        );
        return;
      }

      final dersData = Map<String, dynamic>.from(dersSnapshot.value as Map);
      final dersAdi = dersData['dersAdi']?.toString();
      final akademisyenId = dersData['akademisyenUid']?.toString();

      if (dersAdi == null || akademisyenId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ders veya akademisyen bilgileri eksik.')),
        );
        return;
      }

      final akademisyenSnapshot = await dbRef.child('kullanicilar/$akademisyenId').get();
      if (!akademisyenSnapshot.exists || akademisyenSnapshot.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akademisyene ait bilgi bulunamadı.')),
        );
        return;
      }

      final akademisyenData = Map<String, dynamic>.from(akademisyenSnapshot.value as Map);
      final akademisyenAdi = akademisyenData['adSoyad']?.toString() ?? '';

      final qrData = {
        'adSoyad': adSoyad,
        'okulNo': okulNo,
        'oturumKodu': kod,
        'dersAdi': dersAdi,
        'dersKodu': dersKodu,
        'akademisyenAdi': akademisyenAdi,
        'oturumTarihi': tarih,
        'oturumSaati': saat,
        'qrData': kod,
      };

      if (!mounted) return;
      Navigator.pushNamed(context, '/qr_generate', arguments: qrData);
    } catch (e) {
      debugPrint('Hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veri alınırken hata oluştu.')),
      );
    }
  }

  void _goAttendanceView() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceViewScreen(
          adSoyad: adSoyad,
          email: email,
          okulNo: okulNo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Yoklama Sistemi'),
        backgroundColor: Colors.blueGrey.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: _logout,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/logo.png', width: 120)),
            const SizedBox(height: 20),
            const Text("Hoşgeldiniz,", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Giriş Bilgileriniz", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("Ad Soyad: $adSoyad"),
                  Text("E-Posta Adresi: $email"),
                  Text("Okul Numarası: $okulNo"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Oturum Kodu", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _oturumKoduController,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              ],
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.qr_code),
                hintText: "6 haneli oturum kodunu giriniz",
                border: OutlineInputBorder(),
                counterText: "",
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _katilOturuma,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Yoklamaya Katıl"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Yoklamalar'),
        ],
        onTap: (index) {
          if (index == 1) {
            _goAttendanceView();
          }
        },
      ),
    );
  }
}
