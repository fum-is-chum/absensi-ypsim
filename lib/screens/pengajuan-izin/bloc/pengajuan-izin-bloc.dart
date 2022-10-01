

import 'dart:async';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:absensi_ypsim/dio-interceptor.dart';
import 'package:absensi_ypsim/misc/credential-getter.dart';
import 'package:absensi_ypsim/services/shared-service.dart';
import 'package:absensi_ypsim/widgets/spinner.dart';
import 'package:path/path.dart';

import '../models/pengajuan-izin-model.dart';

class PengajuanIzinBloc {
  late PengajuanIzinModel _pengajuanIzinModel;
  Spinner sp = new Spinner();
  
  PengajuanIzinBloc() {
    _pengajuanIzinModel = PengajuanIzinModel();
  }

  void dispose() => _pengajuanIzinModel = PengajuanIzinModel();

  PengajuanIzinModel get model => _pengajuanIzinModel;

  void setInitialValue(PengajuanIzinModel data) => _pengajuanIzinModel = data;

  Map<String, dynamic> getRawValue() => _pengajuanIzinModel.toJson();

  Future<File?> fetchFile() async {
    if(_pengajuanIzinModel.file != null) {
      await createFileOfPdfUrl(null, _pengajuanIzinModel.file!).then((value) => _pengajuanIzinModel.file = value);
      return _pengajuanIzinModel.file;
    }
    return null;
  }

  Future<bool> updateIzin(BuildContext context) async {
    try{
      sp.show(context: context);
      await update();
      sp.hide();
      await ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "Berhasil",
          text: 'Izin berhasil diedit'
        ),
      );
      return true;
    } catch (e) {
      sp.hide();
      handleError(context, e);
      return false;
    }
  }

  Future<bool> createIzin(BuildContext context) async {
    try{
      sp.show(context: context);
      Response resp = await create();
      sp.hide();
      await ArtSweetAlert.show(
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
      handleError(context, e);
      return false;
    }
  }

  Future<Response> create() async {
    int userId = await CredentialGetter().userId;
    // _pengajuanIzinModel.remove('file');
    // var formData = FormData.fromMap(_pengajuanIzinModel);
    var formData = FormData.fromMap({
      ..._pengajuanIzinModel.toJson(),
      'file': _pengajuanIzinModel.file != null ?
              MultipartFile.fromBytes(
              (_pengajuanIzinModel.file as File).readAsBytesSync(),
              filename: basename((_pengajuanIzinModel.file as File).path)) 
              : null
    });
    
    return DioClient().dioWithResponseType(ResponseType.plain).post(
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

  Future<Response> update() async {
    int? permissionId = _pengajuanIzinModel.id;
    // _pengajuanIzinModel.remove('file');
    // var formData = FormData.fromMap(_pengajuanIzinModel);
    var formData = FormData.fromMap({
      ..._pengajuanIzinModel.toJson(),
      'file': _pengajuanIzinModel.file != null ?
              MultipartFile.fromBytes(
              (_pengajuanIzinModel.file as File).readAsBytesSync(),
              filename: basename((_pengajuanIzinModel.file as File).path)) 
              : null
    });

    return DioClient().dioWithResponseType(ResponseType.plain).post(
      '/permission/update/$permissionId',
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