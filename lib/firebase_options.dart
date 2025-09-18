// File: lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAi-VHDxCZx8fj4SQhGctxpQVO5kwGi_zE',
    appId: '1:1068612952671:web:b59bb9a41ed6acb5ad71ea',
    messagingSenderId: '1068612952671',
    projectId: 'darul-hidayah-class-routine',
    authDomain: 'darul-hidayah-class-routine.firebaseapp.com',
    storageBucket: 'darul-hidayah-class-routine.firebasestorage.app',
    measurementId: 'G-J3V0W5TT08',
  );

  // ✅ Web Config

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAeCRAu5-wxdMO3eCYNtsN1PVD9KBy8n7Q',
    appId: '1:1068612952671:android:48f72d7371cfb40cad71ea',
    messagingSenderId: '1068612952671',
    projectId: 'darul-hidayah-class-routine',
    storageBucket: 'darul-hidayah-class-routine.firebasestorage.app',
  );

  // ✅ Android Config

  // ✅ iOS Config (যদি কখনো দরকার হয়)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDxxxxxx-Your-iOS-API-Key",
    appId: "1:1068612952671:ios:xxxxxxxxxxxxxx",
    messagingSenderId: "1068612952671",
    projectId: "darul-hidayah-class-routine",
    storageBucket: "darul-hidayah-class-routine.appspot.com",
    iosClientId: "1068612952671-xxxxxxxxxxxx.apps.googleusercontent.com",
    iosBundleId: "darulhidayah.classroutine",
  );

  // ✅ macOS Config (optional)
  static const FirebaseOptions macos = ios;
}