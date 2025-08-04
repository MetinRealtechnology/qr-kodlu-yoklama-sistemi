import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SessionDetailScreen extends StatefulWidget {
  final Map<dynamic, dynamic> oturum;

  const SessionDetailScreen({Key? key, required this.oturum}) : super(key: key);

  @override
  _SessionDetailScreenState createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  String? dersAdi;
  List<Map<dynamic, dynamic>> yoklamalarList = [];

  @override
  void initState() {
    super.initState();
    fetchDersAdi();
    fetchYoklamalar();
  }

  Future<void> fetchDersAdi() async {
    final derslerRef = FirebaseDatabase.instance.ref().child('dersler');
    final snapshot = await derslerRef.get();

    if (snapshot.exists) {
      final dersler = snapshot.value as Map<dynamic, dynamic>;
      for (var entry in dersler.entries) {
        final ders = entry.value;
        if (ders['dersKodu'] == widget.oturum['dersKodu']) {
          setState(() {
            dersAdi = ders['dersAdi'];
          });
          break;
        }
      }
    }
  }

  Future<void> fetchYoklamalar() async {
    final oturumId = widget.oturum['oturumID'];
    final yoklamalarRef = FirebaseDatabase.instance.ref().child('yoklamalar').child(oturumId);

    final snapshot = await yoklamalarRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      List<Map<dynamic, dynamic>> tempList = [];
      data.forEach((key, value) {
        tempList.add(value);
      });

      setState(() {
        yoklamalarList = tempList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final oturum = widget.oturum;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oturum Detayları'),
        backgroundColor: Colors.blueGrey.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Oturum Kodu", oturum['oturumID'] ?? "Bilinmiyor", Icons.vpn_key),
                  const SizedBox(height: 12),
                  _buildDetailRow("Ders Adı", dersAdi ?? "Yükleniyor...", Icons.book),
                  const SizedBox(height: 12),
                  _buildDetailRow("Ders Kodu", oturum['dersKodu'] ?? "Bilinmiyor", Icons.code),
                  const SizedBox(height: 12),
                  _buildDetailRow("Tarih", oturum['tarih'] ?? "Bilinmiyor", Icons.calendar_today),
                  const SizedBox(height: 12),
                  _buildDetailRow("Saat", oturum['saat'] ?? "Bilinmiyor", Icons.access_time),
                  const SizedBox(height: 12),
                  _buildDetailRow("Toplam Öğrenci Sayısı", yoklamalarList.length.toString(), Icons.group),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Katılan Öğrenciler',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),

            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: yoklamalarList.length,
              itemBuilder: (context, index) {
                final yoklama = yoklamalarList[index];
                final adSoyad = yoklama['adSoyad'] ?? 'Bilinmiyor';
                final okulNo = yoklama['okulNo'] ?? 'Bilinmiyor';
                final yoklamaTarihi = yoklama['tarih'] ?? 'Bilinmiyor';
                final yoklamaSaati = yoklama['saat'] ?? 'Bilinmiyor';


                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(adSoyad),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Numara: $okulNo'),
                        Text('Katılım Tarihi: $yoklamaTarihi $yoklamaSaati'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
