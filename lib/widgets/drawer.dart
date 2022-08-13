import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

import 'package:material_kit_flutter/widgets/drawer-tile.dart';

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
                Divider(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: DrawerTile(
                icon: Icons.logout,
                onTap: () {
                  if (currentPage != "logout")
                    Navigator.pushReplacementNamed(context, '/logout');
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
