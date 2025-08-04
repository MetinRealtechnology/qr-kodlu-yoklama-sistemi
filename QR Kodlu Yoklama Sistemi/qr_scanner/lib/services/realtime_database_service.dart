import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import 'package:qr_scanner/models/oturum_model.dart';

final Logger _logger = Logger('RealtimeDatabaseService');

class RealtimeDatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<List<Oturum>> getStudentAttendance(String userUid) async {
    final List<Oturum> attendanceList = [];

    try {

      final yoklamalarSnapshot = await _dbRef.child('yoklamalar').get();

      if (!yoklamalarSnapshot.exists) {
        _logger.info('Yoklamalar node’u boş.');
        return attendanceList;
      }

      final yoklamalarData = yoklamalarSnapshot.value as Map<dynamic, dynamic>;

      for (var oturumId in yoklamalarData.keys) {
        final ogrencilerMap = yoklamalarData[oturumId];

        if (ogrencilerMap is Map) {
          for (var okulNo in ogrencilerMap.keys) {
            final yoklamaBilgi = ogrencilerMap[okulNo];

            if (yoklamaBilgi is Map && yoklamaBilgi['ogrenciUid'] == userUid) {

              final oturumSnapshot = await _dbRef.child('oturumlar/$oturumId').get();

              if (oturumSnapshot.exists) {
                final oturumData = oturumSnapshot.value as Map<dynamic, dynamic>;

                final oturum = Oturum(
                  oturumId: oturumData['oturumID'] ?? '',
                  dersKodu: oturumData['dersKodu'] ?? '',
                  dersAdi: '',
                  oturumTarihi: oturumData['tarih'] ?? '',
                  oturumSaati: oturumData['saat'] ?? '',
                  akademisyenAdi: '',
                  yoklamaTarihi: yoklamaBilgi['tarih'] ?? '',
                  yoklamaSaati: yoklamaBilgi['saat'] ?? '',
                );

                attendanceList.add(oturum);
              } else {
                _logger.warning('Oturum $oturumId verisi bulunamadı.');
              }
            }
          }
        }
      }
    } catch (e, stacktrace) {
      _logger.severe('Hata RealtimeDatabaseService.getStudentAttendance: $e', e, stacktrace);
    }

    return attendanceList;
  }
}
