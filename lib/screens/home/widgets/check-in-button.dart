import 'dart:async';
import 'dart:ffi';

import 'package:SIMAt/screens/home/bloc/check-in-bloc.dart';
import 'package:SIMAt/screens/home/bloc/location-bloc.dart';
import 'package:SIMAt/screens/home/camera.dart';
import 'package:SIMAt/screens/home/home.dart';
import 'package:SIMAt/utils/constants/Theme.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../bloc/home-bloc.dart';

final CheckInBloc checkInBloc = CheckInBloc();
final HomeBloc homeBloc = HomeBloc();

class CheckInButtonContainer extends StatefulWidget {
  CheckInButtonContainer({Key? key}) : super(key: key);
  @override
  State<CheckInButtonContainer> createState() => _CheckInButtonContainer();
}

class _CheckInButtonContainer extends State<CheckInButtonContainer> {
  late StreamSubscription s;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isCheckout(Map<String, dynamic>? attendanceStatus) {
    if (attendanceStatus == null) return false;
    return attendanceStatus['personal_calender']?['check_in'] != null &&
        attendanceStatus['personal_calender']?['check_out'] == null;
  }

  bool _isHoliday(Map<String, dynamic>? data) {
    if (data == null) return false;
    return data['is_holiday'] ?? false;
  }

  bool _isTimeValid(Map<String, dynamic>? data, String current) {
    if (data == null) return false;
    String date = data['personal_calender']['date'];
    Map<String, dynamic>? settings = data['time_settings'];
    // handle jika settings null
    if (settings == null) return false;
    if (data['personal_calender']['check_in'] != null &&
        data['personal_calender']['check_out'] != null) return false;

    late String start;
    late String end;

    // cek apakah hari sabtu
    bool isSaturday =
        DateFormat('EEEE').format(DateTime.parse(date)) == 'Saturday';
    if (_isCheckout(data)) {
      start = isSaturday
          ? settings['saturday_check_out_start']
          : settings['check_out_start'];
      end = isSaturday
          ? settings['saturday_check_out_end']
          : settings['check_out_end'];
    } else {
      start = isSaturday
          ? settings['saturday_check_in_start']
          : settings['check_in_start'];
      end = isSaturday
          ? settings['saturday_check_in_end']
          : settings['check_in_end'];
    }
    DateTime _start = DateTime.parse("${date}T${start}");
    DateTime _end = DateTime.parse("${date}T${end}");
    DateTime _curr = DateTime.parse("${date}T${current}");
    return !(_curr.isBefore(_start) || _curr.isAfter(_end));
  }

  bool _disabled(dynamic status, Position? pos) {
    return status == null ||
        (pos == null && !kIsWeb) ||
        status == ServiceStatus.disabled;
  }

  Widget _webWidget() {
    return StreamBuilder(
      stream: LocationBloc.positionStatus$,
      builder:
          (BuildContext context, AsyncSnapshot<Position?> positionSnapshot) {
        if (!positionSnapshot.hasData || positionSnapshot.data == null) {
          return CheckInButton(
            disabled: true,
            isCheckout: false,
          );
        }

        return StreamBuilder(
          stream: CombineLatestStream.list([
            homeBloc.attendanceStatus$,
            LocationBloc.targetLocation$,
          ]),
          builder: (BuildContext context,
              AsyncSnapshot<List<dynamic>> locationSnapshot) {
            bool attendanceIsValid =
                locationSnapshot.data?[0]['personal_calender'] != null;
            bool targetLocationIsValid = locationSnapshot.data?[1] != null;

            if (!locationSnapshot.hasData ||
                !attendanceIsValid ||
                !targetLocationIsValid) {
              return CheckInButton(
                  disabled: true,
                  isCheckout: _isCheckout(locationSnapshot.data?[0]));
            }

            return StreamBuilder(
              stream: timeBloc.count$,
              builder: (BuildContext context, AsyncSnapshot<String> time) {
                if (!time.hasData || time.data == null) {
                  return CheckInButton(disabled: true, isCheckout: false);
                }
                return CheckInButton(
                    disabled:
                        !_isTimeValid(locationSnapshot.data![0], time.data!) ||
                            !LocationBloc.isInValidLocation() ||
                            positionSnapshot.data!.isMocked ||
                            _isHoliday(locationSnapshot.data![0]),
                    isCheckout: _isCheckout(locationSnapshot.data?[0]));
              },
            );
          },
        );
      },
    );
  }

