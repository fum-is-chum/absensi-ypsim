import 'package:flutter/material.dart';
import 'package:material_kit_flutter/misc/credential-getter.dart';
import 'package:material_kit_flutter/screens/Login-Register-Verification/screens/login/bloc/login-bloc.dart';
// import 'package:url_launcher/url_launcher.dart';

import 'package:material_kit_flutter/widgets/drawer-tile.dart';
import 'package:material_kit_flutter/widgets/spinner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaterialDrawer extends StatelessWidget {
  final String? currentPage;

  MaterialDrawer({this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: Column(children: [
          SizedBox(
            height: 270,
            child: DrawerHeader(
              child: Container(
                // padding: EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage:
                            AssetImage("assets/img/logo-ypsim.jpeg"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
                      child: Text("John Doe",
                          style:
                              TextStyle(color: Colors.black87, fontSize: 21)),
                    ),
                    Row(
                      children: [
                        Text(
                          "201110349",
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 8),
              children: [
                Divider(),
                SizedBox(height: 8),
                DrawerTile(
                    icon: Icons.home,
                    onTap: () {
                      if (currentPage != "Home")
                        Navigator.pushReplacementNamed(context, '/home');
                    },
                    iconColor: Colors.black,
                    title: "Home",
                    isSelected: currentPage == "Home" ? true : false),
                DrawerTile(
                    icon: Icons.post_add,
                    onTap: () {
                      if (currentPage != "Request")
                        Navigator.pushReplacementNamed(context, '/request');
                    },
                    iconColor: Colors.black,
                    title: "Pengajuan Izin",
                    isSelected: currentPage == "Request" ? true : false),
                DrawerTile(
                    icon: Icons.timelapse,
                    onTap: () {
                      if (currentPage != "History")
                        Navigator.pushReplacementNamed(context, '/history');
                    },
                    iconColor: Colors.black,
                    title: "Riwayat Presensi",
                    isSelected: currentPage == "History" ? true : false),
                SizedBox(height: 8),
                DrawerTile(
                    icon: Icons.timelapse,
                    onTap: () {
                      if (currentPage != "History Izin")
                        Navigator.pushReplacementNamed(
                            context, '/history_izin');
                    },
                    iconColor: Colors.black,
                    title: "Riwayat Izin",
                    isSelected: currentPage == "History Izin" ? true : false),
                SizedBox(height: 8),
                Divider(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: DrawerTile(
                icon: Icons.logout,
                onTap: () async {
                  if (currentPage != "logout") {
                    await LoginBloc().logoutUser(context);
                    SharedPreferences sharedPref = await SharedPreferences.getInstance();
                    sharedPref.remove('user');
                    CredentialGetter().reset();
                    Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false
                    );
                  }
                },
                iconColor: Colors.black,
                title: "Keluar",
                isSelected: currentPage == "logout" ? true : false),
          ),
        ]),
      ),
    );
  }
}
