import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class LocationBloc {
  LocationBloc._();
  static final _instance = LocationBloc._();
  LocationPermission? _permissionGranted;
  late LocationSettings locationSettings;
  factory LocationBloc() {
    return _instance; // singleton service
  }

  init() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        // distanceFilter: 100,
        // forceLocationManager: true,
        intervalDuration: const Duration(seconds: 8),
        //(Optional) Set foreground notification config to keep the app alive 
        //when going to the background
        foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
            "Absensi YPSIM is running in background",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
        )
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        // distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
        locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        // distanceFilter: 100,
      );
    }

    await checkPermission();
  }

  checkPermission() async {
    if(!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }
    _permissionGranted = await Geolocator.checkPermission();
    if(_permissionGranted == LocationPermission.deniedForever || _permissionGranted == LocationPermission.denied){
      _permissionGranted = await Geolocator.requestPermission();
      if(_permissionGranted == LocationPermission.deniedForever || _permissionGranted == LocationPermission.denied){
        await Geolocator.openAppSettings();
      }
    }
  }
  /*
    serviceStatusStream$
    return: (ServiceStatus status) {
      _name: 'enabled' | 'disabled'
      index: 1 | 0
    }
  */
  Future<Position> get getPosition => Geolocator.getCurrentPosition(timeLimit: Duration(seconds: 20));
  Future<bool> get isLocationOn => Geolocator.isLocationServiceEnabled();
  Stream<Position> get positionStream$ => Geolocator.getPositionStream(locationSettings: locationSettings);
  Stream<ServiceStatus> get serviceStatusStream$ => Geolocator.getServiceStatusStream();
  // Stream<LocationData> get locationStream$ => location.onLocationChanged;
  Stream<dynamic> get locationStream$ => CombineLatestStream.list(
    [
      serviceStatusStream$,
      positionStream$
    ]
  );
}