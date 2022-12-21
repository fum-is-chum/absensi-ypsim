import 'dart:async';

import 'package:SIMAt/screens/test.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class TestBloc {
  static StreamSubscription<Position>? positionStreamSubscription;
  static StreamSubscription<ServiceStatus>? serviceStatusStreamSubscription;

  static late BehaviorSubject<dynamic> _positionSubject;
  static BehaviorSubject<ServiceStatus> _serviceStatusSubject = new BehaviorSubject.seeded(ServiceStatus.disabled);
  static bool positionStreamStarted = false;

  TestBloc._();
  static final _instance = TestBloc._();
  factory TestBloc() {
    return _instance; // singleton service
  }


  static void init() {
    _positionSubject = new BehaviorSubject.seeded(null);
    getCurrentPosition().then((value) {
      try { 
        if(value == null) throw 'Null';
        _updateServiceStatus(ServiceStatus.enabled);
      } catch (e) {
        _updateServiceStatus(ServiceStatus.disabled);
      }
      toggleServiceStatusStream();
    });
  }

  static Stream<ServiceStatus> get serviceStatus$ => _serviceStatusSubject.asBroadcastStream();
  static Stream<dynamic> get positionStatus$ => _positionSubject.asBroadcastStream();
  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition();
    _updatePosition(
      position
    );
    return position;
  }

  static Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // _updatePosition(
      //   _PositionItemType.log,
      //   _kLocationServicesDisabledMessage,
      // );

      return false;
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
        // _updatePosition(
        //   _PositionItemType.log,
        //   _kPermissionDeniedMessage,
        // );

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      // _updatePosition(
      //   _PositionItemType.log,
      //   _kPermissionDeniedForeverMessage,
      // );

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // _updatePosition(
    //   _PositionItemType.log,
    //   _kPermissionGrantedMessage,
    // );
    return true;
  }

  static void _updatePosition(dynamic pos) {
    _positionSubject.sink.add(pos);
    // _positionItems.add(_PositionItem(type, displayValue));
    // setState(() {});
  }

  static void _updateServiceStatus(ServiceStatus status) {
    _serviceStatusSubject.sink.add(status);
    // _positionItems.add(_PositionItem(type, displayValue));
    // setState(() {});
  }

  static bool _isListening() => !(positionStreamSubscription == null ||
      positionStreamSubscription!.isPaused);

  static Color determineButtonColor() {
    return _isListening() ? Colors.green : Colors.red;
  }

  static void toggleServiceStatusStream() {
    if (serviceStatusStreamSubscription == null) {
      _openLocationSettings();
      final serviceStatusStream = Geolocator.getServiceStatusStream();
      serviceStatusStreamSubscription =
          serviceStatusStream.handleError((error) {
        serviceStatusStreamSubscription?.cancel();
        serviceStatusStreamSubscription = null;
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
          // if(serviceStatusStreamSubscription == null) _openLocationSettings();
        }
        _updateServiceStatus(
          serviceStatus
        );
      });
    }
  }

  static void toggleListening() {
    if (positionStreamSubscription == null) {
      _updatePosition(-1);
      final positionStream = Geolocator.getPositionStream();
      positionStreamSubscription = positionStream.handleError((error) {
        positionStreamSubscription?.cancel();
        positionStreamSubscription = null;
      }).listen((pos) => _updatePosition(pos));
      // positionStreamSubscription?.pause();
    } else {
      getCurrentPosition();
    }
    // setState(() {
    //   if (_positionStreamSubscription == null) {
    //     return;
    //   }

    //   String statusDisplayValue;
    //   if (_positionStreamSubscription!.isPaused) {
    //     _positionStreamSubscription!.resume();
    //     statusDisplayValue = 'resumed';
    //   } else {
    //     _positionStreamSubscription!.pause();
    //     statusDisplayValue = 'paused';
    //   }

    //   _updatePosition(
    //     _PositionItemType.log,
    //     'Listening for position updates $statusDisplayValue',
    //   );
    // });
  }

  static void dispose() {
    if (positionStreamSubscription != null) {
      positionStreamSubscription!.cancel();
      positionStreamSubscription = null;
    }
    // super.dispose();
  }

  static void getLastKnownPosition() async {
    final position = await Geolocator.getLastKnownPosition();
    if (position != null) {
      _updatePosition(
        position
      );
    } else {
      _updatePosition(
        null
      );
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
    // _updatePosition(
    //   _PositionItemType.log,
    //   '$locationAccuracyStatusValue location accuracy granted.',
    // );
  }

  void _openAppSettings() async {
    final opened = await Geolocator.openAppSettings();
    String displayValue;

    if (opened) {
      displayValue = 'Opened Application Settings.';
    } else {
      displayValue = 'Error opening Application Settings.';
    }

    // _updatePosition(
    //   _PositionItemType.log,
    //   displayValue,
    // );
  }

  static void _openLocationSettings() async {
    final opened = await Geolocator.openLocationSettings();
    String displayValue;

    if (opened) {
      displayValue = 'Opened Location Settings';
    } else {
      displayValue = 'Error opening Location Settings';
    }

    // _updatePosition(
    //   _PositionItemType.log,
    //   displayValue,
    // );
  }
}