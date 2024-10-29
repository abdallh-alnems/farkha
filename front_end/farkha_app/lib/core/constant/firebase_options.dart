// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCTVAJkSR4NGFC_UmMXQFwtGiULgubMVak',
    appId: '1:159521160544:web:5afb453663a0ebc521f205',
    messagingSenderId: '159521160544',
    projectId: 'farkha-c7248',
    authDomain: 'farkha-c7248.firebaseapp.com',
    storageBucket: 'farkha-c7248.appspot.com',
    measurementId: 'G-04MHH243XW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAkcXEc6ICXvD0W4GMHZ9JDZfURYJSUWLQ',
    appId: '1:159521160544:android:8bb038def7e3670a21f205',
    messagingSenderId: '159521160544',
    projectId: 'farkha-c7248',
    storageBucket: 'farkha-c7248.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtHWNP-fmKjEt46NypsMws0SwyMaNjhfo',
    appId: '1:159521160544:ios:dae94e93884611d221f205',
    messagingSenderId: '159521160544',
    projectId: 'farkha-c7248',
    storageBucket: 'farkha-c7248.appspot.com',
    iosBundleId: 'com.example.farkhaApp',
  );
}