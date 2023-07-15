import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:mustard_kitchen/controller/home_controller.dart';

import '../services/navigation_service.dart';
import 'screens/notification_page.dart';
import '../globals.dart' as globals;

//From Flutter Local Notification
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  log('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    log('notification action tapped with input: ${notificationResponse.input}');
  }
}

//Local Notification
FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
//Firebase Messaging
FirebaseMessaging messaging = FirebaseMessaging.instance;

class NewNotificationService {
  NewNotificationService._();
  AndroidInitializationSettings androidInitializationSettings =
      const AndroidInitializationSettings('@mipmap/launcher_icon');
  DarwinInitializationSettings? iosSettings =
      const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestSoundPermission: true,
    requestBadgePermission: true,
    defaultPresentBadge: true,
    requestCriticalPermission: true,
  );

  static void requestNotiPermission() async {
    bool? granted = false;

    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosNotificationsPlugin =
          notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      granted = await iosNotificationsPlugin?.requestPermissions();
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      granted = await androidImplementation?.requestPermission();
      log("Notification is granted: $granted");
    }

    NewNotificationService.getFcmToken();
  }

  static void initializeNotification() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestSoundPermission: true,
        requestBadgePermission: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        requestCriticalPermission: true,
      ),
    );
    bool? initialized = await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      onDidReceiveNotificationResponse: (notificationResponse) async {
        final String? payload = notificationResponse.payload;
        if (notificationResponse.payload != null) {
          debugPrint("Notification Payload: $payload");
          log(payload!);
          Navigator.of(NavigationService.context)
              .pushReplacement(MaterialPageRoute(
                  builder: (context) => ShowNotification(
                        notificationUrl: payload,
                      )));
        }
      },
    );
    log("Notifications Initialization: $initialized");
  }

  static void createAndDisplaynotification(RemoteMessage message) async {
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'mustardkitchen',
      'mustardkitchenNotification',
      icon: '@mipmap/launcher_icon',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );
    DarwinNotificationDetails iOSNotificationDetails =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = NotificationDetails(
          android: androidDetails, iOS: iOSNotificationDetails);
      await notificationsPlugin.show(
        id, // message.data['id'],
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data["click_action"],
        // payload: message.notification!.android!.clickAction,
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  static Future<void> getFcmToken() async {
    String? fcmToken;
    //instance Firebase Messaging;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log("Notification Permission is Accessed");
      if (Platform.isIOS) {
        String? apnsToken = await messaging.getAPNSToken();
        log("The APNS TOken is: $apnsToken");
      }
      fcmToken = await messaging.getToken(); // will be applied try and catch

      log("The token is :${fcmToken!}");
      globals.url = fcmToken;
    }
    if (fcmToken != null) {
      HomeController homeController = Get.put(HomeController());

      if (Platform.isAndroid) {
        homeController.url.value =
            'https://apps.mustardindian.com/?platform=android&token=$fcmToken';
      } else if (Platform.isIOS) {
        homeController.url.value =
            'https://apps.mustardindian.com/?platform=ios&token=$fcmToken';
      }
      log('run with permission');
    } else {
      HomeController homeController = Get.put(HomeController());
      homeController.url.value = 'https://apps.mustardindian.com';
      log('run without permission');
    }
  }
}
