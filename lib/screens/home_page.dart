import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:mustard_kitchen/controller/home_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/constants.dart';
import '../globals.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.put(HomeController());

    return Obx(() {
      if (homeController.url.value == '') {
        return CircularProgressIndicator();
      } else {
        log('url : ' + homeController.url.value);
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
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
          ..loadRequest(Uri.parse(homeController.url.value));
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
    });
  }
}
