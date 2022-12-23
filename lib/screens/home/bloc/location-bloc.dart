import 'dart:async';

import 'package:SIMAt/models/api-response.dart';
import 'package:SIMAt/utils/interceptors/dio-interceptor.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class LocationBloc {
  static StreamSubscription<Position>? positionStreamSubscription;
  static StreamSubscription<ServiceStatus>? serviceStatusStreamSubscription;

  static BehaviorSubject<dynamic> _positionSubject =
      new BehaviorSubject.seeded(null);
  static BehaviorSubject<Map<String, dynamic>> _targetLocation =
      BehaviorSubject.seeded({});
  static BehaviorSubject<ServiceStatus> _serviceStatusSubject =
      new BehaviorSubject.seeded(ServiceStatus.disabled);
  static LocationSettings? _locationSettings;
  static bool positionStreamStarted = false;

  LocationBloc._();
  static final _instance = LocationBloc._();
  factory LocationBloc() {
    return _instance; // singleton service
  }

  static Future<void> init() async {
    _positionSubject = new BehaviorSubject.seeded(null);
    if (_locationSettings == null) setLocationSettings();
    getCurrentPosition().then((value) {
      if (value == null) {
        _updateServiceStatus(ServiceStatus.disabled);
      } else {
        _updateServiceStatus(ServiceStatus.enabled);
      }
      toggleServiceStatusStream(openSettings: value == null);
    });
  }

  static LocationSettings setLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
          // forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText: "SIMAt is running in background",
            notificationTitle: "SIMAt",
            enableWakeLock: true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      _locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.fitness,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      _locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      );
    }
    return _locationSettings!;
  }

  static Stream<ServiceStatus> get serviceStatus$ =>
      _serviceStatusSubject.asBroadcastStream();
  static Stream<dynamic> get positionStatus$ =>
      _positionSubject.asBroadcastStream();
  static Position? get position => _positionSubject.value;
  static Map<String, dynamic> get getTargetLocation => _targetLocation.value;
  static Stream<Map<String, dynamic>> get targetLocation$ =>
      _targetLocation.asBroadcastStream();

  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      _updatePosition(position);
      return position;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> _handlePermission() async {
    bool serviceEnabled;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _openLocationSettings();
      return false;
    } else {
      bool permission;
      permission = await requestPermission();
      return permission;
    }
  }

  static Future<bool> requestPermission() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _openAppSettings();
      return false;
    }
    return true;
  }

  static void _updatePosition(dynamic pos) {
    _positionSubject.sink.add(pos);
  }

  static void _updateServiceStatus(ServiceStatus status) {
    _serviceStatusSubject.sink.add(status);
  }

  static bool _isListening() => !(positionStreamSubscription == null ||
      positionStreamSubscription!.isPaused);

  static void toggleServiceStatusStream({bool openSettings = true}) {
    if (serviceStatusStreamSubscription == null) {
      final serviceStatusStream = Geolocator.getServiceStatusStream();
      serviceStatusStreamSubscription =
          serviceStatusStream.handleError((error) {
        serviceStatusStreamSubscription?.cancel();
        serviceStatusStreamSubscription = null;
        Future.delayed(const Duration(seconds: 1))
            .then((value) => toggleServiceStatusStream());
      }).listen((serviceStatus) {
        if (serviceStatus == ServiceStatus.enabled) {
          positionStreamStarted = positionStreamSubscription == null;
          _updatePosition(-1);
          if (positionStreamStarted) {
            toggleListening();
          } else {
            getCurrentPosition();
          }
        } else {
          if (positionStreamSubscription != null) {
            positionStreamSubscription?.cancel();
            positionStreamSubscription = null;
          }
          _updatePosition(null);
        }
        _updateServiceStatus(serviceStatus);
      });
    }
  }

  static void toggleListening() {
    if (positionStreamSubscription == null) {
      _updatePosition(-1);
      final positionStream =
          Geolocator.getPositionStream(locationSettings: _locationSettings);
      positionStreamSubscription = positionStream.handleError((error) {
        positionStreamSubscription?.cancel();
        positionStreamSubscription = null;
        Future.delayed(const Duration(seconds: 1))
            .then((value) => toggleListening());
      }).listen((pos) {
        _updatePosition(pos);
      });
      // positionStreamSubscription?.pause();
    } else {
      getCurrentPosition();
    }
  }

  static void dispose() {
    if (positionStreamSubscription != null) {
      positionStreamSubscription!.cancel();
      positionStreamSubscription = null;
    }
    // super.dispose();
  }

  static void getLastKnownPosition() async {
    if (kIsWeb) return;
    final position = await Geolocator.getLastKnownPosition();
    if (position != null) {
      _updatePosition(position);
    } else {
      _updatePosition(null);
    }
  }

  void _getLocationAccuracy() async {
    final status = await Geolocator.getLocationAccuracy();
    _handleLocationAccuracyStatus(status);
  }

  void _requestTemporaryFullAccuracy() async {
    final status = await Geolocator.requestTemporaryFullAccuracy(
      purposeKey: "TemporaryPreciseAccuracy",
    );
    _handleLocationAccuracyStatus(status);
  }

  void _handleLocationAccuracyStatus(LocationAccuracyStatus status) {
    String locationAccuracyStatusValue;
    if (status == LocationAccuracyStatus.precise) {
      locationAccuracyStatusValue = 'Precise';
    } else if (status == LocationAccuracyStatus.reduced) {
      locationAccuracyStatusValue = 'Reduced';
    } else {
      locationAccuracyStatusValue = 'Unknown';
    }
  }

  static void _openAppSettings() async {
    if (kIsWeb) return;
    final opened = await Geolocator.openAppSettings();
  }

  static Future<void> _openLocationSettings() async {
    if (kIsWeb) return;
    await Geolocator.openLocationSettings();
    return;
  }
  // end - Location Service

  static int get getDistance {
    if (_positionSubject.value == null ||
        _positionSubject.value == -1 ||
        getTargetLocation['latitude'] == null) return -1;
    double x1 = _positionSubject.value.latitude;
    double y1 = _positionSubject.value.longitude;
    double x2 = getTargetLocation['latitude'];
    double y2 = getTargetLocation['longitude'];
    int radius = getTargetLocation['radius'];

    int distance = Geolocator.distanceBetween(x1, y1, x2, y2).round() - radius;
    return distance >= 0 ? distance : 0;
  }

  static bool isInValidLocation() {
    //
    if (_positionSubject.value == null ||
        _positionSubject.value == -1 ||
        getTargetLocation['latitude'] == null) return false;
    double x1 = _positionSubject.value.latitude;
    double y1 = _positionSubject.value.longitude;
    double x2 = getTargetLocation['latitude'];
    double y2 = getTargetLocation['longitude'];
    int radius = getTargetLocation['radius'];

    return Geolocator.distanceBetween(x1, y1, x2, y2).round() <=
        radius; // return distance in meter
  }

  static Future<Map<String, dynamic>> getValidLocation() async {
    // sp.show();
    try {
      _targetLocation.sink.add({});
      ApiResponse response =
          ApiResponse.fromJson((await _getValidLocation()).data);
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

  static Future<Response> _getValidLocation() {
    return DioClient.dio.get('/get-validation-location',
        options: Options(headers: {'RequireToken': ''}));
  }
}
