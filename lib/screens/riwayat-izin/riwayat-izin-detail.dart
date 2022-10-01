import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:material_kit_flutter/utils/constants/Theme.dart';
import 'package:material_kit_flutter/screens/pengajuan-izin/pengajuan-izin.dart';
import 'package:material_kit_flutter/screens/riwayat-izin/models/riwayat-izin.dart';
import 'package:material_kit_flutter/utils/services/shared-service.dart';
import 'package:material_kit_flutter/widgets/spinner.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'bloc/riwayat-izin-detail.dart';

RiwayatIzinDetailBloc _riwayatIzinBloc = RiwayatIzinDetailBloc();

class RiwayatIzinDetail extends StatelessWidget {
  final RiwayatIzinModel item;

  RiwayatIzinDetail({Key? key, required this.item}): super(key: key);
  
  List<Widget> _actionWidget(BuildContext context) {
    if(item.status == 'Menunggu') 
      return [
        IconButton(
          onPressed: () async {
            await _riwayatIzinBloc.getDetail(context, item.id).then((value) {
              if(value != null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => 
                  PengajuanIzin(editData: value,)
                ));
              }
            });
          },
          icon: Icon(Icons.edit_note,
            size: 32.0,
          )
        )
      ];
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Detail Riwayat Izin",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          elevation: 2,
          backgroundColor: MaterialColors.bgColorScreen,
          iconTheme: IconThemeData(color: Colors.black),
          actions: _actionWidget(context),
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        // key: _scaffoldKey,
        // drawer: MaterialDrawer(currentPage: "Riwayat-izin"),
        body: Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(12.0),
                //     color: Colors.black26,
                //   ),
                //   height: 200,
                // ),
                // SizedBox(height: 16),
                Text(
                  "Status",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(item.status),
                (() { 
                  if(item.reason != null)
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Text(
                          "Alasan Penolakan",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(item.reason!),
                      ],
                    );
                  return const SizedBox();
                } ()),
                SizedBox(height: 16),
                Text(
                  "Tanggal Pengajuan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(formatDateOnly(item.created_at, format: "EEEE, d MMMM yyyy")),
                SizedBox(height: 16),
                Text(
                  "Tanggal Mulai",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(formatDateOnly(item.start_date, format: "dd MMMM yyyy")),
                SizedBox(height: 16),
                Text(
                  "Tanggal Selesai",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(formatDateOnly(item.end_date, format: "dd MMMM yyyy")),
                SizedBox(height: 16),
                Text(
                  "Keterangan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(item.remark),
                SizedBox(height: 16),
                Text(
                  "Lampiran",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                (() {
                  if(item.file == null)
                    return Text('Tidak ada Lampiran');
                  return InkWell(
                    onTap: () {
                      if(item.file != null) _riwayatIzinBloc.launchURL(item.file!);
                    },
                    child: Text(item.file!.substring(item.file!.lastIndexOf('/') + 1),
                      style: TextStyle(
                        decoration: TextDecoration.underline
                      ),
                    ),
                  );
                }()),
                SizedBox(height: 16,),
                (() {
                  if(item.file != null) {
                    return LampiranView(url: "https://presensi.ypsimlibrary.com${item.file!}");
                  }
                  return Container();
                } ())
              ],
            ),
          ),
        ));
  }
}


class LampiranView extends StatefulWidget {
  final String url;

  const LampiranView({Key? key, required this.url}) : super(key: key);

  @override
  State<LampiranView> createState() => _LampiranView();
}

class _LampiranView extends State<LampiranView> {

  @override 
  Widget build(BuildContext context) {
    if(widget.url.indexOf(".pdf") == -1)
      return Container(
        height: 500,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        child: WebView(
          gestureRecognizers: [
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          ].toSet(),
          onWebViewCreated: (WebViewController wv) {
            setState(() {
              
            });
          },
          initialUrl: Uri.dataFromString("""
            <!DOCTYPE html>
              <html lang="en">
                <head>
                  <meta charset="UTF-8">
                  <meta http-equiv="X-UA-Compatible" content="IE=edge">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <style>
                    *{
                      box-sizing: border-box;
                    }
                    body{
                      margin: 0px;
                    }
                    iframe{
                      height: 100vh;
                      width: 100vw;
                    }
                  </style>
                </head>
                <body>
                  <iframe id="embed-maps" height="auto" frameBorder="0" src="${widget.url}"></iframe>
                </body>
              </html>""", 
              mimeType: 'text/html'
            ).toString(),
          javascriptMode: JavascriptMode.unrestricted,
        )
      );
    return Container(
      height: 500,
      child: FutureBuilder(
        future: createFileOfPdfUrl(context, widget.url),
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if(!snapshot.hasData)
            return loadingSpinner();
          return PDFScreen(path: snapshot.data!.path,);
        },
      ),
    );
  }
}

class PDFScreen extends StatefulWidget {
  final String? path;

  PDFScreen({Key? key, this.path}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document"),
        leading: Container(),
        automaticallyImplyLeading: false,
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.share),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            // swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.WIDTH,
            gestureRecognizers: [
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            ].toSet(),
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              // print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              // print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              // print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              // print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
    );
  }
}