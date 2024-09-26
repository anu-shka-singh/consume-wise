import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:overlay/database/database_service.dart';
import 'package:overlay/dtos/application_data.dart';
import 'package:overlay/monitoring_service/utils/user_usage_utils.dart';
import 'package:usage_stats/usage_stats.dart';



const String STOP_MONITORING_SERVICE_KEY = "stop";
const String SET_APPS_NAME_FOR_MONITORING_KEY = "setAppsNames";
const String APP_NAMES_LIST_KEY = "appNames";

// Entry Point for Monitoring Isolate
@pragma('vm:entry-point')
onMonitoringServiceStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseService databaseService = await DatabaseService.instance();

  Map<String, ApplicationData> monitoredApplicationSet = {};

  // Stop this background service
  _registerListener(service);

  Map<String, UsageInfo> previousUsageSession = await getCurrentUsageStats(monitoredApplicationSet);
  _startTimer(databaseService, monitoredApplicationSet, previousUsageSession);
}

Future<void> _startTimer(DatabaseService databaseService, Map<String, ApplicationData> monitoredApplicationSet, Map<String, UsageInfo> previousUsageSession) async{
  Timer.periodic(const Duration(seconds: 1), (timer) async{
    timer.cancel();
    _setMonitoringApplicationsSet(databaseService, monitoredApplicationSet);
    Map<String, UsageInfo> currentUsageSession = await getCurrentUsageStats(monitoredApplicationSet);
    String? appOpened = checkIfAnyAppHasBeenOpened(currentUsageSession, previousUsageSession, monitoredApplicationSet);
    if(appOpened != null){
      _showDialog();
    }
    previousUsageSession = currentUsageSession;

    _startTimer(databaseService, monitoredApplicationSet, previousUsageSession);
  });
}

_showDialog() async {
    await FlutterOverlayWindow.showOverlay(
      overlayTitle: "", 
      startPosition: OverlayPosition(50, 0),
      flag: OverlayFlag.focusPointer,
      enableDrag: true,
      );
}

_setMonitoringApplicationsSet(DatabaseService databaseService, Map<String, ApplicationData> monitoredApplicationSet){
  List<ApplicationData> monitoredApps = databaseService.getAllAppData();
  monitoredApplicationSet.clear();

  for(ApplicationData app in monitoredApps){
    monitoredApplicationSet[app.appId] = app;
  }
}

_registerListener(ServiceInstance service){
  service.on(STOP_MONITORING_SERVICE_KEY).listen((event) {
    service.stopSelf();
  });
}
