import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerateScreen extends StatelessWidget {
  const QRGenerateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("QR Sayfası"),
          backgroundColor: Colors.blueGrey.shade900,
        ),
        body: const Center(
          child: Text("Geçersiz veya eksik veri."),
        ),
      );
    }

    final Map<String, dynamic> data = args;

    final String adSoyad = data['adSoyad'] ?? '';
    final String okulNo = data['okulNo'] ?? '';           // öğrenci numarası
    final String oturumKodu = data['oturumKodu'] ?? '';
    final String dersAdi = data['dersAdi'] ?? '';
    final String dersKodu = data['dersKodu'] ?? '';
    final String akademisyenAdi = data['akademisyenAdi'] ?? '';
    final String oturumTarihi = data['oturumTarihi'] ?? '';
    final String oturumSaati = data['oturumSaati'] ?? '';
    final String qrData = data['qrData'] ?? '';           // 2025-06-28-CB99ES-odu003 gibi oturum kodu ve ders bilgisi


    final String fullQrData = "${qrData}_$okulNo";


    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Sayfası"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView( // taşmaları engeller
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Öğrenci Adı", adSoyad),
              _buildInfoRow("Okul Numarası", okulNo),
              _buildInfoRow("Oturum Kodu", oturumKodu),
              _buildInfoRow("Ders Adı", dersAdi),
              _buildInfoRow("Ders Kodu", dersKodu),
              _buildInfoRow("Akademisyen Adı", akademisyenAdi),
              _buildInfoRow("Oturum Tarihi", oturumTarihi),
              _buildInfoRow("Oturum Saati", oturumSaati),
              _buildInfoRow("QR Data", fullQrData),
              const SizedBox(height: 30),
              Center(
                child: QrImageView(
                  data: fullQrData,
                  version: QrVersions.auto,
                  size: 250.0,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 5,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
