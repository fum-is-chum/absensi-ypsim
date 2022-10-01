import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:material_kit_flutter/screens/home/location-view.dart';
import 'bloc/camera-bloc.dart';
import 'bloc/home-bloc.dart';
import 'bloc/location-bloc.dart';
import 'bloc/time-bloc.dart';
import 'package:material_kit_flutter/utils/constants/Theme.dart';
import 'camera.dart';
import 'package:material_kit_flutter/widgets/card-small.dart';
import 'package:material_kit_flutter/widgets/drawer.dart';
import 'package:flutter/foundation.dart';

final Map<String, Map<String, String>> homeCards = {
  "Makeup": {
    "title": "Find the cheapest deals on our range...",
    "image":
        "https://images.unsplash.com/photo-1515709980177-7a7d628c09ba?crop=entropy&w=840&h=840&fit=crop",
    "price": "220"
  },
};

late TimeBloc timeBloc;
late HomeBloc homeBloc;
late CameraBloc cameraBloc;

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

    homeBloc = HomeBloc();
    timeBloc = TimeBloc();
    cameraBloc = CameraBloc();
    super.initState();
  }

  @override
  void dispose() {
    timeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ));
  }
}

class ImageRow extends StatefulWidget {
  ImageRow({Key? key}): super(key: key);
  @override
  _ImageRow createState() => _ImageRow();
}

class _ImageRow extends State<ImageRow> {

  @override
  void dispose() {
    // cameraBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: cameraBloc.imageStream,
      builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CardSmall(
              // cta: cameraBloc.snapTime != '' && !homeBloc.statusAbsensi() ? cameraBloc.snapTime : "07:01:12 WIB",
              cta: '00:00:00 WIB',
              title: "IN",
              // img: snapshot.hasData && snapshot.data != null && !homeBloc.statusAbsensi() ? snapshot.data :homeCards["Makeup"]!['image'],
              img: homeCards["Makeup"]!['image'],
              tap: () {
                // Navigator.pushReplacementNamed(context, '/pro');
              }
            ),
            SizedBox(width: 8),
            CardSmall(
              // cta: cameraBloc.snapTime != '' && homeBloc.statusAbsensi() ? cameraBloc.snapTime : "16:01:12 WIB",
              cta: '00:00:00 WIB',
              title: "OUT",
              // img: snapshot.hasData && snapshot.data != null && homeBloc.statusAbsensi() ? snapshot.data : homeCards["Makeup"]!['image'],
              img: homeCards["Makeup"]!['image'],
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

class CheckIn extends StatefulWidget {
  const CheckIn({Key? key}) : super(key: key);

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
              color: MaterialColors.newPrimary,
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
  var time = 0;

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
      startTimer(formatter.format(dateString));
    } catch (e) {
      inspect(e);
    }
  }

  void startTimer(String data) {
    const oneSec = const Duration(seconds: 1);

    counts = data.split(":").map((e) => int.parse(e)).toList();

    time = counts[2];
    time += counts[1] * 60;
    time += (counts[0] * 60) * 60;

    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          
          if (counts[2] >= 59 && counts[1] > 0) {
            counts[1] += 1;
            counts[2] = 0;
          }

          if (counts[1] >= 59 && counts[0] > 0) {
            counts[0] += 1;
            counts[1] = 0;
          }

          if (counts[0] >= 23) {
            counts[0] = 0;
            counts[1] = 0;
            counts[2] = 0;
          }

          counts[2]++;
          time++;

          var hours = "";
          var minutes = "";
          var seconds = "";

          if (counts[0] < 10){
            hours = "0";
          }
          
          if (counts[1] < 10) {
            minutes = "0";
          }
          
          if (counts[2] < 10) {
            seconds = "0";
          }

          hours += "${counts[0]}";
          minutes += "${counts[1]}";
          seconds += "${counts[2]}";

          timeBloc.count = "$hours:$minutes:$seconds";

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
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if(!snapshot.hasData) {
          return CheckInButton(disabled: true);
        }
        return !kIsWeb ? StreamBuilder<ServiceStatus>(
          stream: locationBloc.serviceStatusStream$,
          initialData: snapshot.data! ? ServiceStatus.enabled : ServiceStatus.disabled,
          builder: (BuildContext context, AsyncSnapshot<ServiceStatus> snapshot) {
            /// index === 0 => disabled
            // return CheckInButton(disabled: false);
            if((!snapshot.hasData || snapshot.data?.index == 0 || snapshot.data == null)) {
             return CheckInButton(disabled: true);
            }
            return FutureBuilder(
              future: locationBloc.getPosition,
              builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
                return CheckInButton(disabled: !snapshot.hasData);
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
  const CheckInButton({Key? key, required this.disabled}): super(key: key);

  @override
  _CheckInButton createState() => _CheckInButton();
}

class _CheckInButton extends State<CheckInButton> {
  final CameraBloc cameraBloc = new CameraBloc();

  @override 
  void dispose() {
    super.dispose();
  }
  @override 
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: (widget.disabled) ? Colors.grey : Colors.green,
        shape: const CircleBorder(), 
        padding: const EdgeInsets.all(80)
      ),
      child: Text(
        "Check In",
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
      onPressed: () async {
        
        if(!widget.disabled) await availableCameras().then((value) => 
          Navigator.push(context, MaterialPageRoute(builder: (_) => CameraPage(cameras: value)))
        );
      },
    );
  }
}