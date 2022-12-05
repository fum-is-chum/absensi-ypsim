
import 'dart:async';

import 'package:SIMAt/screens/home/bloc/check-in-bloc.dart';
import 'package:SIMAt/screens/home/bloc/location-bloc.dart';
import 'package:SIMAt/screens/home/camera.dart';
import 'package:SIMAt/screens/home/home.dart';
import 'package:SIMAt/utils/constants/Theme.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

import '../bloc/home-bloc.dart';

final LocationBloc locationBloc = LocationBloc();
final CheckInBloc checkInBloc = CheckInBloc();
final HomeBloc homeBloc = HomeBloc();

class CheckInButtonContainer extends StatefulWidget {
  CheckInButtonContainer({Key? key}): super(key: key);
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
    if(attendanceStatus == null) return false;
    return 
      attendanceStatus['personal_calender']?['check_in'] != null && 
      attendanceStatus['personal_calender']?['check_out'] == null;
  }

  bool _isHoliday(Map<String, dynamic>? data) {
    if(data == null) return false;
    return data['is_holiday'] ?? false;
  }

  bool _isTimeValid(Map<String, dynamic>? data, String current) {
    if(data == null) return false;
    String date = data['personal_calender']['date'];
    Map<String, dynamic>? settings = data['time_settings'];
    // handle jika settings null
    if(settings == null) return false;
    if(data['personal_calender']['check_in'] != null && data['personal_calender']['check_out'] != null) return false;

    late String start;
    late String end;
    if(_isCheckout(data)) {
      start = settings['check_out_start'];
      end = settings['check_out_end'];
    } else {
      start = settings['check_in_start'];
      end = settings['check_in_end'];
    }
    DateTime _start = DateTime.parse("${date}T${start}");
    DateTime _end = DateTime.parse("${date}T${end}");
    DateTime _curr = DateTime.parse("${date}T${current}");
    return !(_curr.isBefore(_start) || _curr.isAfter(_end));
  }

  bool _disabled(dynamic status, Position? pos) {
    return status == null || (pos == null && !kIsWeb) || status == ServiceStatus.disabled;
  }

  Widget _webWidgets() {
    return FutureBuilder(
      future: Future.wait([
        locationBloc.isLocationOn
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> location) {
        if(!location.hasData) {
          return CheckInButton(disabled: true, isCheckout: false,);
        }

        // return CheckInButton(disabled: false, isCheckout: false,);

        
        return StreamBuilder<List<dynamic>>(
          stream: CombineLatestStream.list([
            locationBloc.positionStream$
          ]),
          builder: (BuildContext context, AsyncSnapshot<List<dynamic>> locationStream) {
            if(!locationStream.hasData || _disabled(locationStream.data?[0], null)) {
              return CheckInButton(disabled: true, isCheckout: false);
            }

            return StreamBuilder(
              stream: CombineLatestStream.list([
                homeBloc.attendanceStatus$,
                locationBloc.targetLocation$
              ]),
              builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                bool attendanceIsValid = snapshot.data?[0]['personal_calender'] != null;
                bool targetLocationIsValid = snapshot.data?[1] != null;

                if(!snapshot.hasData || !attendanceIsValid || !targetLocationIsValid) {
                  return CheckInButton(disabled: true, isCheckout: _isCheckout(snapshot.data?[0]));
                }
                
                return StreamBuilder(
                  stream: timeBloc.count$,
                  builder: (BuildContext context, AsyncSnapshot<String> time) {
                    if(!time.hasData || time.data == null) {
                        return CheckInButton(disabled: true, isCheckout: false);
                    }
                    // return CheckInButton(disabled: false, isCheckout: false,);
                    return CheckInButton(
                      disabled: !_isTimeValid(snapshot.data![0], time.data!) || !locationBloc.isInValidLocation() || _isHoliday(snapshot.data![0]),
                      isCheckout: _isCheckout(snapshot.data?[0])
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _androidWidgets() {
    return FutureBuilder(
      future: Future.wait([
        locationBloc.isLocationOn,
        locationBloc.lastKnownPosition
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> location) {
        if(!location.hasData || (location.hasData && !location.data?[0])) {
          return CheckInButton(disabled: true, isCheckout: false,);
        }

        return StreamBuilder<List<dynamic>>(
          stream: CombineLatestStream.list([
            locationBloc.serviceStatusStream$,
            locationBloc.positionStream$
          ]),
          initialData: [
            location.data![0] ? ServiceStatus.enabled : ServiceStatus.disabled,
            location.data?[1]
          ],
          builder: (BuildContext context, AsyncSnapshot<List<dynamic>> locationStream) {
            if(!locationStream.hasData || _disabled(locationStream.data?[0], locationStream.data?[1])) {
              return CheckInButton(disabled: true, isCheckout: false);
            }

            return StreamBuilder(
              stream: CombineLatestStream.list([
                homeBloc.attendanceStatus$,
                locationBloc.targetLocation$,
              ]),
              builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                bool attendanceIsValid = snapshot.data?[0]['personal_calender'] != null;
                bool targetLocationIsValid = snapshot.data?[1] != null;

                if(!snapshot.hasData || !attendanceIsValid || !targetLocationIsValid) {
                  return CheckInButton(disabled: true, isCheckout: _isCheckout(snapshot.data?[0]));
                }
                
                return StreamBuilder(
                  stream: timeBloc.count$,
                  builder: (BuildContext context, AsyncSnapshot<String> time) {
                    if(!time.hasData || time.data == null) {
                        return CheckInButton(disabled: true, isCheckout: false);
                    }
                    return CheckInButton(
                      disabled: !_isTimeValid(snapshot.data![0], time.data!) || !locationBloc.isInValidLocation() || _isHoliday(snapshot.data![0]),
                      isCheckout: _isCheckout(snapshot.data?[0])
                    );
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
    return kIsWeb ? _webWidgets() : _androidWidgets();
  }
}

class CheckInButton extends StatefulWidget {
  final bool disabled;
  final bool isCheckout;
  const CheckInButton({Key? key, required this.disabled, required this.isCheckout}): super(key: key);

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
        primary: (widget.disabled) ? Colors.grey : widget.isCheckout ? MaterialColors.bgPrimary : Colors.green,
        shape: const CircleBorder(), 
        padding: const EdgeInsets.all(80)
      ),
      child: Text(
        widget.isCheckout ? "Check Out" : "Check In",
        style: TextStyle(fontSize: 20, color: widget.isCheckout ? Colors.black : Colors.white),
      ),
      onPressed: () async {
        if(!widget.disabled) await availableCameras().then((value) async  {
          await Navigator.push(
            context, MaterialPageRoute(builder: (_) => CameraPage(cameras: value)
          ));
          if(cameraBloc.imageFile != null) {
            widget.isCheckout ? 
              await homeBloc.checkOut(
                context: context, 
                pos: locationBloc.getCurrentPosition!,
                dateTime: "${timeBloc.currentDate} ${timeBloc.currentTime}",
                photo: cameraBloc.imageFile!
              ) : 
              await homeBloc.checkIn(
                context: context, 
                pos: locationBloc.getCurrentPosition!,
                dateTime: "${timeBloc.currentDate} ${timeBloc.currentTime}",
                photo: cameraBloc.imageFile!
              );
            cameraBloc.reset();
            homeBloc.triggerReload();
          }
        });
      },
    );
  }
}