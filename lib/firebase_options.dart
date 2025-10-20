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
    apiKey: 'AIzaSyBLsVjwsqZINvZbaBtpgeDGeZG1pIJJC3s',
    appId: '1:980903205715:web:9f7f0931a1ee1664be5fa6',
    messagingSenderId: '980903205715',
    projectId: 'masu-learning-app-a4974',
    authDomain: 'masu-learning-app-a4974.firebaseapp.com',
    storageBucket: 'masu-learning-app-a4974.firebasestorage.app',
    measurementId: 'G-48JD60BQHV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBLsVjwsqZINvZbaBtpgeDGeZG1pIJJC3s',
    appId: '1:980903205715:android:67f0b658b5d75ec4be5fa6',
    messagingSenderId: '980903205715',
    projectId: 'masu-learning-app-a4974',
    storageBucket: 'masu-learning-app-a4974.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBLsVjwsqZINvZbaBtpgeDGeZG1pIJJC3s',
    appId: '1:980903205715:ios:837fd13f8592ea24be5fa6',
    messagingSenderId: '980903205715',
    projectId: 'masu-learning-app-a4974',
    storageBucket: 'masu-learning-app-a4974.firebasestorage.app',
    iosClientId: '980903205715-ios-837fd13f8592ea24be5fa6',
    iosBundleId: 'com.masulearning.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBLsVjwsqZINvZbaBtpgeDGeZG1pIJJC3s',
    appId: '1:980903205715:ios:837fd13f8592ea24be5fa6',
    messagingSenderId: '980903205715',
    projectId: 'masu-learning-app-a4974',
    storageBucket: 'masu-learning-app-a4974.firebasestorage.app',
    iosClientId: '980903205715-ios-837fd13f8592ea24be5fa6',
    iosBundleId: 'com.masulearning.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBLsVjwsqZINvZbaBtpgeDGeZG1pIJJC3s',
    appId: '1:980903205715:web:9f7f0931a1ee1664be5fa6',
    messagingSenderId: '980903205715',
    projectId: 'masu-learning-app-a4974',
    storageBucket: 'masu-learning-app-a4974.firebasestorage.app',
  );
}
