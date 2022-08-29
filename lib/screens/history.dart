import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_kit_flutter/bloc/history-bloc.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/screens/history-dummy.dart';

import '../widgets/drawer.dart';
import '../widgets/history-item.dart';

final Map<String, Map<String, String>> homeCards = {
  "Makeup": {
    "title": "Find the cheapest deals on our range...",
    "image":
        "https://images.unsplash.com/photo-1515709980177-7a7d628c09ba?crop=entropy&w=840&h=840&fit=crop",
    "price": "220"
  },
};

final historyBloc = new HistoryBloc();

class History extends StatefulWidget {
  final List<Map<String,dynamic>> log = list;
  History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _History();
}

class _History extends State<History> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MaterialDrawer(currentPage: "History"),
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
                    return HistoryItem(
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
    _controller.text = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(historyBloc.getValue('tanggalAkhir')));
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
                            DateTime.parse(historyBloc.getValue('tanggalAwal')),
                        firstDate: widget.isAkhir
                            ? DateTime.parse(
                                historyBloc.getValue('tanggalAwal'))
                            : DateTime.fromMillisecondsSinceEpoch(0),
                        lastDate: DateTime(DateTime.now().year + 10))
                    .then((DateTime? value) {
                  if (value != null) {
                    historyBloc.setValue(
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
                      DateTime.parse(historyBloc.getValue('tanggalAwal')),
                  firstDate: widget.isAkhir
                      ? DateTime.parse(historyBloc.getValue('tanggalAwal'))
                      : DateTime.fromMillisecondsSinceEpoch(0),
                  lastDate: DateTime(DateTime.now().year + 10))
              .then((DateTime? value) {
            if (value != null) {
              historyBloc.setValue(
                  widget.isAkhir ? 'tanggalAkhir' : 'tanggalAwal',
                  DateFormat('yyyy-MM-dd').format(value).toString());
              _controller.text = DateFormat('yyyy-MM-dd').format(value);
              setState(() {});
            }
          });
        });
  }
}
