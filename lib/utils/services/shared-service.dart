import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:absensi_ypsim/dio-interceptor.dart';
import 'package:path_provider/path_provider.dart';

String formatDateOnly(dynamic date, {String format = 'yyyy-MM-dd'}) {
  return DateFormat(format, "id_ID").format(date is String ? DateTime.parse(date): date);
}

String formatTimeOnly(dynamic date) {
  return DateFormat("HH:mm:ss", "id_ID").format(date is String ? DateTime.parse(date): date);
}

Future<String> handleError(BuildContext? context, dynamic e) async {
  String error = "";
  if(e is DioError) {
    if(e.response != null && e.response!.data != null) {
      error = "${ApiResponse.fromJson(jsonDecode(e.response!.data)).Message}";
    } else if(e.error is SocketException) {
      error = "Tidak ada koneksi";
    } else if(e.error is TimeoutException) {
      error = "${e.requestOptions.baseUrl}${e.requestOptions.path}\nRequest Timeout";
    }
  } else {
    error = e.toString();
  }
  if(context != null)
    await ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        type: ArtSweetAlertType.danger,
        title: "Gagal",
        text: error
      )
    );
  return error;
}

Future<File> createFileOfPdfUrl(BuildContext? context, String url) async {
  Completer<File> completer = Completer();
  // print("Start download file from internet!");
  try {
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var bytes = (await DioClient().dioWithResponseType(ResponseType.bytes, baseUrl: 'https://presensi.ypsimlibrary.com').get(url)).data;
    var dir = await getApplicationDocumentsDirectory();
    // print("Download files");
    // print("${dir.path}/$filename");
    File file = File("${dir.path}/$filename");

    await file.writeAsBytes(bytes, flush: true);
    completer.complete(file);
    // print("Done");
  } catch (e) {
    await handleError(context, e);
  }

  return completer.future;
}