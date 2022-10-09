import 'dart:developer';

import 'package:absensi_ypsim/models/api-response.dart';
import 'package:absensi_ypsim/utils/interceptors/dio-interceptor.dart';
import 'package:absensi_ypsim/utils/services/shared-service.dart';
import 'package:absensi_ypsim/widgets/spinner.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class LocationBloc {
  late LocationSettings _locationSettings;
  late Position _currentPos;
  bool? serviceEnabled;
  LocationPermission? permission;
  Spinner sp = Spinner();
  BehaviorSubject<bool> _locationLoading = BehaviorSubject.seeded(false);
  BehaviorSubject<Map<String, dynamic>> _targetLocation = BehaviorSubject.seeded({});
  double x2 = 0;
  double y2 = 0;

  LocationBloc._();
  static final _instance = LocationBloc._();
  factory LocationBloc() {
    return _instance; // singleton service
  }

  void init() {
    _locationLoading = BehaviorSubject.seeded(false);
    _targetLocation = BehaviorSubject.seeded({});
  }

  void updatePosition(Position pos) {
    _currentPos = pos;
  }
  
  void dispose() {
    _locationLoading.close();
    _targetLocation.close();
  }

  Stream<Map<String, dynamic>> get targetLocation$ => _targetLocation.asBroadcastStream();
  Map<String, dynamic> get getTargetLocation => _targetLocation.value;
  Position get getCurrentPosition => _currentPos;
  Stream<bool> get locationLoading$ => _locationLoading.stream.asBroadcastStream();
  bool get isLoading => _locationLoading.value;
  Future<bool> get isLocationOn => Geolocator.isLocationServiceEnabled();
  Stream<Position> get positionStream$ => Geolocator.getPositionStream(locationSettings: _locationSettings);
  Stream<ServiceStatus> get serviceStatusStream$ => Geolocator.getServiceStatusStream();

  /// start - Location Service
  void initLocation() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        // forceLocationManager: true,
        intervalDuration: const Duration(seconds: 8),
        //(Optional) Set foreground notification config to keep the app alive 
        //when going to the background
        // foregroundNotificationConfig: const ForegroundNotificationConfig(
        //     notificationText:
        //     "Absensi YPSIM is running in background",
        //     notificationTitle: "Running in Background",
        //     enableWakeLock: true,
        // )
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      _locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 50,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
        _locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      );
    }

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled!) {
      permission = await Geolocator.requestPermission();
      await Geolocator.openLocationSettings();
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Geolocator.openAppSettings();
      // return Future.error(
      //   'Location permissions are permanently denied, we cannot request permissions.');
    } 

  }

  void updateLoadingStatus(bool value) {
    _locationLoading.sink.add(value);
  }

  Future<Position> get getPosition async {
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled!) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        Geolocator.openLocationSettings();
        // return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Geolocator.openAppSettings();
      // return Future.error(
      //   'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try{
      _currentPos = await Geolocator.getCurrentPosition();
    } catch(e) {

    }
    return _currentPos;
  }
  // end - Location Service

  bool isInValidLocation(double x1, double y1, double x2, double y2, double radius) { // 
    return Geolocator.distanceBetween(x1, y1, x2, y2) <= radius; // return distance in meter
  }

  Future<Map<String, dynamic>> getValidLocation(BuildContext context) async {
    // sp.show();
    try {
      ApiResponse response = ApiResponse.fromJson((await this._getValidLocation()).data);
      Map<String, dynamic> result = response.Result;
      _targetLocation.sink.add(result);
      // sp.hide();
      return result;
    } catch (e) {
      // sp.hide();
      handleError(e);;
      return {};
    }
  }

  Future<Response> _getValidLocation() {
    return DioClient().dio.get('/get-validation-location',
      options: Options(
        headers: {
          'RequireToken': ''
        }
      )
    );
  }
}