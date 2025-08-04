import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class SessionUpdateScreen extends StatefulWidget {
  final Map<dynamic, dynamic> oturum;

  const SessionUpdateScreen({super.key, required this.oturum});

  @override
  State<SessionUpdateScreen> createState() => _SessionUpdateScreenState();
}

class _SessionUpdateScreenState extends State<SessionUpdateScreen> {
  late String oturumID;
  late String selectedDate;
  late String selectedTime;
  String? selectedDersKodu;
  Map<String, dynamic> dersler = {};

  @override
  void initState() {
    super.initState();
    oturumID = widget.oturum['oturumID'] ?? '';
    selectedDate = widget.oturum['tarih'] ?? '';
    selectedTime = widget.oturum['saat'] ?? '';
    selectedDersKodu = widget.oturum['dersKodu'];
    fetchDersler();
  }

  Future<void> fetchDersler() async {
    final ref = FirebaseDatabase.instance.ref('dersler');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        dersler = data.map((key, value) => MapEntry(value['dersKodu'], value['dersAdi']));
      });
    }
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(selectedDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> pickTime() async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        selectedTime = picked.format(context);
      });
    }
  }

  Future<void> updateSession() async {
    final ref = FirebaseDatabase.instance.ref('oturumlar/$oturumID');

    await ref.update({
      'tarih': selectedDate,
      'saat': selectedTime,
      'dersKodu': selectedDersKodu,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oturum başarıyla güncellendi')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Oturum Düzenle"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: const [
                Icon(Icons.code),
                SizedBox(width: 8),
                Text("Oturum ID", style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              oturumID,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),


            Row(
              children: const [
                Icon(Icons.calendar_today),
                SizedBox(width: 8),
                Text("Tarih", style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                child: Text(selectedDate),
              ),
            ),
            const SizedBox(height: 16),


            Row(
              children: const [
                Icon(Icons.access_time),
                SizedBox(width: 8),
                Text("Saat", style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: pickTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                child: Text(selectedTime),
              ),
            ),
            const SizedBox(height: 16),


            Row(
              children: const [
                Icon(Icons.menu_book),
                SizedBox(width: 8),
                Text("Ders", style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: selectedDersKodu,
              items: dersler.entries
                  .map((e) => DropdownMenuItem<String>(
                value: e.key,
                child: Text("${e.value} (${e.key})"),
              ))
                  .toList(),
              onChanged: (val) => setState(() => selectedDersKodu = val),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: updateSession,
              child: const Text("Oturumu Düzenle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
