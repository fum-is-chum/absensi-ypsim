import 'package:flutter/material.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/widgets/drawer.dart';
import 'package:material_kit_flutter/widgets/history-item.dart';

final Map<String, Map<String, String>> homeCards = {
  "Makeup": {
    "title": "Find the cheapest deals on our range...",
    "image":
        "https://images.unsplash.com/photo-1515709980177-7a7d628c09ba?crop=entropy&w=840&h=840&fit=crop",
    "price": "220"
  },
};

class History extends StatelessWidget {
  // final GlobalKey _scaffoldKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Riwayat Presensi",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: MaterialColors.bgColorScreen,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        // key: _scaffoldKey,
        drawer: MaterialDrawer(currentPage: "History"),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                HistoryItem(
                  date: "Sabtu, 14 Mei 2022",
                  checkIn: "07:30",
                  checkOut: "16:50",
                  status: "Tepat Waktu",
                  tap: () {},
                ),
                SizedBox(height: 12),
                HistoryItem(
                  date: "Senin, 16 Mei 2022",
                  checkIn: "08:30",
                  checkOut: "16:50",
                  status: "Telat",
                  tap: () {},
                ),
                SizedBox(height: 12),
                HistoryItem(
                  date: "Selasa, 17 Mei 2022",
                  checkIn: "00:00",
                  checkOut: "00:00",
                  status: "Absen",
                  tap: () {},
                ),
                SizedBox(height: 12),
                HistoryItem(
                  date: "Rabu, 18 Mei 2022",
                  checkIn: "07:30",
                  checkOut: "16:00",
                  status: "Cepat Pulang",
                  tap: () {},
                ),
              ],
            ),
          ),
        ));
  }
}
