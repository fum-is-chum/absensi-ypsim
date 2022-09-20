import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_kit_flutter/screens/History-Izin/bloc/history-izin-bloc.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/widgets/drawer.dart';
import 'package:material_kit_flutter/widgets/history-izin-item.dart';

final Map<String, Map<String, String>> homeCards = {
  "Makeup": {
    "title": "Find the cheapest deals on our range...",
    "image":
        "https://images.unsplash.com/photo-1515709980177-7a7d628c09ba?crop=entropy&w=840&h=840&fit=crop",
    "price": "220"
  },
};

final historyIzinBloc = new HistoryIzinBloc();

class HistoryIzin extends StatelessWidget {
  // final GlobalKey _scaffoldKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Riwayat Izin",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          elevation: 0,
          backgroundColor: MaterialColors.bgColorScreen,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        // key: _scaffoldKey,
        drawer: MaterialDrawer(currentPage: "History Izin"),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.black54,
                        blurRadius: 8.0,
                        offset: Offset(0.0, 0.75))
                  ], color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: TanggalField(),
                        width: MediaQuery.of(context).size.width / 2.3,
                      ),
                      SizedBox(width: 20),
                      SizedBox(
                        child: TanggalField(isAkhir: true),
                        width: MediaQuery.of(context).size.width / 2.3,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      HistoryIzinItem(
                        date: "Sabtu, 14 Mei 2022",
                        mulai: "15 Mei 2022",
                        selesai: "20 Mei 2022",
                        status: "Diterima",
                        tap: () {
                          Navigator.pushReplacementNamed(
                              context, '/history_izin_detail');
                        },
                      ),
                      SizedBox(height: 12),
                      HistoryIzinItem(
                        date: "Sabtu, 14 Mei 2022",
                        mulai: "15 Mei 2022",
                        selesai: "20 Mei 2022",
                        status: "Menunggu",
                        tap: () {
                          Navigator.pushReplacementNamed(
                              context, '/history_izin_detail');
                        },
                      ),
                      SizedBox(height: 12),
                      HistoryIzinItem(
                        date: "Sabtu, 14 Mei 2022",
                        mulai: "15 Mei 2022",
                        selesai: "20 Mei 2022",
                        status: "Ditolak",
                        tap: () {
                          Navigator.pushReplacementNamed(
                              context, '/history_izin_detail');
                        },
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class TanggalField extends StatefulWidget {
  final bool isAkhir;
  TanggalField({Key? key, this.isAkhir = false}) : super(key: key);

  @override
  _TanggalField createState() => _TanggalField();
}

class _TanggalField extends State<TanggalField> {
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _controller.text = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(historyIzinBloc.getValue('tanggalAkhir')));
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: _controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: widget.isAkhir ? "Tanggal Akhir" : "Tanggal Awal",
          suffixIcon: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.date_range),
              // color: MaterialColors.muted,
              onPressed: () {
                showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(
                            historyIzinBloc.getValue('tanggalAwal')),
                        firstDate: widget.isAkhir
                            ? DateTime.parse(
                                historyIzinBloc.getValue('tanggalAwal'))
                            : DateTime.fromMillisecondsSinceEpoch(0),
                        lastDate: DateTime(DateTime.now().year + 10))
                    .then((DateTime? value) {
                  if (value != null) {
                    historyIzinBloc.setValue(
                        widget.isAkhir ? 'tanggalAkhir' : 'tanggalAwal',
                        DateFormat('yyyy-MM-dd').format(value).toString());
                    _controller.text = DateFormat('yyyy-MM-dd').format(value);
                    setState(() {});
                  }
                });
              }),
          hintText: widget.isAkhir ? "Tanggal Akhir" : "Tanggal Awal",
          border: OutlineInputBorder(),
        ),
        onTap: () {
          showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.parse(historyIzinBloc.getValue('tanggalAwal')),
                  firstDate: widget.isAkhir
                      ? DateTime.parse(historyIzinBloc.getValue('tanggalAwal'))
                      : DateTime.fromMillisecondsSinceEpoch(0),
                  lastDate: DateTime(DateTime.now().year + 10))
              .then((DateTime? value) {
            if (value != null) {
              historyIzinBloc.setValue(
                  widget.isAkhir ? 'tanggalAkhir' : 'tanggalAwal',
                  DateFormat('yyyy-MM-dd').format(value).toString());
              _controller.text = DateFormat('yyyy-MM-dd').format(value);
              setState(() {});
            }
          });
        });
  }
}
