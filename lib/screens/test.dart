// import 'package:SIMAt/screens/home/bloc/location-bloc.dart';
// import 'package:SIMAt/utils/constants/Theme.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// class TestPage extends StatelessWidget {
//   TestPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text(
//             "Home",
//             style: TextStyle(
//               color: Colors.black,
//             ),
//           ),
//           backgroundColor: Colors.white,
//           iconTheme: IconThemeData(color: Colors.black),
//         ),
//         backgroundColor: MaterialColors.bgColorScreen,
//         // key: _scaffoldKey,
//         body: Container(
//             height: MediaQuery.of(context).size.height,
//             width: double.infinity,
//             child: PositionStatus()));
//   }
// }

// class PositionStatus extends StatefulWidget {
//   PositionStatus({Key? key}) : super(key: key);

//   @override
//   State<PositionStatus> createState() => _PositionStatus();
// }

// class _PositionStatus extends State<PositionStatus> {
//   @override
//   void initState() {
//     super.initState();
//     LocationBloc.init();
//   }

//   @override
//   void dispose() {
//     LocationBloc.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const sizedBox = SizedBox(
//       height: 10,
//     );

//     return Scaffold(
//       backgroundColor: Theme.of(context).backgroundColor,
//       body: Column(
//         children: [
//           StreamBuilder(
//             stream: LocationBloc.serviceStatus$,
//             builder:
//                 (BuildContext context, AsyncSnapshot<ServiceStatus> snapshot) {
//               if (!snapshot.hasData ||
//                   snapshot.data == ServiceStatus.disabled) {
//                 return Text('Service disabled');
//               }

//               return Text('Service Enabled');
//             },
//           ),
//           sizedBox,
//           StreamBuilder(
//             stream: LocationBloc.positionStatus$,
//             builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//               if (!snapshot.hasData || snapshot.data == null) {
//                 return Text('Location Off');
//               }

//               if (snapshot.data == -1) {
//                 return Text('Getting Location');
//               }

//               return Text(
//                   "${snapshot.data!.latitude}, ${snapshot.data!.longitude}");
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//               child: (LocationBloc.positionStreamSubscription == null ||
//                       LocationBloc.positionStreamSubscription!.isPaused)
//                   ? const Icon(Icons.play_arrow)
//                   : const Icon(Icons.pause),
//               onPressed: () {
//                 LocationBloc.positionStreamStarted =
//                     !LocationBloc.positionStreamStarted;
//                 LocationBloc.toggleListening();
//               },
//               tooltip: (LocationBloc.positionStreamSubscription == null)
//                   ? 'Start position updates'
//                   : LocationBloc.positionStreamSubscription!.isPaused
//                       ? 'Resume'
//                       : 'Pause',
//               backgroundColor: Colors.green),
//           sizedBox,
//           FloatingActionButton(
//             child: const Icon(Icons.my_location),
//             onPressed: () {
//               LocationBloc.getCurrentPosition();
//             },
//           ),
//           sizedBox,
//           FloatingActionButton(
//             child: const Icon(Icons.bookmark),
//             onPressed: () {
//               LocationBloc.getLastKnownPosition();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// enum _PositionItemType {
//   log,
//   position,
// }

// class _PositionItem {
//   _PositionItem(this.type, this.displayValue);

//   final _PositionItemType type;
//   final String displayValue;
// }
