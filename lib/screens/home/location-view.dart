import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_kit_flutter/utils//iframe/iframe.dart';
import 'package:material_kit_flutter/screens/home/bloc/location-bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:material_kit_flutter/utils/constants/Theme.dart';

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
  WebViewController? webView;
  LocationBloc locationBloc = new LocationBloc(); 
  late StreamSubscription<ServiceStatus> serviceStatus;
  late StreamSubscription<Position> positionStatus;
  bool findLocationClicked = false;

  Future<void> loadMaps(Position event) async {
    await webView?.runJavascript(redrawMaps(event.latitude, event.longitude));
    locationBloc.updateLoadingStatus(false);
    // setState(() {
      
    // });
  }

  void reload() async {
    if(!locationBloc.isLoading) {
      locationBloc.updateLoadingStatus(true);
      await locationBloc.getPosition.then(loadMaps);
    }
  }

  @override
  void initState() {
    super.initState();
    locationBloc.initLocation();
    serviceStatus = locationBloc.serviceStatusStream$.listen((event) { 
      setState(() {
        
      });
    });

    positionStatus = locationBloc.positionStream$.distinct().listen(loadMaps);
  }

  @override 
  void dispose() {
    serviceStatus.cancel();
    positionStatus.cancel();
    // locationBloc.dispose();
    super.dispose();
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
            const x2 = 3.590723972268678;
            const y2 = 98.68159334599628;
            const zoom = 15;
            return Stack(
              children: [
                // https://maps.google.com/maps?q=${currentLocation!!.latitude},${currentLocation!!.longitude}&z=15&output=embed
                AbsorbPointer(
                  child: WebView(
                    gestureRecognizers: [
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    ].toSet(),
                    onWebViewCreated: (WebViewController wv) {
                      webView = wv;
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
                            html,body{
                              margin: 0px;
                              height: 100%;
                              width: 100%;
                              overflow: hidden;
                            }
                            iframe{
                              height: 100%;
                              width: 100%;
                            }
                          </style>
                        </head>
                        <body>
                          <iframe id="embed-maps" height="auto" frameBorder="0" src="https://maps.google.com/maps?q=${snapshot.data!.latitude},${snapshot.data!.longitude}&z=15&output=embed"></iframe>
                        </body>
                        <script>

                          let iframe = document.getElementById('embed-maps');
                          x1 = ${snapshot.data!.latitude};
                          y1 = ${snapshot.data!.longitude};

                          x2 = $x2;
                          y2 = $y2;

                          zoom = $zoom;
                          const meterPerPx = (lat, zoom) => {
                            return 156543.03392 * Math.cos(lat * Math.PI / 180) / Math.pow(2, zoom)
                          }
                          
                          // return [x diff, y diff]
                          const distanceMeter = (x1, y1, x2, y2) => {
                            function toRadians(value) {
                              return value * Math.PI / 180
                            }
                          
                            var R = 6371.0710
                            var rlat1 = toRadians(x1) // Convert degrees to radians
                            var rlat2 = toRadians(x2) // Convert degrees to radians
                            var difflat = rlat2 - rlat1 // Radian difference (latitudes)
                            var difflon = toRadians(y2 - y1) // Radian difference (longitudes)
                            return 2 * R * Math.asin(Math.sqrt(Math.sin(difflat / 2) * Math.sin(difflat / 2) + Math.cos(rlat1) * Math.cos(rlat2) * Math.sin(difflon / 2) * Math.sin(difflon / 2))) * 1000
                          }; 

                          const newCanvas = () => {
                            let canvas = document.createElement('canvas');
                            canvas.style.position = 'absolute';
                            const body = document.body;
                            body.insertAdjacentElement('afterbegin', canvas);
                            return canvas;
                          }

                          // diameter in meter
                          const newPoint = (x2, y2, diameter) => {
                            let canvas = newCanvas();
                          
                            const mPerPx = meterPerPx(x1, zoom);
                            const jarak = distanceMeter(x1,y1,x2,y2)
                            const R = Math.ceil((diameter / 2) / mPerPx); 
                            const S  = (R * 2) + 5;

                            canvas.setAttribute('width', S);
                            canvas.setAttribute('height', S);

                            const dy = ((x1 - x2) * 110132) / mPerPx;
                            const dx = (Math.sqrt(Math.pow(jarak, 2) - Math.pow(dy, 2))) / mPerPx;

                            canvas.style.left = 'calc(50% + ' + dx + 'px - ' + R + 'px)';
                            canvas.style.top = 'calc(50% + ' + dy + 'px - ' + R + 'px)';

                            if (canvas.getContext) {
                              var ctx = canvas.getContext('2d'); 
                              var X = canvas.width / 2;
                              var Y = canvas.height / 2;
                              ctx.beginPath();
                              ctx.arc(X, Y, R, 0, 2 * Math.PI, false);
                              ctx.lineWidth = 1.5;
                              ctx.strokeStyle = '#FF0000';
                              ctx.fillStyle = '#00000022'
                              ctx.stroke();
                              ctx.fill();
                            }
                          }
                          newPoint(x1, y1, 1000);
                        </script>
                      </html>""", 
                      mimeType: 'text/html'
                    ).toString(),
                    javascriptMode: JavascriptMode.unrestricted,
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