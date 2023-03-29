import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:SIMAt/screens/home/bloc/location-bloc.dart';
import 'package:SIMAt/utils//iframe/iframe.dart';
import 'package:SIMAt/utils/constants/Theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LocationView extends StatefulWidget {
  LocationView({Key? key}) : super(key: key);
  @override
  _LocationView createState() => _LocationView();
}

class _LocationView extends State<LocationView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
            // width: MediaQuery.of(context).size.width,
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
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: StreamBuilder<List<dynamic>>(
                        stream: CombineLatestStream.list([
                          LocationBloc.targetLocation$,
                          LocationBloc.positionStatus$
                        ]),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<dynamic>> locationList) {
                          if (!locationList.hasData ||
                              LocationBloc.getDistance != 0) {
                            return Text('Anda berada di luar jangkauan absensi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ));
                          }

                          return Text(
                            "Anda berada di dalam jangkauan absensi",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          );
                        }),
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
              child: MyMapView(key: mapKey))
        ],
      ),
    );
  }
}

class MyMapView extends StatefulWidget {
  MyMapView({Key? key}) : super(key: key);

  @override
  _MyMapView createState() => _MyMapView();
}

class _MyMapView extends State<MyMapView> {
  late WebViewController? webView = null;
  StreamSubscription<ServiceStatus>? serviceStatus;
  StreamSubscription<Position?>? positionStatus;

  Future<void> loadMaps(Position? pos) async {
    Map<String, dynamic>? target = LocationBloc.targetLocation;
    if (pos != null && (target?.isNotEmpty ?? false)) {
      try {
        await webView?.runJavaScript(updatePosition(pos, target!));
      } catch (e) {}
    }
  }

  void reload() async {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    LocationBloc.getValidLocation();
    serviceStatus = LocationBloc.serviceStatus$.listen((event) {
      if (event == ServiceStatus.enabled) {
        LocationBloc.getValidLocation();
        // webView = null;
      }
      // setState(() {});
    });

    positionStatus = LocationBloc.positionStatus$.listen((value) {
      // print("1");
      loadMaps(value);
    });
  }

  @override
  void dispose() {
    if (serviceStatus != null)
      serviceStatus!.cancel().whenComplete(() => serviceStatus = null);
    if (positionStatus != null)
      positionStatus!.cancel().whenComplete(() => positionStatus = null);
    super.dispose();
  }

  Widget _MapStatusWidget(String status, {bool loading = false}) {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            loading ? CircularProgressIndicator() : Container(),
            Text(status)
          ]),
    );
  }

  Widget _androidWidgets(Map<String, dynamic> targetLocation) {
    return Stack(children: [
      WebViewWidget(
        controller: webView!,
        gestureRecognizers: [
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        ].toSet(),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: LocationBloc.serviceStatus$.delay(const Duration(seconds: 1)),
        builder: (BuildContext context,
            AsyncSnapshot<ServiceStatus> serviceStatusSnapshot) {
          if (!serviceStatusSnapshot.hasData ||
              serviceStatusSnapshot.data == ServiceStatus.disabled) {
            return _MapStatusWidget('Hidupkan Akses Lokasi');
          }
          return FutureBuilder(
              future: LocationBloc.getCurrentPosition(),
              builder: (BuildContext context,
                  AsyncSnapshot<dynamic> positionSnapshot) {
                if (!positionSnapshot.hasData ||
                    positionSnapshot.data == null ||
                    positionSnapshot.data == -1) {
                  return _MapStatusWidget('Sedang mengambil lokasi',
                      loading: true);
                }
                return StreamBuilder(
                    stream: LocationBloc.targetLocation$,
                    initialData: LocationBloc.getTargetLocation,
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          snapshot.data?['latitude'] == null) {
                        return _MapStatusWidget(
                            'Sedang mengambil radius absensi',
                            loading: true);
                      }

                      if (webView == null) {
                        webView = WebViewController()
                          ..setJavaScriptMode(JavaScriptMode.unrestricted)
                          ..loadRequest(Uri.dataFromString(
                              homeMap(
                                  LocationBloc.position,
                                  snapshot.data!['latitude'],
                                  snapshot.data!['longitude'],
                                  snapshot.data!['radius']),
                              mimeType: 'text/html',
                              encoding: Encoding.getByName('utf-8')));
                      }

                      return _androidWidgets(snapshot.data!);
                    });
              });
        });
  }
}
