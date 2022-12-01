// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:SIMAt/utils//iframe/iframe.dart';
// import 'package:SIMAt/screens/home/bloc/location-bloc.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// import 'package:SIMAt/utils/constants/Theme.dart';

// final LocationBloc locationBloc = LocationBloc(); 
// class LocationView extends StatefulWidget {
//   LocationView({Key? key}) : super(key: key);
//   @override
//   _LocationView createState() => _LocationView();
// }

// class _LocationView extends State<LocationView> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   GlobalKey<_MyMapView> mapKey = GlobalKey();
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//         elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(8.0)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width,
//             decoration: BoxDecoration(
//               color: MaterialColors.newPrimary,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(8.0),
//                 topRight: Radius.circular(8.0),
//               ),
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.location_on,
//                         color: Colors.white,
//                       ),
//                       SizedBox(width: 8),
                      
//                       StreamBuilder(
//                         stream: locationBloc.targetLocation$,
//                         builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> targetLocation) {
//                           bool targetLocationIsValid = targetLocation.hasData && targetLocation.data != null && targetLocation.data!['latitude'] != null;
//                           return Text(
//                             "Lokasi Anda ${targetLocationIsValid ? locationBloc.getDistance : 0}m",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                             ),
//                           );
//                         }
//                       )
//                     ],
//                   ),
//                   Material(
//                     shape: CircleBorder(),
//                     color: Colors.transparent,
//                     child: IconButton(
//                       onPressed: () {
//                         mapKey.currentState!.reload();
//                       },
//                       splashRadius: 20.0,
//                       // splashColor: Colors.grey,
//                       padding: EdgeInsets.all(8),
//                       constraints: BoxConstraints(),
//                       icon: const Icon(Icons.replay_outlined),
//                       color: Colors.white,
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             width: MediaQuery.of(context).size.width,
//             height: 400,
//             child: MyMapView(key: mapKey)
//           )
//         ],
//       ),
//     );
//   }
// }

// class MyMapView extends StatefulWidget {
//   MyMapView({Key? key}): super(key: key);

//   @override
//   _MyMapView createState() => _MyMapView();
// }

// class _MyMapView extends State<MyMapView> {
//   WebViewController? webView;
//   late StreamSubscription<ServiceStatus> serviceStatus;
//   late StreamSubscription<List<dynamic>> positionStatus;

//   Future<void> loadMaps(List<dynamic> data) async {
//     Position? pos = data[0];
//     Map<String, dynamic> target = data[1];
//     if(pos != null) {
//         locationBloc.updatePosition(pos);
//       if(webView != null ) {
//         await webView!.runJavascript(redrawMaps(
//           pos.latitude,
//           pos.longitude,
//           target['latitude'],
//           target['longitude'],
//           target['radius']
//         ));
//       }
//     }
//     locationBloc.updateLoadingStatus(false);
//     // setState(() {
      
//     // });
//   }

//   void reload() async {
//     if(!locationBloc.isLoading) {
//       locationBloc.updateLoadingStatus(true);
//       await Future.wait([
//         locationBloc.getPosition,
//         locationBloc.getValidLocation()
//       ]).then(loadMaps);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     serviceStatus = locationBloc.serviceStatusStream$.listen((event) { 
//       setState(() {
        
//       });
//     });
//     positionStatus = CombineLatestStream.list([
//       locationBloc.positionStream$,
//       locationBloc.targetLocation$
//     ]).listen(loadMaps);
//   }

//   @override 
//   void dispose() {
//     serviceStatus.cancel();
//     positionStatus.cancel();
//     super.dispose();
//   }

