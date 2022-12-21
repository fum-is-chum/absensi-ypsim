import 'dart:async';

import 'package:SIMAt/env.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:SIMAt/utils/interceptors/dio-interceptor.dart';
import 'package:SIMAt/models/api-response.dart';
import 'package:SIMAt/screens/pengajuan-izin/models/pengajuan-izin-model.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:SIMAt/widgets/spinner.dart';
import 'package:url_launcher/url_launcher.dart';

class RiwayatIzinDetailBloc {
  Spinner sp = Spinner();

  launchURL(String file) async {
    Uri url = Uri.parse("${Environment.baseUrl}$file");
    if (await canLaunchUrl(url)) {
      await launchUrl(url,
        mode: LaunchMode.externalApplication
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<PengajuanIzinModel?> getDetail(BuildContext? context, int permission_id) async {
    if(context != null) sp.show();
    try {
      PengajuanIzinModel? data = await _getDetail(permission_id);
      if(context != null) sp.hide();
      return data;
    } catch (e) {
      if(context != null) sp.hide();
      await handleError(e);
    }
    return null;
  }


  Future<PengajuanIzinModel?> _getDetail(int permission_id) async {
    try {
      Response resp = await DioClient.dio.get(
        "/permission/detail/$permission_id",
        options: Options(
          headers: {
            'RequireToken': ''
          }
        )
      );
      return PengajuanIzinModel.fromJson(ApiResponse.fromJson(resp.data).Result);
    } catch (e) {
      throw e;
    }
  }
}
