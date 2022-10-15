import 'dart:async';

import 'package:rxdart/rxdart.dart';

class CheckInBloc {
  late BehaviorSubject<bool> _isTimeValid;

  CheckInBloc() {
  }

  void init() {
    _isTimeValid = BehaviorSubject.seeded(false);
  }

  void updateTimeValidity(bool value) {
    _isTimeValid.sink.add(value);
  }

  Stream<bool> get isTimeValid$ => _isTimeValid.asBroadcastStream();

  bool isTimeValid([String? date, String? start, String? end, String? current]) {
    try {
      DateTime _start = DateTime.parse("${date}T$start");
      DateTime _end = DateTime.parse("${date}T$end");
      DateTime _curr = DateTime.parse("${date}T$current");
      return !(_curr.isBefore(_start) || _curr.isAfter(_end));
    } catch (e) {
      return false;
    }
  }
}