
import 'dart:async';
import 'dart:developer';

import 'package:absensi_ypsim/screens/home/bloc/check-in-bloc.dart';
import 'package:absensi_ypsim/screens/home/bloc/location-bloc.dart';
import 'package:absensi_ypsim/screens/home/camera.dart';
import 'package:absensi_ypsim/screens/home/home.dart';
import 'package:absensi_ypsim/utils/constants/Theme.dart';
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

  bool get _disabled {
    return 
      homeBloc.attendanceStatus['personal_calender'] != null &&
      locationBloc.getTargetLocation['latitude'] != null
    ;
  }

  bool _isCheckout(Map<String, dynamic>? attendanceStatus) {
    if(attendanceStatus == null) return false;
    return 
      attendanceStatus['personal_calender']?['check_in'] != null && 
      attendanceStatus['personal_calender']?['check_out'] == null;
  }

  bool _isTimeValid(Map<String, dynamic>? data, String current) {
    if(data == null) return false;
    String date = data['personal_calender']['date'];
    Map<String, dynamic> settings = data['time_settings'];

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


  @override
  Widget build(BuildContext context) {    
    return !kIsWeb ? FutureBuilder(
      future: locationBloc.isLocationOn,
      builder: (BuildContext context, AsyncSnapshot<bool> location) {
        if(!location.hasData) {
          return CheckInButton(disabled: true, isCheckout: false,);
        }
        return StreamBuilder<ServiceStatus>(
          stream: locationBloc.serviceStatusStream$,
          initialData: location.data! ? ServiceStatus.enabled : ServiceStatus.disabled,
          builder: (BuildContext context, AsyncSnapshot<ServiceStatus> service) {
            /// index === 0 => disabled
            // return CheckInButton(disabled: false);
            if((!service.hasData || service.data?.index == 0 || service.data == null)) {
              return CheckInButton(disabled: true, isCheckout: false,);
            }
            return FutureBuilder(
              future: locationBloc.getPosition,
              builder: (BuildContext context, AsyncSnapshot<Position> position) {
                bool positionIsValid = position.hasData && position.data != null;
                if(!positionIsValid) {
                  return CheckInButton(disabled: true, isCheckout: false,);
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
                          disabled: !_isTimeValid(snapshot.data![0], time.data!),
                          isCheckout: _isCheckout(snapshot.data?[0])
                        );
                      },
                    );
                  },
                );
                // return StreamBuilder(
                //   stream: homeBloc.attendanceStatus$,
                //   builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> attendance) {
                //     bool attendanceIsValid = attendance.hasData && attendance.data != null && attendance.data!['personal_calender'] != null;
                    
                //     if(!attendanceIsValid) {
                //       return CheckInButton(disabled: true, isCheckout: false);
                //     }

                //     return StreamBuilder(
                //       stream: locationBloc.targetLocation$,
                //       builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> targetLocation) {
                //         bool targetLocationIsValid = targetLocation.hasData && targetLocation.data != null;
                //         return CheckInButton(
                //           disabled: !targetLocationIsValid || !locationBloc.isInValidLocation(),
                //           isCheckout: _isCheckout(attendance.data!)
                //         );
                //       },
                //     );
                //   }
                // );
              }
            );
          }
        );
      },
    )
    : Container();
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
                pos: locationBloc.getCurrentPosition,
                dateTime: "${timeBloc.currentDate} ${timeBloc.count}",
                photo: cameraBloc.imageFile!
              ) : 
              await homeBloc.checkIn(
                context: context, 
                pos: locationBloc.getCurrentPosition,
                dateTime: "${timeBloc.currentDate} ${timeBloc.count}",
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