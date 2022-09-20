

import 'package:material_kit_flutter/widgets/spinner.dart';

import '../models/history-izin.dart';

class HistoryIzinBloc {
  late Map<String, dynamic> _historyIzinModel;
  Spinner sp = Spinner();

  HistoryIzinBloc() {
    _historyIzinModel = new HistoryIzinModel().toJson();
  }

  void setValue(String key, dynamic value) => _historyIzinModel[key] = value;

  String getValue(String key) => _historyIzinModel[key];

  Map<String, dynamic> getRawValue() => _historyIzinModel;
}
