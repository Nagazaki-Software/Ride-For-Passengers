import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCxq0iBKdwc2F7SdBnYCzMhC-nXIMIEyyU",
            authDomain: "quick-b108e.firebaseapp.com",
            projectId: "quick-b108e",
            storageBucket: "quick-b108e.firebasestorage.app",
            messagingSenderId: "1075126726259",
            appId: "1:1075126726259:web:0d395f965fa14a0bc68406",
            measurementId: "G-D8P4TB2KJP"));
  } else {
    await Firebase.initializeApp();
  }
}
