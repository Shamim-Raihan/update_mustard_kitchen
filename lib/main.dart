import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:mustard_kitchen/screens/home_page.dart';
import 'package:mustard_kitchen/screens/splash_page.dart';
import 'package:mustard_kitchen/update_notification_service.dart';

import 'firebase_option.dart';
import 'screens/notification_page.dart';
import 'services/navigation_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  log("Handling a background message: ${message.messageId}");
  log("Handling a background message: ${message.notification!.title}");
  log('link: ${message.data['body']}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NewNotificationService.requestNotiPermission();
  NewNotificationService.initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void registerNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        log("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          log("New Notification");
          Future.delayed(Duration(seconds: 4), () {
                      Navigator.pushReplacement(
              NavigationService.context,
              MaterialPageRoute(
                  builder: (context) =>
                      ShowNotification(notificationUrl: message.data['click_action'])));
    });
          // Navigator.of(NavigationService.context).pop();
          // Navigator.pushReplacement(NavigationService.context, MaterialPageRoute(builder: (context)=>ShowNotification(notificationUrl: message.notification!.body.toString())));
          // Navigator.pushReplacement(
          //     NavigationService.context,
          //     MaterialPageRoute(
          //         builder: (context) =>
          //             ShowNotification(notificationUrl: message.data['click_action'])));
          // if (message.data['id'] != null) {
          //   log("Firebase Message : Go to new page");
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => ShowNotification(
          //         notificationUrl: '',
          //       ),
          //     ),
          //   );
          //   log('clicked on notification');
          //   Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          //     return ShowNotification(
          //       notificationUrl: '',
          //     );
          //   }));
          // }
        }
      },
    );

    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        log("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          log(message.notification!.title.toString());
          log(message.notification!.body.toString());
          log("message.data11 ${message.data}");
          log("message.data11 ${message.notification!.android!.clickAction}");
          // log('noti fication : '+message.notification!['click_action']);
          NewNotificationService.createAndDisplaynotification(message);
        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        log("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          // log(message.notification!.title.toString());
          // log(message.notification!.body.toString());
          // log("message.data22 ${message.data['id']}");
          // log('mini');
          // log(message.toString());

          Navigator.of(NavigationService.context).pop();
          // Navigator.of(NavigationService.context).push(MaterialPageRoute(
          //     builder: (context) => ShowNotification(
          //           notificationUrl: message.notification!.body.toString(),
          //         )));
          log(message.data['body']);
          Navigator.of(NavigationService.context).push(MaterialPageRoute(
            builder: (context) => ShowNotification(
                  notificationUrl: message.data['click_action'],
                )));
        }
      },
    );

    if (Platform.isIOS) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  @override
  void initState() {
    registerNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mustard Indian',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: NavigationService.navigatorKey,
      // home: const HomePage(),
      home: SplashScreen(),
    );
  }
}
