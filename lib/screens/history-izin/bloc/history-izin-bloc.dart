

import '../models/history-izin.dart';

class HistoryIzinBloc {
  List<HistoryIzinModel> _historyIzinModel = [];
  HistoryIzinFilter _filter = HistoryIzinFilter();

  HistoryIzinBloc();

  HistoryIzinFilter get filter => _filter;
}
