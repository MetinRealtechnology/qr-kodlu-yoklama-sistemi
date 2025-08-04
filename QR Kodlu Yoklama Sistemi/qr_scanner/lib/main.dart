import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_scanner/screens/login_screen.dart';
import 'package:qr_scanner/screens/student_panel/attendance_view_screen.dart';
import 'package:qr_scanner/screens/academic_panel/courses_screen.dart';
import 'package:qr_scanner/screens/academic_panel/session_list_screen.dart';
import 'package:qr_scanner/screens/academic_panel/session_add_screen.dart';
import 'package:qr_scanner/screens/academic_panel/session_update_screen.dart';
import 'package:qr_scanner/screens/academic_panel/session_detail_screen.dart';
import 'package:qr_scanner/services/auth_service.dart';
import 'firebase_options.dart';
import 'package:qr_scanner/screens/academic_panel/home_screen.dart';
import 'package:qr_scanner/screens/student_panel/student_home_screen.dart';
import 'package:qr_scanner/screens/student_panel/qr_generate_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Yoklama Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: const LoginScreen(),

      routes: {
        '/root': (context) => const RootScreen(),
        '/home': (context) => const RootScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/session_list': (context) => const SessionListScreen(),
        '/session_add': (context) => const SessionAddScreen(),
        '/academic_home': (context) => const HomeScreen(),
        '/session_update': (context) => const SessionUpdateScreen(oturum: {}), // bu eksik
        '/qr_generate': (context) => const QRGenerateScreen(),
      },


      onGenerateRoute: (settings) {
        if (settings.name == '/session_update') {
          final args = settings.arguments;
          if (args is Map<dynamic, dynamic>) {
            return MaterialPageRoute(
              builder: (_) => SessionUpdateScreen(oturum: args),
            );
          } else {

            return MaterialPageRoute(
              builder: (_) => SessionUpdateScreen(oturum: <dynamic, dynamic>{}),
            );
          }
        }
        if (settings.name == '/session_detail') {
          final args = settings.arguments;
          if (args is Map<dynamic, dynamic>) {
            return MaterialPageRoute(
              builder: (_) => SessionDetailScreen(oturum: args),
            );
          } else {
            return MaterialPageRoute(
              builder: (_) => SessionDetailScreen(oturum: <dynamic, dynamic>{}),
            );
          }
        }
        return null;
      },

    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService.getCurrentUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final role = snapshot.data;
          if (role == 'akademisyen') {
            return const HomeScreen();
          } else if (role == 'ogrenci') {
            return const StudentHomeScreen();
          }
        }


        return const LoginScreen();
      },
    );
  }
}


