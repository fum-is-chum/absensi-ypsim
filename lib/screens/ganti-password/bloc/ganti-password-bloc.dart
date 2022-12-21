import 'dart:async';

import 'package:SIMAt/utils/interceptors/dio-interceptor.dart';
import 'package:SIMAt/utils/misc/credential-getter.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:SIMAt/widgets/spinner.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/ganti-password-model.dart';

class GantiPasswordBloc {
  late GantiPasswordModel _GantiPasswordModel;
  Spinner sp = new Spinner();
  
  GantiPasswordBloc() {
    _GantiPasswordModel = GantiPasswordModel();
  }

  void dispose() => _GantiPasswordModel = GantiPasswordModel();

  GantiPasswordModel get model => _GantiPasswordModel;

  void setInitialValue(GantiPasswordModel data) => _GantiPasswordModel = data;

  Map<String, dynamic> getRawValue() => _GantiPasswordModel.toJson();

  Future<bool> gantiPassword(BuildContext context) async {
    try{
      sp.show();
      await update();
      await CredentialGetter.updatePassword(model.newPassword);
      // update password ke sharedPreference
      sp.hide();
      await ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
          type: ArtSweetAlertType.success,
          title: "Berhasil",
          text: 'Berhasil Ganti Password'
        ),
      );
      return true;
    } catch (e) {
      sp.hide();
      await handleError(e);
      return false;
    }
  }

  Future<Response> update() async {
    int? userId = await CredentialGetter.userId;
    
    return DioClient.dio.post("/changePassword/$userId",
      options: Options(
        headers: {
          'RequireToken': ''
        }
      ),
      data: model
    );
  }
}