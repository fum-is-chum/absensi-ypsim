import 'package:absensi_ypsim/models/api-response.dart';
import 'package:absensi_ypsim/utils/interceptors/dio-interceptor.dart';
import 'package:absensi_ypsim/utils/services/shared-service.dart';
import 'package:absensi_ypsim/widgets/spinner.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class LocationBloc {
  late LocationSettings _locationSettings;
  Position? _currentPos;
  bool? serviceEnabled;
  LocationPermission? permission;
  Spinner sp = Spinner();
  BehaviorSubject<bool> _locationLoading = BehaviorSubject.seeded(false);
  BehaviorSubject<Map<String, dynamic>> _targetLocation = BehaviorSubject.seeded({});
  BehaviorSubject<bool> _fetchingPosition = BehaviorSubject.seeded(false);

  LocationBloc._();
  static final _instance = LocationBloc._();
  factory LocationBloc() {
    return _instance; // singleton service
  }

  void updatePosition(Position pos) {
    _currentPos = pos;
  }

  Map<String, dynamic> get getTargetLocation => _targetLocation.value;
  Position? get getCurrentPosition => _currentPos;
  bool get isLoading => _locationLoading.value;

  Future<bool> get isLocationOn => Geolocator.isLocationServiceEnabled();
  Future<Position?> get lastKnownPosition => Geolocator.getLastKnownPosition();

  Stream<bool> get fetchingPostion$ => _fetchingPosition.asBroadcastStream();
  Stream<bool> get locationLoading$ => _locationLoading.asBroadcastStream();
  Stream<Map<String, dynamic>> get targetLocation$ => _targetLocation.asBroadcastStream();
  Stream<Position> get positionStream$ => Geolocator.getPositionStream(locationSettings: _locationSettings);
  Stream<ServiceStatus> get serviceStatusStream$ => Geolocator.getServiceStatusStream().asBroadcastStream();

  /// start - Location Service
  void initLocation() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
        // forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        //(Optional) Set foreground notification config to keep the app alive 
        //when going to the background
        foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText: "SimLog is running in background",
            notificationTitle: "SimLog",
            enableWakeLock: true,
        )
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      _locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
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

  Future<Position?> get getPosition async {
    if(_fetchingPosition.value) return null;
    print('A');
    _fetchingPosition.sink.add(true);
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
    _fetchingPosition.sink.add(false);
    // print('B');
    return _currentPos;
  }
  // end - Location Service

  int get getDistance {
    if(_currentPos == null || getTargetLocation['latitude'] == null) 
      return 0;
    double x1 = _currentPos!.latitude; 
    double y1 = _currentPos!.longitude;
    double x2 = getTargetLocation['latitude'];
    double y2 = getTargetLocation['longitude'];
    int radius = getTargetLocation['radius'];
    
    int distance = Geolocator.distanceBetween(x1, y1, x2, y2).round() - radius;
    return distance >= 0 ? distance : 0;
  } 

  bool isInValidLocation() { // 
    if(_currentPos == null || getTargetLocation['latitude'] == null) 
      return false;
    double x1 = _currentPos!.latitude;
    double y1 = _currentPos!.longitude;
    double x2 = getTargetLocation['latitude'];
    double y2 = getTargetLocation['longitude'];
    int radius = getTargetLocation['radius'];

    return Geolocator.distanceBetween(x1, y1, x2, y2).round() <= radius; // return distance in meter
  }

  /*
    data = [
      isLocationOn -> bool,
      getPosition -> Position,
      getValidLocation -> Map<String, dynamic>
    ]
  */
  int mapViewValid(List<dynamic>? data) {
    if(data == null) return 0;
    if(data[0] == false) return -1;
    if((data[1] as Position?)?.latitude == null) return -2;
    if((data[2] as Map<String, dynamic>?)?['latitude'] == null) return -3;
    return 1;
    // return
    //   data[0] == true &&
    //   (data[1] as Position?)?.latitude != null &&
    //   (data[2] as Map<String, dynamic>?)?['latitude'] != null
    // ;

  }
  Future<Map<String, dynamic>> getValidLocation() async {
    // sp.show();
    try {
      _targetLocation.sink.add({});
      ApiResponse response = ApiResponse.fromJson((await this._getValidLocation()).data);
      Map<String, dynamic> result = response.Result;

      _targetLocation.sink.add(result);
      // sp.hide();
      return result;
    } catch (e) {
      // sp.hide();
      handleError(e);
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