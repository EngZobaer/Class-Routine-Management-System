import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return   FirebaseOptions(
      apiKey: 'your-api-key',
      authDomain: 'your-auth-domain',
      projectId: 'your-project-id',
      storageBucket: 'your-storage-bucket',
      messagingSenderId: 'your-messaging-sender-id',
      appId: 'your-app-id',
      measurementId: 'your-measurement-id',
    );
  }
}
