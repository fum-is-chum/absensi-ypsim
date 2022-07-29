import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/location-bloc.dart';
import '../constants/Theme.dart';

class LocationView extends StatefulWidget {
  LocationView({Key? key}) : super(key: key);
  @override
  _LocationView createState() => _LocationView();
}

class _LocationView extends State<LocationView> {
  GlobalKey<_MyMapView> mapKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: MaterialColors.newPrimary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Lokasi Anda",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Material(
                    shape: CircleBorder(),
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () {
                        mapKey.currentState!.reload();
                      },
                      splashRadius: 20.0,
                      // splashColor: Colors.grey,
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(),
                      icon: const Icon(Icons.replay_outlined),
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 400,
            child: MyMapView(key: mapKey)
          )
        ],
      ),
    );
  }
}

class MyMapView extends StatefulWidget {
  MyMapView({Key? key}): super(key: key);

  @override
  _MyMapView createState() => _MyMapView();
}

class _MyMapView extends State<MyMapView> {
  InAppWebViewController? webView;
  LocationBloc locationBloc = new LocationBloc(); 
  late StreamSubscription<ServiceStatus> serviceStatus;
  late StreamSubscription<Position> positionStatus;
  bool findLocationClicked = false;

  Future<void> loadMaps(Position event) async {
    Uri uri = Uri(
      scheme: 'https',
      host: 'google.com',
      path: '/maps',
      queryParameters: {'q': '${event.latitude},${event.longitude}'}
    );
    await webView?.loadUrl(urlRequest: URLRequest(url: uri));
  }

  void reload() async {
    this.locationBloc.getPosition.then(loadMaps);
  }

  @override
  void initState() {
    super.initState();
    locationBloc.initLocation();
    serviceStatus = locationBloc.serviceStatusStream$.listen((event) { 
      findLocationClicked = false;
      setState(() {
        
      });
    });

    positionStatus = locationBloc.positionStream$.distinct().listen(loadMaps);
  }

  @override 
  void dispose() {
    serviceStatus.cancel();
    positionStatus.cancel();
    locationBloc.dispose();
    super.dispose();
  }
  
  /// fungsi untuk mengklik tombol lokasi pada google maps webview
  /// (suatu saat bisa saja berubah jika ada update dr Google terhadap maps webview)
  findMyLocation(InAppWebViewController controller, Uri? url) async {
    /// await controller.evaluateJavascript(source: "var elems = document.querySelectorAll('*'), res = Array.from(elems).find(v => v.textContent.indexOf('Lokasi Anda') === 0);alert(res.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.outerHTML);"); // tombol lokasi 
    await controller.evaluateJavascript(source: "document.querySelector('div[role=\"checkbox\"]').click();");
    if(!findLocationClicked) findLocationClicked = true;
    /// await controller.evaluateJavascript(source: "document.querySelector('div[aria-label=\"Lokasi Anda\"]').click();");
  }

  @override 
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: locationBloc.isLocationOn,
      builder: (BuildContext context, AsyncSnapshot<bool> locationSnapshot) {
        if(!locationSnapshot.hasData || (locationSnapshot.hasData && locationSnapshot.data! == false)) {
          return Center(child: Text('Hidupkan akses lokasi'));
        }
        return FutureBuilder(
          future: locationBloc.getPosition,
          builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
            if(!snapshot.hasData || snapshot.data?.latitude == null) {
              return Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                AbsorbPointer(
                  child: InAppWebView(
                    // gestureRecognizers: [
                    //   Factory<OneSequenceGestureRecognizer>(
                    //       () => EagerGestureRecognizer(),
                    //     ),
                    //   ].toSet(),
                    // contextMenu: contextMenu,
                    // initialUrlRequest: URLRequest(url: Uri.parse('https://www.google.co.id/maps/@${snapshot.data!.latitude},${snapshot.data!.longitude},17z')),
                    initialUrlRequest: URLRequest(url: Uri.parse('https://www.google.com/maps?q=${snapshot.data!.latitude},${snapshot.data!.longitude}')),
                    // initialFile: "assets/index.html",
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        // debuggingEnabled: true,
                        useShouldOverrideUrlLoading: true,
                      ),
                      android: AndroidInAppWebViewOptions(
                        //useHybridComposition: true
                      )
                    ),
                    androidOnGeolocationPermissionsShowPrompt:
                          (InAppWebViewController controller, String origin) async {
                            return Future.value(GeolocationPermissionShowPromptResponse(
                                  origin: origin, allow: true, retain: false));
                          },
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                      // print("onWebViewCreated");
                    },
                    onLoadStart: (InAppWebViewController controller, Uri? url) {
                      
                    },
                    shouldOverrideUrlLoading:
                        (controller, shouldOverrideUrlLoadingRequest) async {
                      Uri? uri = shouldOverrideUrlLoadingRequest.request.url;

                      if (![
                        "http",
                        "https",
                        "file",
                        "chrome",
                        "data",
                        "javascript",
                        "about"
                      ].contains(uri?.scheme)) {
                        if (await canLaunchUrl(uri!)) {
                          // Launch the App
                          await launchUrl(
                            uri,
                          );
                          // and cancel the request
                          return NavigationActionPolicy.CANCEL;
                        }
                      }

                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStop: (InAppWebViewController controller, Uri? url) async {},
                    // !findLocationClicked ? findMyLocation : (InAppWebViewController controller, Uri? url) async {},
                    
                    onProgressChanged:
                        (InAppWebViewController controller, int progress) {

                    },
                    onUpdateVisitedHistory: (InAppWebViewController controller,
                        Uri? url, bool? androidIsReload) {
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      // print(consoleMessage);
                    },
                  ),
                ),
                StreamBuilder(
                  stream: locationBloc.locationLoading$,
                  builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if(!snapshot.hasData || snapshot.data == true) {
                      return Center(child: CircularProgressIndicator(),);
                    }
                    return Stack();
                  },
                )
              ],
            );
          }
        );
      },
    );
  }
}