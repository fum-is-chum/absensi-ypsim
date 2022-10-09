import 'dart:async';
import 'dart:developer';

import 'package:absensi_ypsim/screens/home/bloc/camera-bloc.dart';
import 'package:absensi_ypsim/screens/home/bloc/home-bloc.dart';
import 'package:absensi_ypsim/screens/home/bloc/location-bloc.dart';
import 'package:absensi_ypsim/screens/home/bloc/time-bloc.dart';
import 'package:absensi_ypsim/screens/home/camera.dart';
import 'package:absensi_ypsim/screens/home/location-view.dart';
import 'package:absensi_ypsim/utils/constants/Theme.dart';
import 'package:absensi_ypsim/widgets/card-small.dart';
import 'package:absensi_ypsim/widgets/drawer.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

TimeBloc timeBloc = TimeBloc();
HomeBloc homeBloc = HomeBloc();
CameraBloc cameraBloc = CameraBloc();

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final GlobalKey _scaffoldKey = new GlobalKey();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Future.delayed(Duration(seconds: 1)).then((value) {
      SystemChrome.restoreSystemUIOverlays();
    });
    homeBloc.init();
    timeBloc.init();
    super.initState();
  }

  @override
  void dispose() {
    timeBloc.dispose();
    homeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Keluar dari aplikasi?'),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Tidak'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Ya'),
                ),
              ],
            );
          },
        );
        return shouldPop!;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Home",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        // key: _scaffoldKey,
        drawer: MaterialDrawer(currentPage: "Home"),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30,),
                ImageRow(),
                SizedBox(height: 20),
                CheckIn(),
                FractionalTranslation(
                  translation: Offset(0, -0.5),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CheckInButtonContainer()
                  ),
                ),
                FractionalTranslation(
                  translation: Offset(0, -0.1),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: LocationView(),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}

class ImageRow extends StatefulWidget {
  ImageRow({Key? key}): super(key: key);
  @override
  _ImageRow createState() => _ImageRow();
}

class _ImageRow extends State<ImageRow> {

  @override
  void initState() {
    Rx.merge([
      timeBloc.dateStream$,
      homeBloc.reloadAttendance$
    ]).listen((event) {
      if(timeBloc.currentDate != "") homeBloc.getAttendanceStatus(date: timeBloc.currentDate);
    });
    super.initState();
  }

  @override
  void dispose() {
    // cameraBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: homeBloc.attendanceStatus$,
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CardSmall(
              cta: snapshot.hasData && snapshot.data != null && snapshot.data!['check_in'] != null ? "${snapshot.data!['check_in']} WIB" : '00:00:00 WIB',
              title: "IN",
              img: snapshot.hasData && snapshot.data != null && snapshot.data!['photo_check_in'] != null ? 
                    "https://presensi.ypsimlibrary.com${snapshot.data!['photo_check_in']}" : 'assets/img/no-image.jpg',
              // img: 'assets/img/no-image.jpg',
              tap: () {
                // Navigator.pushReplacementNamed(context, '/pro');
              }
            ),
            SizedBox(width: 8),
            CardSmall(
              cta: snapshot.hasData && snapshot.data != null && snapshot.data!['check_out'] != null ? "${snapshot.data!['check_out']} WIB" : '00:00:00 WIB',
              title: "OUT",
              img: snapshot.hasData && snapshot.data != null && snapshot.data!['photo_check_out'] != null ? 
                  "https://presensi.ypsimlibrary.com${snapshot.data!['photo_check_out']}" : 'assets/img/no-image.jpg',
              // img: 'assets/img/no-image.jpg',
              tap: () {
                // Navigator.pushReplacementNamed(context, '/pro');
              }
            )
          ],
        );
      },
    );
  }
}

