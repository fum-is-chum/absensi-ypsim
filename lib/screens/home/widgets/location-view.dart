import 'dart:async';

import 'package:absensi_ypsim/screens/home/bloc/location-bloc.dart';
import 'package:absensi_ypsim/utils//iframe/iframe.dart';
import 'package:absensi_ypsim/utils/constants/Theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter/webview_flutter.dart';

final LocationBloc locationBloc = LocationBloc(); 
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
                      
                      StreamBuilder(
                        stream: locationBloc.targetLocation$,
                        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> targetLocation) {
                          bool targetLocationIsValid = targetLocation.hasData && targetLocation.data != null && targetLocation.data!['latitude'] != null;
                          return Text(
                            "Lokasi Anda ${targetLocationIsValid ? locationBloc.getDistance : 0}m",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          );
                        }
                      )
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
  WebViewController? webView;
  late StreamSubscription<ServiceStatus> serviceStatus;
  StreamSubscription<List<dynamic>>? positionStatus;

  Future<void> loadMaps(List<dynamic> data) async {
    Position? pos = data[0];
    Map<String, dynamic> target = data[1];
    if(pos != null) {
      locationBloc.updatePosition(pos);
      if(webView != null ) {
        await webView!.runJavascript(updatePosition(pos, target));
      }
    }
    locationBloc.updateLoadingStatus(false);
    // setState(() {
      
    // });
  }

  void reload() async {
    if(webView != null) {
      Future.wait([
        locationBloc.getPosition,
        locationBloc.getValidLocation()
      ]).then((value) async {
        Map<String, dynamic> targetLocation = value[1] as Map<String, dynamic>;
        await webView!.loadUrl(
          Uri.dataFromString(homeMap(
            value[0] as Position,
            targetLocation['latitude'],
            targetLocation['longitude'],
            targetLocation['radius']
          ), 
          mimeType: 'text/html').toString()
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    serviceStatus = locationBloc.serviceStatusStream$.listen((event) { 
      setState(() {
        
      });
    });
    locationBloc.getPosition.then((value) {
      positionStatus = CombineLatestStream.list([
        locationBloc.positionStream$,
        locationBloc.targetLocation$
      ]).listen(loadMaps);
    });
  }

  @override 
  void dispose() {
    serviceStatus.cancel();
    if(positionStatus != null) positionStatus!.cancel();
    super.dispose();
  }

  /*
    data = [
      isLocationOn -> bool,
      getPosition -> Position,
      getValidLocation -> Map<String, dynamic>
    ]
  */
  int _mapViewValid(List<dynamic>? data) {
    if(data == null) return 0;
    if(data[0] == false) return -1;
    if((data[1] as Map<String, dynamic>?)?['latitude'] == null) return -2;
    return 1;
    // return
    //   data[0] == true &&
    //   (data[1] as Position?)?.latitude != null &&
    //   (data[2] as Map<String, dynamic>?)?['latitude'] != null
    // ;

  }

  @override 
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        locationBloc.isLocationOn,
        locationBloc.getValidLocation()
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        int status = _mapViewValid(snapshot.data);
        if(!snapshot.hasData || status != 1) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: (() {
                if(status == -1) {
                  return <Widget>[
                    Text('Hidupkan Akses Lokasi')
                  ];
                }
                return <Widget>[CircularProgressIndicator()];
              } ()),
            ),
          );
        }

        Map<String, dynamic> targetLocation = snapshot.data![1];
        return StreamBuilder(
          stream: locationBloc.positionStream$,
          initialData: locationBloc.getCurrentPosition,
          builder: (BuildContext context, AsyncSnapshot<Position> pos) {
            if(!pos.hasData || (pos.hasData && pos.data == null)) {
              return Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                WebView(
                  gestureRecognizers: [
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  ].toSet(),
                  onWebViewCreated: (WebViewController wv) {
                    webView = wv;
                  },
                  
                  initialUrl: Uri.dataFromString(homeMap(
                    pos.data!,
                    targetLocation['latitude'],
                    targetLocation['longitude'],
                    targetLocation['radius']
                  ), mimeType: 'text/html').toString(),
                  javascriptMode: JavascriptMode.unrestricted,
                ),
                StreamBuilder(
                  stream: locationBloc.locationLoading$,
                  builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if(!snapshot.hasData || snapshot.data == true) {
                      return Center(child: CircularProgressIndicator(),);
                    }
                    return Container();
                  },
                )
              ]
            );
          },
        );
      }
    );
  }
}