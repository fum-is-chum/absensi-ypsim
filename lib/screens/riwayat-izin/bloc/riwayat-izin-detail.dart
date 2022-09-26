import 'dart:io';

import 'package:dio/dio.dart';
import 'package:material_kit_flutter/dio-interceptor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RiwayatIzinDetailBloc {
  RiwayatIzinDetailBloc._sharedInstance();
  static final RiwayatIzinDetailBloc _shared = RiwayatIzinDetailBloc._sharedInstance();
  factory RiwayatIzinDetailBloc() => _shared;

  launchURL(String file) async {
    Uri url = Uri.parse("https://presensi.ypsimlibrary.com$file");
    if (await canLaunchUrl(url)) {
      await launchUrl(url,
        mode: LaunchMode.externalApplication
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
