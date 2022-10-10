import 'package:absensi_ypsim/screens/riwayat-izin/riwayat-izin-detail.dart';
import 'package:absensi_ypsim/screens/riwayat-presensi/models/history-model.dart';
import 'package:absensi_ypsim/utils/constants/Theme.dart';
import 'package:absensi_ypsim/utils/services/shared-service.dart';
import 'package:absensi_ypsim/widgets/drawer.dart';
import 'package:flutter/material.dart';

class RiwayatPresensiDetail extends StatelessWidget {
  final HistoryModel item;

  RiwayatPresensiDetail({Key? key, required this.item}): super(key: key);

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
        elevation: 2,
        backgroundColor: MaterialColors.bgColorScreen,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      // key: _scaffoldKey,
      // drawer: MaterialDrawer(currentPage: "History"),
      body: Container(
        padding: EdgeInsets.all(16),
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
              Text(item.status),
              SizedBox(height: 16),
              Text(
                "Tanggal Presensi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(formatDateOnly(item.created_at,
                    format: 'EEEE, d MMMM yyyy')),
              SizedBox(height: 16),
              Text(
                "Waktu Check In",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(formatDateOnly(item.start_date,
                    format: 'H:mm')),
              SizedBox(height: 16),
              Text(
                "Waktu Check Out",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(formatDateOnly(item.end_date, format: 'H:mm')),
              SizedBox(height: 16),
              Text(
                "Foto",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              // Text(
              //   "Lihat Foto",
              //   style: TextStyle(decoration: TextDecoration.underline),
              // ),
              (() {
                if (item.file != null) {
                  return LampiranView(
                      url: "https://presensi.ypsimlibrary.com${item.file!}");
                }
                return Container();
              }())
            ],
          ),
        ),
      )
    );
  }
}
