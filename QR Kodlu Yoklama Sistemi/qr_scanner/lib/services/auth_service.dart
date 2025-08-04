import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _database = FirebaseDatabase.instance.ref();


  static Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _database.child('kullanicilar/${user.uid}/tip').get();

    if (snapshot.exists) {
      return snapshot.value.toString();
    }

    return null;
  }
}
