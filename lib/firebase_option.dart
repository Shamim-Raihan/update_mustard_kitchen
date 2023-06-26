import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('DefaultFirebase option has not been configured'
          'configure firebase cli again.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError('No mac platform');
      case TargetPlatform.windows:
        throw UnsupportedError('sdfdsfsdf');
      case TargetPlatform.linux:
        throw UnsupportedError('sdfsdfsdfdf');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4jggEe5HBpMohIGJJx_Wlb461nryXwpI',
    appId: '1:868144413836:android:11a859acb910e67b0fcfa9',
    messagingSenderId: '868144413836',
    projectId: 'mustard-indian-kitchen-681a9',
  );
  static const FirebaseOptions ios = FirebaseOptions(
      apiKey: 'AIzaSyCS-A_J8PppGIOAemBjT-NYp3a-HIUsO3U',
      appId: '1:868144413836:ios:b1aa7e7031ce2c3c0fcfa9',
      messagingSenderId: '868144413836',
      projectId: 'mustard-indian-kitchen-681a9');
}
