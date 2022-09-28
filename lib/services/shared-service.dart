import 'dart:async';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:material_kit_flutter/dio-interceptor.dart';
import 'package:path_provider/path_provider.dart';

String formatDateOnly(dynamic date, {String format = 'yyyy-MM-dd'}) {
  return DateFormat(format, "id_ID").format(date is String ? DateTime.parse(date): date);
}

Future<String> handleError(BuildContext? context, dynamic e) async {
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
    handleError(context, e);
  }

  return completer.future;
}