

import 'dart:async';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:material_kit_flutter/dio-interceptor.dart';
import 'package:material_kit_flutter/misc/credential-getter.dart';
import 'package:material_kit_flutter/widgets/spinner.dart';

import '../models/pengajuan-izin-model.dart';

class PengajuanIzinBloc {
  late Map<String, dynamic> _pengajuanIzinModel;
  Spinner sp = new Spinner();
  
  PengajuanIzinBloc() {
    _pengajuanIzinModel = new PengajuanIzinModel().toJson();
  }

  void setValue(String key, dynamic value) => _pengajuanIzinModel[key] = value;

  String getValue(String key) => _pengajuanIzinModel[key];

  Map<String, dynamic> getRawValue() => _pengajuanIzinModel;

  Future<bool> createIzin(BuildContext context) async {
    try{
      sp.show(context: context);
      Response resp = await create();
      sp.hide();
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "Berhasil",
          text: 'Izin berhasil diajukan'
        )
      );
      return true;
    } catch (e) {
      sp.hide();
      String error = "";
      if(e is DioError) {
        if(e.response != null) {
          error = "${e.message}\n${e.response.toString()}";
        } else if(e.error is SocketException) {
          error = "Tidak ada koneksi";
        } else if(e.error is TimeoutException) {
          error = "${e.requestOptions.baseUrl}${e.requestOptions.path}\nRequest Timeout";
        }
      } else {
        error = e.toString();
      }
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.danger,
          title: "Gagal",
          text: error
        )
      );
      return false;
    }
  }

  Future<Response> create() async {
    int userId = await CredentialGetter().userId;
    _pengajuanIzinModel.remove('file');
    var formData = FormData.fromMap(_pengajuanIzinModel);
    // var formData = FormData.fromMap({
    //   ..._pengajuanIzinModel,
    //   'file': MultipartFile.fromBytes(
    //     (_pengajuanIzinModel['file'] as File).readAsBytesSync(),
    //     filename: basename((_pengajuanIzinModel['file'] as File).path)
    //   )
    // });
    return DioClient().dio.post(
      '/permission/$userId',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Connection': 'keep-alive',
          'Accept-Encoding': 'gzip, deflat, br',
          'RequireToken': ''
        }
      )
    );
  }
}