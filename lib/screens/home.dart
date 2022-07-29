import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/widgets/card-small.dart';
import 'package:material_kit_flutter/widgets/drawer.dart';
import 'package:rxdart/rxdart.dart';

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
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CardSmall(
                        cta: "07:01:12 WIB",
                        title: "IN",
                        img: homeCards["Makeup"]!['image'],
                        tap: () {
                          // Navigator.pushReplacementNamed(context, '/pro');
                        }),
                    SizedBox(width: 8),
                    CardSmall(
                        cta: "16:01:12 WIB",
                        title: "OUT",
                        img: homeCards["Makeup"]!['image'],
                        tap: () {
                          // Navigator.pushReplacementNamed(context, '/pro');
                        })
                  ],
                ),
                SizedBox(height: 20),
                CheckIn(),
                SizedBox(height: 120),
                LocationView(),
                SizedBox(height: 30),
              ],
            ),
          ),
        ));
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
                FractionalTranslation(
                  translation: Offset(0, 0.5),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CheckInButtonContainer()
                  ),
                )
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
            return CheckInButton(disabled: false);
            // if((!snapshot.hasData || snapshot.data?.index == 0 || snapshot.data == null)) {
            //  return CheckInButton(disabled: true);
            // }
            // return CheckInButton(disabled: false);
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
  // File? image;
  Future pickImage() async {
    try {
      final img = await ImagePicker().pickImage(source: ImageSource.camera);
      inspect(img);
      // final File imageTemp = File();
      // setState(() => this.image = imageTemp);
    } on PlatformException catch(e) {
      print('Failed to pick image: $e');
    } 
    return;
  }

  @override 
  void dispose() {
    super.dispose();
  }
  @override 
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: MaterialButton(
        onPressed: () async {
            print('camera');
            await pickImage();
        },
        child: Container(
          padding: EdgeInsets.all(80),
          decoration: BoxDecoration(
            color: (widget.disabled) ? Colors.grey : Colors.green,
            shape: BoxShape.circle
          ),
          child: Text(
            "Check In",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        color: (widget.disabled) ? Colors.grey : Colors.green,
        shape: CircleBorder(),
      ),
    );
  }
}