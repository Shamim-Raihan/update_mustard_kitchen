import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../globals.dart' as globals;

class ShowNotification extends StatefulWidget {
  String notificationUrl;
  ShowNotification({Key? key, required this.notificationUrl}) : super(key: key);

  @override
  State<ShowNotification> createState() => _ShowNotificationState();
}

class _ShowNotificationState extends State<ShowNotification> {
  @override
  void initState() {
    log('noti : ${widget.notificationUrl}');
    globals.weblink = widget.notificationUrl;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x001a1a1a))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(globals.weblink));
    Connectivity connectivity = Connectivity();
    return WillPopScope(
        onWillPop: () async {
          if (await controller.canGoBack()) {
            controller.goBack();
            return false;
          } else {
            return true;
          }
        },
        child: SafeArea(
          child: Scaffold(
            body: StreamBuilder(
              stream: connectivity.onConnectivityChanged,
              builder: (_, snapshot) {
                return snapshot.connectionState == ConnectionState.active
                    ? snapshot.data != ConnectivityResult.none
                        ? WebViewWidget(controller: controller)
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.wifi_off_sharp,
                                  size: 45,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('No Data Connection')
                              ],
                            ),
                          )
                    : WebViewWidget(controller: controller);
              },
            ),
          ),
        ));
  }
}
