import 'dart:async';
import 'dart:developer';

import 'package:SIMAt/screens/home/bloc/home-bloc.dart';
import 'package:SIMAt/screens/home/home.dart';
import 'package:SIMAt/utils/constants/Theme.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckInCard extends StatelessWidget {
  const CheckInCard({Key? key}) : super(key: key);

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Waktu saat ini",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  TimerDisplay()
                ],
              ),
            ),
          ),
          Container(
            height: 230,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: "Tekan tombol ",
                        ),
                        TextSpan(
                          text: "Check In ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "di bawah untuk menyatakan ",
                        ),
                        TextSpan(
                          text: "Waktu Masuk Kerja. ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "Pastikan ",
                        ),
                        TextSpan(
                          text: "Lokasi Anda ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "terdeteksi oleh sistem",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  CheckInOutRange()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckInOutRange extends StatefulWidget {
  const CheckInOutRange({Key? key}) : super(key: key);

  @override
  State<CheckInOutRange> createState() => _CheckInOutRange();
}

class _CheckInOutRange extends State<CheckInOutRange> {
  String _checkInOutRange(Map<String, dynamic> settings) {
    String checkInStart =
        (settings['check_in_start'] as String).substring(0, 5);
    String checkInEnd = (settings['check_in_end'] as String).substring(0, 5);

    String checkOutStart =
        (settings['check_out_start'] as String).substring(0, 5);
    String checkOutEnd = (settings['check_out_end'] as String).substring(0, 5);
    return "Range check in\t: $checkInStart - $checkInEnd WIB\nRange check out\t: $checkOutStart - $checkOutEnd WIB";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: HomeBloc().attendanceStatus$,
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        // inspect(snapshot.data);
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!["time_settings"] == null) {
          return Text("");
        }
        return Text(
          _checkInOutRange(snapshot.data!["time_settings"]),
          style: TextStyle(fontSize: 16),
        );
      },
    );
  }
}

class TimerDisplay extends StatefulWidget {
  const TimerDisplay({Key? key}) : super(key: key);

  @override
  State<TimerDisplay> createState() => _TimerDisplay();
}

class _TimerDisplay extends State<TimerDisplay> {
  Timer _timer = Timer(Duration(seconds: 10), () {});
  late StreamSubscription<bool> _sub;
  List<int> counts = [];
  // var time = 0;

  @override
  void initState() {
    _sub = timeBloc.reloadStream.listen((event) {
      getTime(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    _sub.cancel();
    super.dispose();
  }

  Future<void> getTime(BuildContext context) async {
    try {
      String result = await timeBloc.getTime(context);
      DateTime dateString = DateTime.parse(result).add(Duration(hours: 7));
      DateFormat formatter = DateFormat('H:mm:ss');
      timeBloc.updateDate(DateFormat("yyyy-MM-dd").format(dateString));
      _timer.cancel();
      startTimer(formatter.format(dateString));
    } catch (e) {
      handleError(e);
    }
  }

  void startTimer(String data) {
    counts = data.split(":").map((e) => int.parse(e)).toList();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        counts[2]++;

        if (counts[2] > 59) {
          counts[2] = 0;
          counts[1]++;
        }

        if (counts[1] > 59) {
          counts[1] = 0;
          counts[0]++;
        }

        if (counts[0] > 23) {
          counts[0] = 0;
        }

        timeBloc.updateCount(
            "${counts[0] < 10 ? "0" : ""}${counts[0]}:${counts[1] < 10 ? "0" : ""}${counts[1]}:${counts[2] < 10 ? "0" : ""}${counts[2]}");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: timeBloc.count$,
      initialData: "00:00:00",
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Text(
          snapshot.data! + " WIB",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
