import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class SessionAddScreen extends StatefulWidget {
  const SessionAddScreen({super.key});

  @override
  State<SessionAddScreen> createState() => _SessionAddScreenState();
}

class _SessionAddScreenState extends State<SessionAddScreen> {
  final dbRef = FirebaseDatabase.instance.ref();
  String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Map<dynamic, dynamic>? _selectedCourse;

  List<Map<dynamic, dynamic>> _courses = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final coursesSnapshot = await dbRef.child('dersler').get();

    if (coursesSnapshot.exists) {
      final data = coursesSnapshot.value as Map<dynamic, dynamic>;

      setState(() {
        _courses = data.entries
            .where((e) => e.value['akademisyenUid'] == currentUserUid) // filtre burada
            .map((e) {
          final val = e.value as Map<dynamic, dynamic>;
          return {
            'dersID': e.key,
            'dersAdi': val['dersAdi'],
            'dersKodu': val['dersKodu'],
            'akademisyenUid': val['akademisyenUid'],
          };
        })
            .toList();
      });
    }
  }


  Future<void> _selectDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  String _generateRandomSessionID(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _createSession() async {
    if (_selectedDate == null || _selectedTime == null || _selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final oturumID = _generateRandomSessionID(6);
      final tarihStr = "${_selectedDate!.year.toString().padLeft(4, '0')}-"
          "${_selectedDate!.month.toString().padLeft(2, '0')}-"
          "${_selectedDate!.day.toString().padLeft(2, '0')}";
      final saatStr = "${_selectedTime!.hour.toString().padLeft(2, '0')}:"
          "${_selectedTime!.minute.toString().padLeft(2, '0')}";

      final qrData = "$tarihStr-$oturumID-${_selectedCourse!['dersKodu']}";

      final sessionData = {
        'akademisyenUid': currentUserUid,
        'dersKodu': _selectedCourse!['dersKodu'],
        'oturumID': oturumID,
        'qrData': qrData,
        'saat': saatStr,
        'tarih': tarihStr,
      };

      await dbRef.child('oturumlar').child(oturumID).set(sessionData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oturum başarıyla oluşturuldu')),
      );

      Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oturum oluşturulurken hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        title: const Text('Oturum Ekle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Tarih Seçimi',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Tarih seçiniz'
                      : "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),


            const Text(
              'Saat Seçimi',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedTime == null
                      ? 'Saat seçiniz'
                      : _selectedTime!.format(context),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),


            const Text(
              'Ders Seçiniz',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<dynamic, dynamic>>(
                  isExpanded: true,
                  hint: const Text(
                    'Ders seçiniz',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: _selectedCourse,
                  dropdownColor: Colors.blueGrey.shade700,
                  items: _courses.map((course) {
                    return DropdownMenuItem<Map<dynamic, dynamic>>(
                      value: course,
                      child: Text(
                        course['dersAdi'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourse = value;
                    });
                  },
                ),
              ),
            ),

            const Spacer(),


            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                  'Oturum Oluştur',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
