import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class LocationBloc {
  LocationBloc._();
  static final _instance = LocationBloc._();
  bool? serviceEnabled;
  LocationPermission? permission;
  late LocationSettings _locationSettings;
  late Position currentPos;
  BehaviorSubject<bool> _locationLoading = new BehaviorSubject.seeded(false);
  factory LocationBloc() {
    return _instance; // singleton service
  }

  void dispose() {
    _locationLoading.close();
  }

  Position get curPos => currentPos;
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
      currentPos = await Geolocator.getCurrentPosition();
    } catch(e) {

    }
    return currentPos;
  }
  // end - Location Service

  bool isInValidLocation() { // 
    // Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude); // return distance in meter
    return true;
  }
}