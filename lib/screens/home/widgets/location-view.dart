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
  StreamSubscription<List<dynamic>>? positionStatus;

  Future<void> loadMaps(List<dynamic> data) async {
    // LocationBloc.updateLoadingStatus(true);
    Position? pos = data[0];
    Map<String, dynamic>? target = data[1];
    if (pos != null && target != null) {
      // LocationBloc.updatePosition(pos);
      if (webView != null) {
        await webView!.runJavascript(updatePosition(pos, target));
      }
    }
    // LocationBloc.updateLoadingStatus(false);
    // setState(() {

    // });
  }

  void reload() async {
    if (webView != null) {
      if (!kIsWeb) {
        // LocationBloc.updateLoadingStatus(true);
        await LocationBloc.getValidLocation().then((targetLocation) async {
          await webView!.loadUrl(Uri.dataFromString(
                  homeMap(LocationBloc.position!, targetLocation['latitude'],
                      targetLocation['longitude'], targetLocation['radius']),
                  mimeType: 'text/html')
              .toString());
        });
        // LocationBloc.updateLoadingStatus(false);
      } else {
        webView!.reload();
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      serviceStatus = LocationBloc.serviceStatus$.listen((event) {
        setState(() {});
      });

      positionStatus = CombineLatestStream.list(
              [LocationBloc.positionStatus$, LocationBloc.targetLocation$])
          .listen((value) {
        loadMaps(value);
      });
    } else {
      positionStatus = CombineLatestStream.list(
              [LocationBloc.positionStatus$, LocationBloc.targetLocation$])
          .listen((value) {
        if (webView != null) {
          webView!.loadUrl(Uri.dataFromString(
                  webMap(
                      value[0] as Position,
                      (value[1] as Map<String, dynamic>)['latitude'],
                      (value[1] as Map<String, dynamic>)['longitude'],
                      (value[1] as Map<String, dynamic>)['radius']),
                  mimeType: 'text/html')
              .toString());
        }
      });
    }
  }

  @override
  void dispose() {
    if (serviceStatus != null) serviceStatus!.cancel();
    if (positionStatus != null) positionStatus!.cancel();
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
                homeMap(LocationBloc.position!, targetLocation['latitude'],
                    targetLocation['longitude'], targetLocation['radius']),
                mimeType: 'text/html')
            .toString(),
        javascriptMode: JavascriptMode.unrestricted,
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

  Widget _webWidgets(Map<String, dynamic> targetLocation) {
    return Stack(children: [
      WebView(
        gestureRecognizers: [
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        ].toSet(),
        initialUrl: Uri.dataFromString(
                webMap(LocationBloc.position!, targetLocation['latitude'],
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

  Future<List> _getLocationStatus() async {
    List items = [];
    List<Future> futures = [
      // LocationBloc.isLocationOn,
      LocationBloc.getValidLocation()
    ];

    await Future.wait(futures.map((e) {
      return e.then((value) {
        items.add(value);
      });
    }).toList());
    // await Future.wait(futures.map((item) {
    //   finalItem = await item;
    //   finalItems.add(finalItem)
    // }).toList())

    return items;
  }

  @override
  Widget build(BuildContext context) {
    LocationBloc.getValidLocation();
    return StreamBuilder(
        stream: LocationBloc.serviceStatus$,
        builder: (BuildContext context,
            AsyncSnapshot<ServiceStatus> serviceStatusSnapshot) {
          if (!serviceStatusSnapshot.hasData ||
              serviceStatusSnapshot.data == ServiceStatus.disabled) {
            return _MapStatusWidget('Hidupkan Akses Lokasi');
          }

          return StreamBuilder(
              stream: LocationBloc.positionStatus$,
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
                  if (!snapshot.hasData || snapshot.data == null || snapshot.data?['latitude'] == null) {
                    return _MapStatusWidget(
                        'Sedang mengambil radius absensi',
                        loading: true);
                  }

                  return kIsWeb
                      ? _webWidgets(snapshot.data!)
                      : _androidWidgets(snapshot.data!);
                  
              });
        });
    });
  }
}
