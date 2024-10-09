import 'dart:async';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter/material.dart';
import 'package:overlay/database/database_service.dart';
import 'package:overlay/overlay_permissions/permissions_granted.dart';
import 'package:usage_stats/usage_stats.dart';

class PermissionsScreen extends StatefulWidget {
  DatabaseService dbService;
  PermissionsScreen(this.dbService, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _PermissionsScreenState();
  }
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool usagePermissionGranted = false;
  bool drawOverOtherAppsPermissionGranted = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      usagePermissionGranted = (await UsageStats.checkUsagePermission())!;
      drawOverOtherAppsPermissionGranted =
          await FlutterOverlayWindow.isPermissionGranted();
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF055b49),
          title: const Text('Permissions Required'),
          foregroundColor: Colors.white,
        ),
        backgroundColor: const Color(0xFFFFF6E7),
        body: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.03,
            ),
            // CircleAvatar(
            //     backgroundColor: const Color(0xFF055b49),
            //     radius: screenWidth * 0.09,
            //     child: Icon(
            //       Icons.approval_rounded,
            //       size: screenWidth * 0.13,
            //       color: Colors.white,
            //     )),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 12),
              child: Text(
                          "For a seamless shopping experience across apps like Blinkit, Zepto and more...",
                          style: TextStyle(
                            fontSize: screenWidth * 0.066,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
            ),
            SizedBox(
              height: screenHeight * 0.025,
            ),
            _aboutPermissionsSection(),
            SizedBox(
              height: screenHeight * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _usagePermissionWidget(),
                SizedBox(
                  width: screenWidth * 0.07,
                ),
                _overlayWidgetPermissionWidget(),
              ],
            ),
            SizedBox(
              height: screenHeight * 0.06,
            ),
            drawOverOtherAppsPermissionGranted && usagePermissionGranted
                ? _continueToAppButton()
                : const SizedBox.shrink(),
            SizedBox(
              height: screenHeight * 0.02,
            )
          ],
        ));
  }

  Widget _aboutPermissionsSection() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        height: screenHeight * 0.32,
        width: screenWidth * 0.9,
        child: Card(
          color: Colors.white,
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Row(
                children: [
                  SizedBox(
                    width: screenWidth * 0.05,
                  ),
                  Icon(
                    Icons.query_stats,
                    size: screenWidth * 0.15,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: screenWidth * 0.04,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Usage Access",
                        style: TextStyle(
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: screenWidth * 0.6), // Limit the width
                          child: Text(
                            "Enables the app to activate overlay features based on your app usage.",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontStyle: FontStyle.italic,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Row(
                children: [
                  SizedBox(
                    width: screenWidth * 0.05,
                  ),
                  Icon(
                    Icons.timer,
                    size: screenWidth * 0.15,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: screenWidth * 0.04,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Display Over Apps",
                        style: TextStyle(
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: screenWidth * 0.6), // Limit the width
                          child: Text(
                            "Allows us to display helpful overlays while you use other apps.",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontStyle: FontStyle.italic,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _continueToAppButton() {
    final double screenWidth = MediaQuery.of(context).size.width;

    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(
          vertical: 15, horizontal: 30), // Adjust padding as needed
      onPressed: (drawOverOtherAppsPermissionGranted && usagePermissionGranted)
          ? () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      PermissionsGranted(widget.dbService)))
          : null,
      color: const Color(0xFF055b49),
      disabledColor: Colors.grey,
      child: Text(
        "Continue to App",
        style: TextStyle(
            fontSize: screenWidth * 0.045,
            color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _usagePermissionWidget() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenHeight * 0.16,
      width: screenWidth * 0.35,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        //color: Colors.blue,
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.query_stats,
                  size: screenWidth * 0.1,
                  color: const Color(0xFF055b49),
                ),
                Text(
                  " : ",
                  style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold),
                ),
                Icon(
                  usagePermissionGranted
                      ? Icons.check_circle_sharp
                      : Icons.close_rounded,
                  color: usagePermissionGranted ? Colors.green : Colors.red,
                  size: screenWidth * 0.1,
                )
              ],
            ),
            SizedBox(
              height: screenHeight * 0.01,
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: const Color(0xFFeaf2e1),
              disabledColor: Colors.grey,
              onPressed: usagePermissionGranted
                  ? null
                  : () async {
                      await _askForUsagePermission();
                      setState(() {});
                    },
              child: Text(
                "Grant",
                style: TextStyle(
                    fontSize: screenWidth * 0.04, color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _overlayWidgetPermissionWidget() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenHeight * 0.16,
      width: screenWidth * 0.35,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer,
                  size: screenWidth * 0.1,
                  color: const Color(0xFF055b49),
                ),
                Text(
                  " : ",
                  style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold),
                ),
                Icon(
                  drawOverOtherAppsPermissionGranted
                      ? Icons.check_circle_sharp
                      : Icons.close_rounded,
                  color: drawOverOtherAppsPermissionGranted
                      ? Colors.green
                      : Colors.red,
                  size: screenWidth * 0.1,
                )
              ],
            ),
            SizedBox(
              height: screenHeight * 0.01,
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: const Color(0xFFeaf2e1),
              disabledColor: Colors.grey,
              onPressed: drawOverOtherAppsPermissionGranted
                  ? null
                  : () async {
                      await _askForDisplayOverWidgetsPermission();
                      setState(() {});
                    },
              child: Text(
                "Grant",
                style: TextStyle(
                    fontSize: screenWidth * 0.04, color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }

  _askForUsagePermission() async {
    UsageStats.grantUsagePermission();
  }

  _askForDisplayOverWidgetsPermission() async {
    bool? overlayPermissionsGranted =
        await FlutterOverlayWindow.requestPermission();
    if (overlayPermissionsGranted != null && !overlayPermissionsGranted) {
      debugPrint("Overlay Permissions not granted!");
    }
  }
}
