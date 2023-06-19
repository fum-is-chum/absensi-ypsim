import 'dart:convert';

import 'package:SIMAt/env.dart';
import 'package:SIMAt/screens/home/home.dart';
import 'package:SIMAt/screens/riwayat-presensi/models/riwayat-presensi-model.dart';
import 'package:SIMAt/utils/constants/Theme.dart';
import 'package:SIMAt/utils/iframe/iframe.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:SIMAt/widgets/card-small.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RiwayatPresensiDetail extends StatelessWidget {
  final RiwayatPresensiModel item;

  const RiwayatPresensiDetail({Key? key, required this.item}) : super(key: key);

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
                SizedBox(height: 16),
                ImageRow(
                  item: item,
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
                Text(formatDateOnly(item.date, format: 'EEEE, d MMMM yyyy')),
                SizedBox(height: 16),
                Text(
                  "Lokasi Absensi",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                (() {
                  if (item.latitude_check_in != null) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 400,
                        child: LokasiAbsensiMap(
                          item: item,
                        ));
                  } else {
                    return Container();
                  }
                }()),
                SizedBox(
                  height: 24,
                )
              ],
            ),
          ),
        ));
  }
}

class ImageRow extends StatelessWidget {
  final RiwayatPresensiModel item;
  const ImageRow({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: homeBloc.attendanceStatus$,
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CardSmall(
                cta: item.check_in,
                title: "IN",
                img: item.photo_check_in != null
                    ? "${Environment.baseUrl}${item.photo_check_in}"
                    : 'assets/img/no-image.jpg',
                tap: () {}),
            SizedBox(width: 8),
            CardSmall(
                cta: item.check_out,
                title: "OUT",
                img: item.photo_check_out != null
                    ? "${Environment.baseUrl}${item.photo_check_out}"
                    : 'assets/img/no-image.jpg',
                // img: 'assets/img/no-image.jpg',
                tap: () {
                  // Navigator.pushReplacementNamed(context, '/pro');
                })
          ],
        );
      },
    );
  }
}

class LokasiAbsensiMap extends StatefulWidget {
  final RiwayatPresensiModel item;
  LokasiAbsensiMap({Key? key, required this.item}) : super(key: key);

  @override
  State<LokasiAbsensiMap> createState() => _LokasiAbsensiMap();
}

class _LokasiAbsensiMap extends State<LokasiAbsensiMap> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.dataFromString(
          detailPresensiMap(
              widget.item.latitude_check_in,
              widget.item.longitude_check_in,
              widget.item.latitude_check_out,
              widget.item.longitude_check_out),
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8')));
  }

  @override
  Widget build(BuildContext contexet) {
    return Stack(
      children: [
        WebViewWidget(
          controller: _controller,
          gestureRecognizers: [
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          ].toSet(),
        )
      ],
    );
  }
}