//   @override 
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: Future.wait([
//         locationBloc.isLocationOn,
//         locationBloc.getPosition,
//         locationBloc.getValidLocation()
//       ]),
//       builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
//         int status = locationBloc.mapViewValid(snapshot.data);
//         if(!snapshot.hasData || status != 1) {
//           return Center(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 CircularProgressIndicator(),
//                 const SizedBox(height: 8,),
//                 Text(
//                   status == -1 ? 'Hidupkan Akses Lokasi' :
//                   status == -2 ? 'Sedang mengambil lokasi gps' :
//                   status == -3 ? 'Sedang membuka map' :
//                   ''
//                 )
//               ],
//             ),
//           );
//         }

//         Position position = snapshot.data![1];
//         Map<String, dynamic> targetLocation = snapshot.data![2];
//         return Stack(
//           children: [
//             AbsorbPointer(
//               child: WebView(
//                 gestureRecognizers: [
//                   Factory<OneSequenceGestureRecognizer>(
//                     () => EagerGestureRecognizer(),
//                   ),
//                 ].toSet(),
//                 onWebViewCreated: (WebViewController wv) {
//                   webView = wv;
//                 },
//                 initialUrl: Uri.dataFromString("""
//                 <!DOCTYPE html>
//                   <html lang="en">
//                     <head>
//                       <meta charset="UTF-8">
//                       <meta http-equiv="X-UA-Compatible" content="IE=edge">
//                       <meta name="viewport" content="width=device-width, initial-scale=1.0">
//                       <style>
//                         *{
//                           box-sizing: border-box;
//                         }
//                         html,body{
//                           margin: 0px;
//                           height: 100%;
//                           width: 100%;
//                           overflow: hidden;
//                         }
//                         iframe{
//                           height: 100%;
//                           width: 100%;
//                         }
//                       </style>
//                     </head>
//                     <body>
//                       <iframe id="embed-maps" height="auto" frameBorder="0"></iframe>
//                     </body>
//                     <script>
//                       const meterPerPx = (lat, zoom) => {
//                         return 156543.03392 * Math.cos(lat * Math.PI / 180) / Math.pow(2, zoom)
//                       }
                      
//                       // return [x diff, y diff]
//                       const distanceMeter = (x1, y1, x2, y2) => {
//                         function toRadians(value) {
//                           return value * Math.PI / 180
//                         }
                      
//                         var R = 6371.0710
//                         var rlat1 = toRadians(x1) // Convert degrees to radians
//                         var rlat2 = toRadians(x2) // Convert degrees to radians
//                         var difflat = rlat2 - rlat1 // Radian difference (latitudes)
//                         var difflon = toRadians(y2 - y1) // Radian difference (longitudes)
//                         return 2 * R * Math.asin(Math.sqrt(Math.sin(difflat / 2) * Math.sin(difflat / 2) + Math.cos(rlat1) * Math.cos(rlat2) * Math.sin(difflon / 2) * Math.sin(difflon / 2))) * 1000
//                       }; 

//                       const newCanvas = () => {
//                         let canvas = document.createElement('canvas');
//                         canvas.style.position = 'absolute';
//                         const body = document.body;
//                         body.insertAdjacentElement('afterbegin', canvas);
//                         return canvas;
//                       }

//                       // diameter in meter
//                       const newPoint = (x2, y2, diameter) => {
//                         let canvas = newCanvas();
                      
//                         const mPerPx = meterPerPx(x1, zoom);
//                         const jarak = distanceMeter(x1,y1,x2,y2)
//                         const R = Math.ceil((diameter / 2) / mPerPx); 
//                         const S  = (R * 2) + 4;

//                         canvas.setAttribute('width', S);
//                         canvas.setAttribute('height', S);

//                         const dy = ((x1 - x2) * 111321) / mPerPx;
//                         const dx = (Math.sqrt(Math.pow(jarak, 2) - Math.pow(0, 2))) / mPerPx * (y1 > y2 ? -1 : 1);
//                         const xOffset = (Math.abs(dx) - (Math.sqrt(Math.pow(dx,2) - Math.pow(dy,2)))) * (y1 > y2 ? 1 : -1);
//                         // dx -= dy;

//                         const _dx = dx - R + xOffset;
//                         const _dy = dy - R

//                         canvas.style.left = 'calc(50% + ' + _dx + 'px)';
//                         canvas.style.top = 'calc(50% + ' + _dy + 'px)';

//                         if (canvas.getContext) {
//                           const ctx = canvas.getContext('2d'); 
//                           const X = canvas.width / 2;
//                           const Y = canvas.height / 2;
//                           ctx.beginPath();
//                           ctx.arc(X, Y, R, 0, 2 * Math.PI, false);
//                           ctx.lineWidth = 1.5;
//                           ctx.strokeStyle = '#FF0000';
//                           ctx.fillStyle = '#00000022'
//                           ctx.stroke();
//                           ctx.fill();
//                         }
//                       }

//                       let x1 = ${position.latitude};
//                       let y1 = ${position.longitude};

//                       let x2 = ${targetLocation['latitude']};
//                       let y2 = ${targetLocation['longitude']};

//                       // let x2 = 3.597036314282042;
//                       // let y2 = 98.67109562745719;

//                       let D = distanceMeter(x1,y1,x2,y2) * 2;
//                       let radius = ${targetLocation['radius']} * 2
//                       const ratios = [
//                         1128.497220,
//                         2256.994440,
//                         4513.988880,
//                         9027.977761,
//                         18055.955520,
//                         36111.911040,
//                         72223.822090,
//                         144447.644200,
//                         288895.288400,
//                         577790.576700,
//                         1155581.153000,
//                         2311162.307000,
//                         4622324.614000,
//                         9244649.227000,
//                         18489298.450000,
//                         36978596.910000,
//                         73957193.820000,
//                         147914387.600000,
//                         295828775.300000,
//                         591657550.500000
//                       ]

//                       let zoom = 19 - ratios.findIndex((d) => {
//                         return d >= D*6
//                       });
//                       // let zoom = 15;
//                       let iframe = document.getElementById('embed-maps');
//                       iframe.setAttribute('src', 'https://maps.google.com/maps?q=' + x1 + ',' + y1 + '&z=' + zoom + '&output=embed');

//                       newPoint(x2, y2, radius);
//                       newPoint(x2, y2, 4);
//                     </script>
//                   </html>""", 
//                   mimeType: 'text/html'
//                 ).toString(),
//                 javascriptMode: JavascriptMode.unrestricted,
//               ),
//             ),
//             StreamBuilder(
//               stream: locationBloc.locationLoading$,
//               builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
//                 if(!snapshot.hasData || snapshot.data == true) {
//                   return Center(child: CircularProgressIndicator(),);
//                 }
//                 return Stack();
//               },
//             )
//           ],
//         );
//       }
//     );
//   }
// }