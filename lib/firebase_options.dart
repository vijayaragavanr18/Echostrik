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
    apiKey: 'AIzaSyAhcaBFqyGvMBcmjYLAYMCCRcQjX54BieU',
    appId: '1:26607371555:web:echostrik_web_app',
    messagingSenderId: '26607371555',
    projectId: 'echostrik',
    authDomain: 'echostrik.firebaseapp.com',
    storageBucket: 'echostrik.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhcaBFqyGvMBcmjYLAYMCCRcQjX54BieU',
    appId: '1:26607371555:android:a8eb29f153289e2fbc7896',
    messagingSenderId: '26607371555',
    projectId: 'echostrik',
    storageBucket: 'echostrik.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAhcaBFqyGvMBcmjYLAYMCCRcQjX54BieU',
    appId: '1:26607371555:ios:echostrik_ios_app',
    messagingSenderId: '26607371555',
    projectId: 'echostrik',
    storageBucket: 'echostrik.firebasestorage.app',
    iosBundleId: 'echostrik.vijayaragavan',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAhcaBFqyGvMBcmjYLAYMCCRcQjX54BieU',
    appId: '1:26607371555:macos:echostrik_macos_app',
    messagingSenderId: '26607371555',
    projectId: 'echostrik',
    storageBucket: 'echostrik.firebasestorage.app',
    iosBundleId: 'echostrik.vijayaragavan',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAhcaBFqyGvMBcmjYLAYMCCRcQjX54BieU',
    appId: '1:26607371555:windows:echostrik_windows_app',
    messagingSenderId: '26607371555',
    projectId: 'echostrik',
    storageBucket: 'echostrik.firebasestorage.app',
  );
}
