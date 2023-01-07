import 'dart:async';

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
  WebViewController? webView;
  StreamSubscription<ServiceStatus>? serviceStatus;
  StreamSubscription<Position?>? positionStatus;

  Future<void> loadMaps(Position? pos) async {
    // LocationBloc.updateLoadingStatus(true);
    Map<String, dynamic>? target = LocationBloc.targetLocation;
    if (pos != null && (target?.isNotEmpty ?? false)) {
      // LocationBloc.updatePosition(pos);
      if (webView != null) {
        try {
          await webView?.runJavascript(updatePosition(pos, target!));
        } catch (e) {}
      }
    }
    // LocationBloc.updateLoadingStatus(false);
    // setState(() {

    // });
  }

  void reload() async {
    setState(() {});
    // if (webView == null) return;
    // await LocationBloc.getValidLocation().then((targetLocation) async {
    //   try {
    //     await webView?.loadUrl(Uri.dataFromString(
    //             homeMap(LocationBloc.position!, targetLocation['latitude'],
    //                 targetLocation['longitude'], targetLocation['radius']),
    //             mimeType: 'text/html')
    //         .toString());
    //   } catch (e) {
    //     print('DEBUG: $e');
    //   }
    // });
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      serviceStatus = LocationBloc.serviceStatus$.listen((event) {
        setState(() {});
      });
    }

    positionStatus = LocationBloc.positionStatus$.listen((value) {
      print(value);
      loadMaps(value);
    });
    // if (!kIsWeb) {
    // } else {
    //   positionStatus = CombineLatestStream.list(
    //           [LocationBloc.positionStatus$, LocationBloc.targetLocation$])
    //       .listen((value) {
    //     if (webView != null) {
    //       webView!.loadUrl(Uri.dataFromString(
    //               webMap(
    //                   value[0] as Position,
    //                   (value[1] as Map<String, dynamic>)['latitude'],
    //                   (value[1] as Map<String, dynamic>)['longitude'],
    //                   (value[1] as Map<String, dynamic>)['radius']),
    //               mimeType: 'text/html')
    //           .toString());
    //     }
    //   });
    // }
  }

  @override
  void dispose() {
    if (serviceStatus != null) serviceStatus!.cancel();
    if (positionStatus != null) positionStatus!.cancel();
    // webView?.clearCache();`
    webView = null;
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
    return LocationBloc.position != null
        ? Stack(children: [
            WebView(
              gestureRecognizers: [
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              ].toSet(),
              onWebViewCreated: (WebViewController wv) {
                webView = wv;
              },
              initialUrl: Uri.dataFromString(
                      homeMap(
                          LocationBloc.position,
                          targetLocation['latitude'],
                          targetLocation['longitude'],
                          targetLocation['radius']),
                      mimeType: 'text/html')
                  .toString(),
              javascriptMode: JavascriptMode.unrestricted,
            )
          ])
        : Container();
  }

  Widget _webWidgets(Map<String, dynamic> targetLocation) {
    return Stack(children: [
      WebView(
        gestureRecognizers: [
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        ].toSet(),
        initialUrl: Uri.dataFromString(
                homeMap(LocationBloc.position, targetLocation['latitude'],
                    targetLocation['longitude'], targetLocation['radius']),
                mimeType: 'text/html')
            .toString(),
        onWebViewCreated: (WebViewController wv) {
          webView = wv;
        },
      ),
      // StreamBuilder(
      //   stream: LocationBloc.locationLoading$,
      //   initialData: false,
      //   builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      //     if (!snapshot.hasData || snapshot.data == true) {
      //       return Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //     return Container();
      //   },
      // )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    LocationBloc.getValidLocation();

    return !kIsWeb
        ? StreamBuilder(
            stream: LocationBloc.serviceStatus$,
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

                          return _androidWidgets(snapshot.data!);
                        });
                  });
            })
        : FutureBuilder(
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
                      return _MapStatusWidget('Sedang mengambil radius absensi',
                          loading: true);
                    }

                    return _webWidgets(snapshot.data!);
                  });
            });
  }
}
