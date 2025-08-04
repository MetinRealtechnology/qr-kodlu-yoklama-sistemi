class Oturum {
  final String oturumId;
  final String dersKodu;
  final String dersAdi;
  final String oturumTarihi;
  final String oturumSaati;
  final String? akademisyenAdi;
  final String? yoklamaTarihi;
  final String? yoklamaSaati;

  Oturum({
    required this.oturumId,
    required this.dersKodu,
    required this.dersAdi,
    required this.oturumTarihi,
    required this.oturumSaati,
    this.akademisyenAdi,
    this.yoklamaTarihi,
    this.yoklamaSaati,
  });

  factory Oturum.fromMap(Map<dynamic, dynamic> map) {
    return Oturum(
      oturumId: map['oturumId'] ?? '',
      dersKodu: map['dersKodu'] ?? '',
      dersAdi: map['dersAdi'] ?? '',
      oturumTarihi: map['oturumTarihi'] ?? '',
      oturumSaati: map['oturumSaati'] ?? '',
      akademisyenAdi: map['akademisyenAdi'],
      yoklamaTarihi: map['yoklamaTarihi'],
      yoklamaSaati: map['yoklamaSaati'],
    );
  }

  Oturum copyWith({
    String? oturumId,
    String? dersKodu,
    String? dersAdi,
    String? oturumTarihi,
    String? oturumSaati,
    String? akademisyenAdi,
    String? yoklamaTarihi,
    String? yoklamaSaati,
  }) {
    return Oturum(
      oturumId: oturumId ?? this.oturumId,
      dersKodu: dersKodu ?? this.dersKodu,
      dersAdi: dersAdi ?? this.dersAdi,
      oturumTarihi: oturumTarihi ?? this.oturumTarihi,
      oturumSaati: oturumSaati ?? this.oturumSaati,
      akademisyenAdi: akademisyenAdi ?? this.akademisyenAdi,
      yoklamaTarihi: yoklamaTarihi ?? this.yoklamaTarihi,
      yoklamaSaati: yoklamaSaati ?? this.yoklamaSaati,
    );
  }
}
