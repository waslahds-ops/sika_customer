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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCvI-tZfAVZafGYjGanmCI7S_M_hRsV6u8',
    appId: '1:87860048304:web:08b7ec575f79720f145da5',
    messagingSenderId: '87860048304',
    projectId: 'sika-applications',
    authDomain: 'sika-applications.firebaseapp.com',
    storageBucket: 'sika-applications.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvI-tZfAVZafGYjGanmCI7S_M_hRsV6u8',
    appId: '1:87860048304:android:9f25810414805cb375a675',
    messagingSenderId: '87860048304',
    projectId: 'sika-applications',
    storageBucket: 'sika-applications.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCvI-tZfAVZafGYjGanmCI7S_M_hRsV6u8',
    appId: '1:87860048304:ios:6c9a7ae49b741158145da5',
    messagingSenderId: '87860048304',
    projectId: 'sika-applications',
    storageBucket: 'sika-applications.firebasestorage.app',
    iosBundleId: 'com.example.glovoApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCvI-tZfAVZafGYjGanmCI7S_M_hRsV6u8',
    appId: '1:87860048304:ios:6c9a7ae49b741158145da5',
    messagingSenderId: '87860048304',
    projectId: 'sika-applications',
    storageBucket: 'sika-applications.firebasestorage.app',
    iosBundleId: 'com.example.glovoApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCvI-tZfAVZafGYjGanmCI7S_M_hRsV6u8',
    appId: '1:87860048304:web:a0857cbfadc669c8145da5',
    messagingSenderId: '87860048304',
    projectId: 'sika-applications',
    authDomain: 'sika-applications.firebaseapp.com',
    storageBucket: 'sika-applications.firebasestorage.app',
  );
}
