import 'dart:async';

import 'package:absensi_ypsim/screens/home/bloc/camera-bloc.dart';
import 'package:absensi_ypsim/screens/home/bloc/home-bloc.dart';
import 'package:absensi_ypsim/screens/home/bloc/time-bloc.dart';
import 'package:absensi_ypsim/screens/home/widgets/location-view.dart';
import 'package:absensi_ypsim/utils/constants/Theme.dart';
import 'package:absensi_ypsim/widgets/card-small.dart';
import 'package:absensi_ypsim/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc/location-bloc.dart';
import 'widgets/check-in-button.dart';
import 'widgets/check-in-card.dart';

TimeBloc timeBloc = TimeBloc();
HomeBloc homeBloc = HomeBloc();
CameraBloc cameraBloc = CameraBloc();
LocationBloc locationBloc = LocationBloc();

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final GlobalKey _scaffoldKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Future.delayed(Duration(seconds: 1)).then((value) {
      SystemChrome.restoreSystemUIOverlays();
    });
    homeBloc.init();
    timeBloc.init();
    locationBloc.initLocation();
  }

  @override
  void dispose() {
    timeBloc.dispose();
    // homeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
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
          child: RefreshIndicator(
            onRefresh: () async {
              await homeBloc.getAttendanceStatus(date: timeBloc.currentDate);
              setState(() {});
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30,),
                  ImageRow(),
                  SizedBox(height: 20),
                  CheckInCard(),
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
    Rx.combineLatestList([
      timeBloc.dateStream$.distinct(),
      homeBloc.reloadAttendance$
    ]).listen((event) {
      print(event);
      homeBloc.getAttendanceStatus(date: timeBloc.currentDate);
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
              cta:  snapshot.hasData && snapshot.data != null && 
                    snapshot.data?['personal_calender'] != null ? "${snapshot.data?['personal_calender']['check_in'] ?? '00:00:00'} WIB" : '00:00:00 WIB',
              title: "IN",
              img:  snapshot.hasData && snapshot.data != null && snapshot.data?['personal_calender']?['photo_check_in'] != null ? 
                    "https://presensi.ypsimlibrary.com${snapshot.data?['personal_calender']['photo_check_in']}" : 'assets/img/no-image.jpg',
              // img: 'assets/img/no-image.jpg',
              tap: () {
                // Navigator.pushReplacementNamed(context, '/pro');
              }
            ),
            SizedBox(width: 8),
            CardSmall(
              cta:  snapshot.hasData && snapshot.data != null && 
                    snapshot.data?['personal_calender'] != null ? "${snapshot.data?['personal_calender']['check_out'] ?? '00:00:00'} WIB" : '00:00:00 WIB',
              title: "OUT",
              img: snapshot.hasData && snapshot.data != null && snapshot.data?['personal_calender']?['photo_check_out'] != null ? 
                  "https://presensi.ypsimlibrary.com${snapshot.data?['personal_calender']['photo_check_out']}" : 'assets/img/no-image.jpg',
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