#include <WiFi.h>
#include <ESP32QRCodeReader.h>
#include <FirebaseESP32.h>
#include <WiFiUdp.h>
#include <NTPClient.h>

// WiFi bilgileri
#define WIFI_SSID "WIFI SSID"
#define WIFI_PASSWORD "WIFI PASSWORD"

// Firebase bilgileri
#define DATABASE_URL "YOUR DATABASE URL"
#define DATABASE_SECRET "YOUR CODE"

// Buzzer pin
#define BUZZER_PIN 3

// Firebase nesneleri
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// QR okuyucu
ESP32QRCodeReader reader(CAMERA_MODEL_AI_THINKER);
struct QRCodeData qrCodeData;

// Saat için NTP
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 3 * 3600, 60000); // GMT+3

void setup() {
  Serial.begin(115200);
  pinMode(BUZZER_PIN, OUTPUT); // Buzzer pini çıkış
  digitalWrite(BUZZER_PIN, LOW);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("WiFi bağlanıyor");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500); Serial.print(".");
  }
  Serial.println(" Bağlandı!");

  timeClient.begin();
  timeClient.update();

  config.database_url = DATABASE_URL;
  config.signer.tokens.legacy_token = DATABASE_SECRET;
  Firebase.begin(&config, &auth);

  reader.setup();
  reader.begin();
  Serial.println("QR kod okuyucu hazır");
}

void loop() {
  if (reader.receiveQrCode(&qrCodeData, 1000)) {
    if (qrCodeData.valid) {
      String qrString = (const char*)qrCodeData.payload;
      qrString.trim();
      Serial.println("QR: " + qrString);

      int sepIndex = qrString.indexOf('_');
      if (sepIndex == -1) {
        Serial.println("QR verisi beklenen formatta değil!");
        return;
      }

      String oturumKodu = qrString.substring(0, sepIndex);
      String okulNo = qrString.substring(sepIndex + 1);
      Serial.println("Oturum: " + oturumKodu + " | Okul No: " + okulNo);

      // Firebase'ten kullanıcı verisi çek
      String uidPath = "/kullanicilar";
      if (!Firebase.getJSON(fbdo, uidPath)) {
        Serial.println("Firebase JSON alma hatası: " + fbdo.errorReason());
        return;
      }

      FirebaseJson json = fbdo.jsonObject();
      FirebaseJsonData jsonData;
      String ogrenciUid = "", adSoyad = "";

      size_t count = json.iteratorBegin();
      String key, value;
      int type;

      for (size_t i = 0; i < count; i++) {
        json.iteratorGet(i, type, key, value);
        FirebaseJson userJson;
        userJson.setJsonData(value);

        FirebaseJsonData temp;
        String okNo, adSoy;

        userJson.get(temp, "okulNo");
        okNo = temp.stringValue;

        if (okNo == okulNo) {
          userJson.get(temp, "adSoyad");
          adSoy = temp.stringValue;

          ogrenciUid = key;
          adSoyad = adSoy;
          break;
        }
      }
      json.iteratorEnd();

      if (ogrenciUid == "") {
        Serial.println("Öğrenci bulunamadı!");
        return;
      }

      // Tarih ve saat al
      timeClient.update();
      String saat = timeClient.getFormattedTime();

      time_t rawtime = timeClient.getEpochTime();
      struct tm *ti = localtime(&rawtime);
      char tarih[11];
      snprintf(tarih, sizeof(tarih), "%04d-%02d-%02d", ti->tm_year + 1900, ti->tm_mon + 1, ti->tm_mday);

      // Firebase'e yaz
      String path = "/yoklamalar/" + oturumKodu + "/" + okulNo;
      FirebaseJson veri;
      veri.set("adSoyad", adSoyad);
      veri.set("ogrenciUid", ogrenciUid);
      veri.set("okulNo", okulNo);
      veri.set("saat", saat);
      veri.set("tarih", tarih);
      veri.set("katildi", true);

      if (Firebase.setJSON(fbdo, path, veri)) {
        Serial.println("Yoklama başarıyla kaydedildi!");

        
        digitalWrite(BUZZER_PIN, HIGH);
        delay(1000);
        digitalWrite(BUZZER_PIN, LOW);

      } else {
        Serial.println("Yoklama gönderilemedi: " + fbdo.errorReason());
      }

      delay(2000); // Aynı QR tekrar okutulmasın diye bekleme
    }
  }
}