class CheckIn extends StatelessWidget {
  const CheckIn({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color:MaterialColors.newPrimary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Waktu saat ini",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  TimerDisplay()
                ],
              ),
            ),
          ),
          Container(
            height: 180,
            child: Stack(
              children: [
              Padding(
                  padding: EdgeInsets.all(12),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: "Tekan tombol ",
                        ),
                        TextSpan(
                          text: "Check In ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "di bawah untuk menyatakan ",
                        ),
                        TextSpan(
                          text: "Waktu Masuk Kerja. ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "Pastikan ",
                        ),
                        TextSpan(
                          text: "Lokasi Anda ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "terdeteksi oleh sistem",
                        ),
                      ],
                    ),
                  ),
                ),
                // FractionalTranslation(
                //   translation: Offset(0, 0.5),
                //   child: Align(
                //     alignment: Alignment.bottomCenter,
                //     child: CheckInButtonContainer()
                //   ),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimerDisplay extends StatefulWidget {
  const TimerDisplay({Key? key}): super(key: key);

  @override
  State<TimerDisplay> createState() => _TimerDisplay();
}

class _TimerDisplay extends State<TimerDisplay> {
  Timer _timer = Timer(Duration(seconds: 10), () {});
  List<int> counts = [];
  // var time = 0;

  @override
  void initState() {
    getTime(context);
    super.initState();
  }

  Future<void> getTime(BuildContext context) async {
    try {
      String result = await timeBloc.getTime(context);
      DateTime dateString = DateTime.parse(result).add(Duration(hours: 7));
      DateFormat formatter = DateFormat('H:mm:ss');
      timeBloc.updateDate(DateFormat("yyyy-MM-dd").format(dateString));
      startTimer(formatter.format(dateString));
    } catch (e) {
      inspect(e);
    }
  }

  void startTimer(String data) {
    counts = data.split(":").map((e) => int.parse(e)).toList();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        setState(() {
          counts[2]++;

          if(counts[2] > 59) {
            counts[2] = 0;
            counts[1]++;
          }

          if(counts[1] > 59) {
            counts[1] = 0;
            counts[0]++;
          }

          if(counts[0] > 23) {
            counts[0] = 0;
          }

          timeBloc.count = "${counts[0] < 10 ? "0" : ""}${counts[0]}:${counts[1] < 10 ? "0" : ""}${counts[1]}:${counts[2] < 10 ? "0" : ""}${counts[2]}";
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      timeBloc.count+" WIB",
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class CheckInButtonContainer extends StatelessWidget {
  CheckInButtonContainer({Key? key}): super(key: key);
  final LocationBloc locationBloc = new LocationBloc();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: locationBloc.isLocationOn,
      builder: (BuildContext context, AsyncSnapshot<bool> location) {
        if(!location.hasData) {
          return CheckInButton(disabled: true, isCheckout: false,);
        }
        return !kIsWeb ? StreamBuilder<ServiceStatus>(
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
                return StreamBuilder(
                  stream: homeBloc.attendanceStatus$,
                  builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> attendance) {
                    if(!attendance.hasData || !position.hasData) {
                      return CheckInButton(disabled: true, isCheckout: false);
                    }

                    return StreamBuilder(
                      stream: locationBloc.targetLocation$,
                      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> targetLocation) {
                        if(!targetLocation.hasData || (targetLocation.hasData && targetLocation.data!['latitude'] == null)) {
                          return CheckInButton(disabled: true, isCheckout: false);
                        }
                        return CheckInButton(
                          disabled: !position.hasData || !attendance.hasData || 
                                    (attendance.data!['check_in'] != null && attendance.data!['check_out'] != null) ||
                                    !locationBloc.isInValidLocation(),
                          isCheckout: attendance.hasData && attendance.data!['check_in'] != null && attendance.data!['check_out'] == null
                        );
                      },
                    );
                  }
                );
              }
            );
          },
        ) : Container();
      },
    );
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
                pos: LocationBloc().getCurrentPosition,
                dateTime: "${timeBloc.currentDate} ${timeBloc.count}",
                photo: cameraBloc.imageFile!
              ) : 
              await homeBloc.checkIn(
                context: context, 
                pos: LocationBloc().getCurrentPosition,
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