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
    apiKey: 'AIzaSyD2IGeXqXW6eNEkdqRDUJIOCzvjhp73by8',
    appId: '1:420047878605:web:bef7a6778e4ab84c7d6c84',
    messagingSenderId: '420047878605',
    projectId: 'consumewise',
    authDomain: 'consumewise.firebaseapp.com',
    databaseURL: 'https://consumewise-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'consumewise.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCtVa60BMtcxrzxd_dl3A01MNe2SPQCzRc',
    appId: '1:420047878605:android:28d80291ea15484c7d6c84',
    messagingSenderId: '420047878605',
    projectId: 'consumewise',
    databaseURL: 'https://consumewise-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'consumewise.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA7tS8WDqX_KvAh7luPe4LjOe_3d1U0rHU',
    appId: '1:420047878605:ios:66bb15b2e3f87ce77d6c84',
    messagingSenderId: '420047878605',
    projectId: 'consumewise',
    databaseURL: 'https://consumewise-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'consumewise.appspot.com',
    iosClientId: '420047878605-9r44q7bg6kltrmn1nva9gt01if3j5qnh.apps.googleusercontent.com',
    iosBundleId: 'com.example.overlay',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA7tS8WDqX_KvAh7luPe4LjOe_3d1U0rHU',
    appId: '1:420047878605:ios:66bb15b2e3f87ce77d6c84',
    messagingSenderId: '420047878605',
    projectId: 'consumewise',
    databaseURL: 'https://consumewise-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'consumewise.appspot.com',
    iosClientId: '420047878605-9r44q7bg6kltrmn1nva9gt01if3j5qnh.apps.googleusercontent.com',
    iosBundleId: 'com.example.overlay',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD2IGeXqXW6eNEkdqRDUJIOCzvjhp73by8',
    appId: '1:420047878605:web:134e59a624731b327d6c84',
    messagingSenderId: '420047878605',
    projectId: 'consumewise',
    authDomain: 'consumewise.firebaseapp.com',
    databaseURL: 'https://consumewise-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'consumewise.appspot.com',
  );

}