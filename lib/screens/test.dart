import 'dart:async';

import 'package:SIMAt/screens/test-bloc.dart';
import 'package:SIMAt/utils/constants/Theme.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class TestPage extends StatelessWidget {
  TestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      // key: _scaffoldKey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: PositionStatus()
      )
    );
  }
}
class PositionStatus extends StatefulWidget {
  PositionStatus({Key? key}) : super(key: key);

  @override
  State<PositionStatus> createState() => _PositionStatus();
}

class _PositionStatus extends State<PositionStatus> {
  @override
  void initState() {
    super.initState();
    TestBloc.init();
  }

  @override
  void dispose() {
    TestBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(
      height: 10,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Column(
        children: [
          StreamBuilder(
            stream: TestBloc.serviceStatus$,
            builder: (BuildContext context, AsyncSnapshot<ServiceStatus> snapshot) {
              if(!snapshot.hasData || snapshot.data == ServiceStatus.disabled) {
                return Text('Service disabled');
              }
              
              return Text('Service Enabled');
            },
          ),
          sizedBox,
          StreamBuilder(
            stream: TestBloc.positionStatus$,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if(!snapshot.hasData || snapshot.data == null) {
                return Text('Location Off');
              }
              
              if(snapshot.data == -1) {
                return Text('Getting Location');
              }

              return Text(
                "${snapshot.data!.latitude}, ${snapshot.data!.longitude}"
              );
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: (TestBloc.positionStreamSubscription == null ||
                    TestBloc.positionStreamSubscription!.isPaused)
                ? const Icon(Icons.play_arrow)
                : const Icon(Icons.pause),
            onPressed: () {
              TestBloc.positionStreamStarted = !TestBloc.positionStreamStarted;
              TestBloc.toggleListening();
            },
            tooltip: (TestBloc.positionStreamSubscription == null)
                ? 'Start position updates'
                : TestBloc.positionStreamSubscription!.isPaused
                    ? 'Resume'
                    : 'Pause',
            backgroundColor: TestBloc.determineButtonColor(),
          ),
          sizedBox,
          FloatingActionButton(
            child: const Icon(Icons.my_location),
            onPressed: () {
              TestBloc.getCurrentPosition();
            },
          ),
          sizedBox,
          FloatingActionButton(
            child: const Icon(Icons.bookmark),
            onPressed: () {
              TestBloc.getLastKnownPosition();
            },
          ),
        ],
      ),
    );
  }
}

enum _PositionItemType {
  log,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}