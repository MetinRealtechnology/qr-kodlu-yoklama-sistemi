QR-Based Attendance System is a mobile and hardware-supported solution that enables teachers and students to handle attendance in real time. The application is built with Flutter and integrated with Firebase. An ESP32-CAM module installed in the classroom detects students' personal QR codes and automatically logs attendance.

This project was developed as a Graduation Project at Ordu University - Computer Programming Department.

 Technologies Used: Flutter, Kotlin, Firebase, ESP32-CAM, Arduino, QR Code, IoT

 The system has two separate user interfaces:

• Teacher Panel: Create courses/sessions, monitor attendance

• Student Panel: Generate personal QR code, attend class

 QR codes are unique for each student and only valid during the defined session time.

 The ESP32-CAM module in the classroom scans the QR codes and sends the data to Firebase, ensuring real-time and automated attendance logging.

 ------ TÜRKÇE ------

 QR Kodlu Yoklama Sistemi, öğretmen ve öğrencilerin gerçek zamanlı olarak yoklama işlemlerini gerçekleştirebildiği, mobil uygulama ve donanım destekli bir sistemdir. Flutter ile geliştirilen uygulama, Firebase üzerinde çalışır ve sınıfa sabitlenen bir ESP32-CAM cihazı sayesinde öğrencilerin QR kodlarını algılayarak otomatik yoklama alır.

Bu proje, Ordu Üniversitesi - Bilgisayar Programcılığı Bitirme Projesi kapsamında geliştirilmiştir.

Kullanılan Teknolojiler: Flutter, Kotlin, Firebase, ESP32-CAM, Arduino, QR Code, IoT

  Uygulama iki taraflı çalışır:
• Öğretmen Paneli: Ders/oturum oluşturma, yoklama takibi
• Öğrenci Paneli: QR üretme, derse giriş işlemleri

QR kodlar kişiye özeldir ve sadece belirtilen oturum zamanında geçerlidir.

Donanım tarafında, sınıf içerisine yerleştirilen ESP32-CAM kartı, QR kodları tarayarak Firebase’e veri gönderir. Böylece sistemde yoklama otomatik olarak işlenir.
