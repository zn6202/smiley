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
    apiKey: 'AIzaSyAmMSDYiayqcG5jY7zJ6wTp0_CTVImeCgM',
    appId: '1:335884564585:web:ad5bef0566eb34d23c4af8',
    messagingSenderId: '335884564585',
    projectId: 'authentication-873b5',
    authDomain: 'authentication-873b5.firebaseapp.com',
    storageBucket: 'authentication-873b5.appspot.com',
    measurementId: 'G-H1XYC8J0FV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCketFhoz9C9Koq5BkEMSsudUUHCa3xE0A',
    appId: '1:335884564585:android:9c30d1087e2029bc3c4af8',
    messagingSenderId: '335884564585',
    projectId: 'authentication-873b5',
    storageBucket: 'authentication-873b5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC9hwHCaawpUQCvyVH4V_Uc2n_7wnmC0hs',
    appId: '1:335884564585:ios:14467705287d3d6a3c4af8',
    messagingSenderId: '335884564585',
    projectId: 'authentication-873b5',
    storageBucket: 'authentication-873b5.appspot.com',
    androidClientId: '335884564585-3utvpfbloobhfc5c88ckd1o0t8svreru.apps.googleusercontent.com',
    iosClientId: '335884564585-m059i07ai7uckr46p2nm5ksh6m28grfm.apps.googleusercontent.com',
    iosBundleId: 'com.smiley.app.testProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAmMSDYiayqcG5jY7zJ6wTp0_CTVImeCgM',
    appId: '1:335884564585:web:ad5bef0566eb34d23c4af8',
    messagingSenderId: '335884564585',
    projectId: 'authentication-873b5',
    authDomain: 'authentication-873b5.firebaseapp.com',
    storageBucket: 'authentication-873b5.appspot.com',
    measurementId: 'G-H1XYC8J0FV',
  );

}