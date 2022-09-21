import 'package:flutter/material.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/screens/History-Izin/bloc/history-izin-bloc.dart';
import 'package:material_kit_flutter/screens/history-izin/history-izin-dummy.dart';
import 'package:material_kit_flutter/services/shared-service.dart';
import 'package:material_kit_flutter/widgets/drawer.dart';
import 'package:material_kit_flutter/widgets/history-izin-item.dart';

final historyIzinBloc = new HistoryIzinBloc();

class HistoryIzin extends StatefulWidget {
  final List<Map<String,dynamic>> log = list;
  HistoryIzin({Key? key}) : super(key: key);
  
  @override
  State<HistoryIzin> createState() => _HistoryIzin();
}

class _HistoryIzin extends State<HistoryIzin> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MaterialDrawer(currentPage: "History Izin",),
      backgroundColor: MaterialColors.bgColorScreen,
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              forceElevated: true,
              title: Text("Riwayat Izin",
                style: TextStyle(color: Colors.black)
              ),
              backgroundColor: MaterialColors.bgColorScreen,
              iconTheme: IconThemeData(color: Colors.black),
              pinned: true,
              snap: true,
              floating: true,
              expandedHeight: 144,
              flexibleSpace: FlexibleSpaceBar(
                background: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
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
                    return HistoryIzinItem(
                        date: widget.log[index]['date'],
                        mulai: widget.log[index]['mulai'],
                        selesai: widget.log[index]['selesai'],
                        status: widget.log[index]['status'],
                        tap: () {
                          Navigator.pushNamed(
                              context, widget.log[index]['link']);
                        },
                    );
                  },
                  childCount: widget.log.length,
                )
              )
            )
          ],
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
    _controller.text = formatDateOnly(historyIzinBloc.filter.startDate);
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
                            historyIzinBloc.filter.startDate!),
                        firstDate: widget.isAkhir
                            ? DateTime.parse(
                                historyIzinBloc.filter.startDate!)
                            : DateTime.fromMillisecondsSinceEpoch(0),
                        lastDate: DateTime(DateTime.now().year + 10))
                    .then((DateTime? value) {
                  if (value != null) {
                    if(widget.isAkhir) {
                      historyIzinBloc.filter.endDate = formatDateOnly(value);
                    } else {
                      historyIzinBloc.filter.startDate = formatDateOnly(value);
                    }
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
                  DateTime.parse(historyIzinBloc.filter.startDate!),
              firstDate: widget.isAkhir
                  ? DateTime.parse(historyIzinBloc.filter.startDate!)
                  : DateTime.fromMillisecondsSinceEpoch(0),
              lastDate: DateTime(DateTime.now().year + 10))
          .then((DateTime? value) {
        if (value != null) {
          if(widget.isAkhir) {
            historyIzinBloc.filter.endDate = formatDateOnly(value);
          } else {
            historyIzinBloc.filter.startDate = formatDateOnly(value);
          }
          _controller.text = formatDateOnly(value);
          setState(() {});
        }
      });
    });
  }
}
