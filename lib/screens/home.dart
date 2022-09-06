import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_kit_flutter/bloc/camera-bloc.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/screens/camera.dart';
import 'package:material_kit_flutter/widgets/card-small.dart';
import 'package:material_kit_flutter/widgets/drawer.dart';

import '../bloc/home-bloc.dart';
import '../bloc/location-bloc.dart';
import '../widgets/location-view.dart';

final Map<String, Map<String, String>> homeCards = {
  "Makeup": {
    "title": "Find the cheapest deals on our range...",
    "image":
        "https://images.unsplash.com/photo-1515709980177-7a7d628c09ba?crop=entropy&w=840&h=840&fit=crop",
    "price": "220"
  },
};


class Home extends StatelessWidget {
  // final GlobalKey _scaffoldKey = new GlobalKey();
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
  final CameraBloc cameraBloc = new CameraBloc();
  final HomeBloc homeBloc = new HomeBloc();
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
              cta: cameraBloc.snapTime != '' && !homeBloc.statusAbsensi() ? cameraBloc.snapTime : "07:01:12 WIB",
              title: "IN",
              img: snapshot.hasData && snapshot.data != null && !homeBloc.statusAbsensi() ? snapshot.data :homeCards["Makeup"]!['image'],
              tap: () {
                // Navigator.pushReplacementNamed(context, '/pro');
              }
            ),
            SizedBox(width: 8),
            CardSmall(
              cta: cameraBloc.snapTime != '' && homeBloc.statusAbsensi() ? cameraBloc.snapTime : "16:01:12 WIB",
              title: "OUT",
              img: snapshot.hasData && snapshot.data != null && homeBloc.statusAbsensi() ? snapshot.data : homeCards["Makeup"]!['image'],
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
                  Text(
                    "07:30:00 WIB",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        return StreamBuilder<ServiceStatus>(
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
                if(snapshot.hasData) {
                  // setelah dapat data lokasi, hitung jarak koordinat ke lokasi, kirim ke api
                  return CheckInButton(disabled: false);
                }
                return CheckInButton(disabled: true);
              }
            );
          },
        );
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
        // if(!widget.disabled) cameraBloc.openCamera();
        if(!widget.disabled) await availableCameras().then((value) => 
          Navigator.push(context, MaterialPageRoute(builder: (_) => CameraPage(cameras: value)))
        );
      },
    );
      // Material(
      //   color: Colors.transparent,
      //   child: MaterialButton(
      //     onPressed: () async {
              
      //     },
      //     child: Container(
      //       padding: EdgeInsets.all(80),
      //       decoration: BoxDecoration(
      //         color: (widget.disabled) ? Colors.grey : Colors.green,
      //         shape: BoxShape.circle
      //       ),
      //       child: Text(
      //         "Check In",
      //         style: TextStyle(fontSize: 20, color: Colors.white),
      //       ),
      //     ),
      //     color: (widget.disabled) ? Colors.grey : Colors.green,
      //     shape: CircleBorder(),
      //   ),
      // );
  }
}