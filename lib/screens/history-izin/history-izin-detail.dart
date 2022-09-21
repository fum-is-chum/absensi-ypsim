import 'package:flutter/material.dart';
import 'package:material_kit_flutter/constants/Theme.dart';

class HistoryIzinDetail extends StatelessWidget {
  // final GlobalKey _scaffoldKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Detail Riwayat Izin",
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
        // drawer: MaterialDrawer(currentPage: "History Izin"),
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
                Text("Diterima"),
                SizedBox(height: 16),
                Text(
                  "Tanggal Pengajuan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text("Sabtu, 14 Mei 2022"),
                SizedBox(height: 16),
                Text(
                  "Tanggal Mulai",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text("15 Mei 2022"),
                SizedBox(height: 16),
                Text(
                  "Tanggal Selesai",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text("20 Mei 2022"),
                SizedBox(height: 16),
                Text(
                  "Lampiran",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Lihat Lampiran",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ));
  }
}
