QR Kodlu Yoklama Sistemi

Ordu Üniversitesi - Bilgisayar Programcılığı Bitirme Projesi olarak hazırlanmıştır.

Proje Tanıtımı
Bu proje, günümüzde üniversitelerde yoklama işlemlerinde yaşanan zaman kaybı, sahte yoklama girişimleri ve manuel kontrol kaynaklı hataların önüne geçmek amacıyla geliştirilmiştir. QR Kodlu Yoklama Sistemi, hem öğretmen hem de öğrenci tarafında mobil uygulamalar üzerinden çalışmaktadır ve derslere katılımın doğruluğunu arttırmayı, işlemleri dijitalleştirerek hızlandırmayı hedeflemektedir.

Proje, Flutter ve Kotlin teknolojileriyle geliştirilen mobil uygulamalar, Firebase Realtime Database ile bulut tabanlı veri yönetimi ve kimlik doğrulama sistemleri, ayrıca donanım tarafında kullanılan Arduino ESP32-CAM ile donatılmış sabit bir kamera modülünden oluşmaktadır. Sistem tamamen gerçek zamanlı çalışmakta, internet bağlantısı aracılığıyla cihazlar arası veri senkronizasyonu sağlamaktadır.

Sistem İşleyişi
1. Öğretmen Arayüzü
Öğretmen, mobil uygulama üzerinden yeni bir ders tanımlayarak sistemde kayıt altına alır. Her ders bir "ders kodu" ile benzersiz hale getirilir. Ders oluşturulduktan sonra öğretmen, bu ders kapsamında bir oturum (yoklama seansı) başlatır. Oturum, tarih ve saat bilgileriyle birlikte sistemde kayıt edilir ve öğretmen bu oturum için öğrencilerle paylaşılmak üzere özel bir oturum kodu oluşturur.

2. Öğrenci Arayüzü
Öğrenciler, mobil uygulamaya giriş yaptıktan sonra sistemde yer alan ders listesine erişebilirler. Uygulama, her öğrenciye özel, benzersiz bir QR kod oluşturur. Bu QR kod, öğrencinin kimliğini ve yoklama anındaki katılım bilgisini temsil eder. QR kodu yalnızca ilgili oturum saatinde geçerli olacak şekilde yapılandırılmıştır. Öğrenciler, sınıfta yer alan sabit kameraya QR kodlarını göstererek yoklama işlemini tamamlarlar.

3. Kamera ve Donanım Altyapısı
Sınıf ortamında yer alan sabit kamera olarak Arduino ESP32-CAM kartı kullanılmıştır. Bu modül, dahili Wi-Fi desteği sayesinde internet üzerinden Firebase’e doğrudan veri gönderebilir. Kamera, öğrencilerin QR kodlarını algılar ve bu kodları Firebase'e iletir. Buradan gelen veri ile sistem, hangi öğrencinin, hangi oturuma, ne zaman katıldığını öğretmen uygulamasında gösterir.

4. Yoklama Doğrulama ve Raporlama
Yoklama, yalnızca QR kodunun geçerli olduğu oturum saatinde ve sınıf içerisindeki kamera üzerinden okutulmasıyla geçerli olur. Böylece başka bir öğrencinin kodunun ekran görüntüsünü gösterme ya da QR kodu kopyalama gibi yöntemlerle yoklama alınmasının önüne geçilir.
Öğretmen, o ana kadar yoklama almış olan öğrencilerin listesini uygulama içinden canlı olarak görebilir ve işlem sonunda bu listeyi dışa aktarabilir veya arşivleyebilir.

Kullanılan Teknolojiler
Mobil Uygulama Geliştirme:

Flutter (Öğrenci tarafı UI ve logic)

Kotlin (Öğretmen uygulaması veya Android tarafı işlemler)

Veri Tabanı ve Backend:

Firebase Realtime Database

Firebase Authentication

Firebase Cloud Storage (varsa fotoğraf/video yedekleri)

Donanım (IoT):

ESP32-CAM (Arduino tabanlı kamera modülü)

QR kod okuma algoritması (OpenCV veya Firebase SDK destekli)

Proje Amaçları ve Katkıları
-> Yoklama işlemini dijitalleştirme: Manuel olarak liste doldurma ya da çağırma gibi işlemler ortadan kalkar.

-> Zaman tasarrufu: Her oturumda yoklama dakikalar içinde tamamlanır.

-> Güvenli katılım kontrolü: Her öğrenciye özel QR kod ve sınıf ortamına bağlı tarama sistemi sayesinde sahte yoklama engellenmiş olur.

-> Gerçek zamanlı senkronizasyon: Firebase sayesinde tüm kullanıcılar anlık veri güncellemeleriyle çalışır.

-> Donanım destekli çözüm: Gömülü sistemlerle eğitimde nesnelerin interneti (IoT) teknolojilerinin kullanılabilirliği gösterilmiş olur.

-> Gelecek Geliştirmeler
Yüz tanıma sistemleri ile QR kodun yanı sıra ekstra doğrulama mekanizmalarının entegre edilmesi

-> Ders dışı etkinliklerde veya sınav yoklamalarında da sistemin kullanılabilir hale getirilmesi

-> QR kod üretim sürecinin, öğrenci numarası ve okul veritabanı ile eşleştirilerek otomatik hale getirilmesi

-> Kamera sisteminin gelişmiş modellerle güncellenerek birden fazla öğrenciyi aynı anda tanıyabilecek hale gelmesi

Sonuç
QR Kodlu Yoklama Sistemi, üniversite ortamlarında sıkça karşılaşılan yoklama sorunlarına yenilikçi ve teknolojik bir çözüm sunmaktadır. Proje, hem yazılım hem de donanım alanında kapsamlı bir bilgi birikimi gerektirmekte olup, bu yönüyle öğrencilere gerçek dünya problemlerine çözüm üretme yeteneği kazandırmaktadır.

Bu sistem, sadece bir bitirme projesi olmanın ötesine geçerek, gelecekte yükseköğretim kurumlarında yaygın olarak kullanılabilecek bir dijital yoklama sisteminin temelini atmaktadır.