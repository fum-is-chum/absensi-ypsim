import 'package:flutter/material.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/widgets/drawer.dart';

class HistoryDetail extends StatelessWidget {
  // final GlobalKey _scaffoldKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Detail Riwayat Presensi",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          elevation: 0,
          backgroundColor: MaterialColors.bgColorScreen,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        // key: _scaffoldKey,
        drawer: MaterialDrawer(currentPage: "History"),
        body: Container(
          padding: EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.black26,
                  ),
                  height: 200,
                ),
                SizedBox(height: 16),
                Text(
                  "Status",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text("Hadir"),
                SizedBox(height: 16),
                Text(
                  "Tanggal Presensi",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text("Sabtu, 14 Mei 2022"),
                SizedBox(height: 16),
                Text(
                  "Waktu Check In",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text("07:15"),
                SizedBox(height: 16),
                Text(
                  "Waktu Check Out",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text("17:15"),
                SizedBox(height: 16),
                Text(
                  "Foto",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Lihat Foto",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ));
  }
}
