// Generated from google-services.json (Android) and GoogleService-Info.plist (iOS)
// Project: ehjez-notifications

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCg23QWSTSkf9stzZ6VqtEsBkw6jz_Z21c',
    appId: '1:517612301230:android:96754159879362d58ab63f',
    messagingSenderId: '517612301230',
    projectId: 'ehjez-notifications',
    storageBucket: 'ehjez-notifications.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBl-cSVb2bvA-sewl4d-WHmM1RGjN4cy6o',
    appId: '1:517612301230:ios:3530dbac59a3296e8ab63f',
    messagingSenderId: '517612301230',
    projectId: 'ehjez-notifications',
    storageBucket: 'ehjez-notifications.firebasestorage.app',
    iosBundleId: 'com.example.ehjez',
  );
}
