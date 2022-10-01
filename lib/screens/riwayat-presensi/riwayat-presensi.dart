import 'package:absensi_ypsim/screens/riwayat-presensi/bloc/history-bloc.dart';
import 'package:flutter/material.dart';
import 'package:absensi_ypsim/utils/constants/Theme.dart';
import 'package:absensi_ypsim/screens/history-dummy.dart';
import 'package:absensi_ypsim/screens/riwayat-presensi/widgets/history-presensi-item.dart';
import 'package:absensi_ypsim/utils/services/shared-service.dart';
import 'package:absensi_ypsim/widgets/drawer.dart';

final historyPresensiBloc = new HistoryBloc();

class RiwayatPresensi extends StatefulWidget {
  final List<Map<String,dynamic>> log = list;
  RiwayatPresensi({Key? key}) : super(key: key);

  @override
  State<RiwayatPresensi> createState() => _History();
}

class _History extends State<RiwayatPresensi> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MaterialDrawer(currentPage: "Riwayat Presensi"),
      backgroundColor: MaterialColors.bgColorScreen,
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              forceElevated: true,
              title: Text("Riwayat Presensi",
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: MaterialColors.bgColorScreen,
              iconTheme: IconThemeData(color: Colors.black),
              pinned: true,
              // snap: true,
              // floating: true,
              expandedHeight: 144,
              collapsedHeight: 144,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  // duration: Duration(milliseconds: 500),
                  padding: EdgeInsets.only(top: 56 + 24),
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
                  )
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return HistoryPresensiItem(
                      date: widget.log[index]['date'],
                      checkIn: widget.log[index]['checkIn'],
                      checkOut: widget.log[index]['checkOut'],
                      status: widget.log[index]['status'],
                      tap: () {
                        Navigator.pushNamed(
                            context, widget.log[index]['link']);
                      },
                    );
                  },
                  childCount: widget.log.length,
                ),
              ),
            )
          ]
        ),
      )
    );
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
    _controller.text = formatDateOnly(historyPresensiBloc.getValue('tanggalAkhir'));
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
                        initialDate:
                            DateTime.parse(historyPresensiBloc.getValue('tanggalAwal')),
                        firstDate: widget.isAkhir
                            ? DateTime.parse(
                                historyPresensiBloc.getValue('tanggalAwal'))
                            : DateTime.fromMillisecondsSinceEpoch(0),
                        lastDate: DateTime(DateTime.now().year + 10))
                    .then((DateTime? value) {
                  if (value != null) {
                    historyPresensiBloc.setValue(
                        widget.isAkhir ? 'tanggalAkhir' : 'tanggalAwal',
                        formatDateOnly(value));
                    _controller.text = formatDateOnly(value);
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
                      DateTime.parse(historyPresensiBloc.getValue('tanggalAwal')),
                  firstDate: widget.isAkhir
                      ? DateTime.parse(historyPresensiBloc.getValue('tanggalAwal'))
                      : DateTime.fromMillisecondsSinceEpoch(0),
                  lastDate: DateTime(DateTime.now().year + 10))
              .then((DateTime? value) {
            if (value != null) {
              historyPresensiBloc.setValue(
                  widget.isAkhir ? 'tanggalAkhir' : 'tanggalAwal',
                  formatDateOnly(value));
              _controller.text = formatDateOnly(value);
              setState(() {});
            }
          });
        });
  }
}