  Widget _androidWidgets() {
    return StreamBuilder(
      stream: LocationBloc.serviceStatus$,
      builder: (BuildContext context,
          AsyncSnapshot<ServiceStatus> serviceStatusSnapshot) {
        if (!serviceStatusSnapshot.hasData ||
            serviceStatusSnapshot.data == ServiceStatus.disabled) {
          return CheckInButton(
            disabled: true,
            isCheckout: false,
          );
        }

        return StreamBuilder(
          stream: LocationBloc.positionStatus$,
          builder: (BuildContext context,
              AsyncSnapshot<Position?> positionSnapshot) {
            if (!positionSnapshot.hasData || positionSnapshot.data == null) {
              return CheckInButton(
                disabled: true,
                isCheckout: false,
              );
            }

            return StreamBuilder(
              stream: CombineLatestStream.list([
                homeBloc.attendanceStatus$,
                LocationBloc.targetLocation$,
              ]),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> locationSnapshot) {
                bool attendanceIsValid =
                    locationSnapshot.data?[0]['personal_calender'] != null;
                bool targetLocationIsValid = locationSnapshot.data?[1] != null;

                if (!locationSnapshot.hasData ||
                    !attendanceIsValid ||
                    !targetLocationIsValid) {
                  return CheckInButton(
                      disabled: true,
                      isCheckout: _isCheckout(locationSnapshot.data?[0]));
                }

                return StreamBuilder(
                  stream: timeBloc.count$,
                  builder: (BuildContext context, AsyncSnapshot<String> time) {
                    if (!time.hasData || time.data == null) {
                      return CheckInButton(disabled: true, isCheckout: false);
                    }
                    return CheckInButton(
                        disabled: !_isTimeValid(
                                locationSnapshot.data![0], time.data!) ||
                            !LocationBloc.isInValidLocation() ||
                            positionSnapshot.data!.isMocked ||
                            _isHoliday(locationSnapshot.data![0]),
                        isCheckout: _isCheckout(locationSnapshot.data?[0]));
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? _webWidget() : _androidWidgets();
  }
}

class CheckInButton extends StatefulWidget {
  final bool disabled;
  final bool isCheckout;
  const CheckInButton(
      {Key? key, required this.disabled, required this.isCheckout})
      : super(key: key);

  @override
  _CheckInButton createState() => _CheckInButton();
}

class _CheckInButton extends State<CheckInButton> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: (widget.disabled)
              ? Colors.grey
              : widget.isCheckout
                  ? MaterialColors.bgPrimary
                  : Colors.green,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(80)),
      child: Text(
        widget.isCheckout ? "Check Out" : "Check In",
        style: TextStyle(
            fontSize: 20,
            color: widget.isCheckout ? Colors.black : Colors.white),
      ),
      onPressed: () async {
        if (!widget.disabled) {
          CameraDescription camera = (await availableCameras()).firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front);
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => CameraPage(camera: camera)));
          if (cameraBloc.imageFile != null) {
            widget.isCheckout
                ? await homeBloc.checkOut(
                    context: context,
                    pos: LocationBloc.position!,
                    dateTime: "${timeBloc.currentDate} ${timeBloc.currentTime}",
                    photo: cameraBloc.imageFile!)
                : await homeBloc.checkIn(
                    context: context,
                    pos: LocationBloc.position!,
                    dateTime: "${timeBloc.currentDate} ${timeBloc.currentTime}",
                    photo: cameraBloc.imageFile!);
            cameraBloc.reset();
            homeBloc.triggerReload();
          }
        }
      },
    );
  }
}
