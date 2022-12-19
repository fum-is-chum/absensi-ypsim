import 'package:SIMAt/screens/riwayat-presensi/bloc/riwayat-presensi-bloc.dart';
import 'package:SIMAt/screens/riwayat-presensi/models/riwayat-presensi-model.dart';
import 'package:SIMAt/screens/riwayat-presensi/riwayat-presensi-detail.dart';
import 'package:SIMAt/screens/riwayat-presensi/widgets/riwayat-presensi-item.dart';
import 'package:SIMAt/utils/constants/Theme.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:SIMAt/widgets/drawer.dart';
import 'package:SIMAt/widgets/spinner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

late RiwayatPresensiBloc riwayatPresensiBloc;

class RiwayatPresensi extends StatefulWidget {
  RiwayatPresensi({Key? key}) : super(key: key);

  @override
  State<RiwayatPresensi> createState() => _RiwayatPresensi();
}

class _RiwayatPresensi extends State<RiwayatPresensi> {
  @override
  void initState() {
    riwayatPresensiBloc = new RiwayatPresensiBloc();
    super.initState();
  }

  @override
  void dispose() {
    // RiwayatPresensiBloc.dispose();
    super.dispose();
  }

  // late Future<List<dynamic>> Function() data =
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
          drawer: MaterialDrawer(
            currentPage: "Riwayat Presensi",
          ),
          backgroundColor: MaterialColors.bgColorScreen,
          body: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  forceElevated: true,
                  elevation: 2,
                  title: Text("Riwayat Presensi",
                      style: TextStyle(color: Colors.black)),
                  backgroundColor: MaterialColors.bgColorScreen,
                  iconTheme: IconThemeData(color: Colors.black),
                  pinned: true,
                  // floating: true,
                  // snap: false,
                  expandedHeight: 128 + (kIsWeb ? 16 : 0),
                  collapsedHeight: 128 + (kIsWeb ? 16 : 0),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                        // duration: Duration(milliseconds: 500),
                        padding: EdgeInsets.fromLTRB(0, 72, 0, 0),
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
                        )),
                  ),
                ),
                SliverToBoxAdapter(
                  child: HistoryList()
                )
              ],
            ),
          )),
    );
  }
}

class HistoryList extends StatefulWidget {
  const HistoryList({Key? key}) : super(key: key);

  @override
  State<HistoryList> createState() => _ListWidget();
}

class _ListWidget extends State<HistoryList> {
  GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();
  List<dynamic> data = [];
  String? err;

  _reset() {
    int len = data.length;
    if (len > 0) {
      for (int i = len - 1; i >= 0; i--) {
        data.removeAt(i);
        _listKey.currentState?.removeItem(
            i,
            (context, animation) => SizeTransition(
                  sizeFactor: animation,
                  child: Container(),
                ),
            duration: const Duration(seconds: 0));
      }
    }
  }

  _getData() async {
    _reset();
    try {
      List<dynamic> newData = await riwayatPresensiBloc.getAttendances();
      if (newData.length == 0)
        throw 'Tidak ada data';
      else {
        err = null;
        for (int i = 0; i < newData.length; i++) {
          data.insert(i, newData[i]);
          _listKey.currentState?.insertItem(i);
          await Future<void>.delayed(const Duration(milliseconds: 30));
        }
      }
    } catch (e) {
      handleError(e);
    }
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    
    return FadeTransition(
      opacity: animation,
      child: HistoryPresensiItem(
        item: RiwayatPresensiModel.fromJson(data[index]),
        tap: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            // if(DateTime.parse(data[index]['startDate']).isBefore())
            return RiwayatPresensiDetail(
                item: RiwayatPresensiModel.fromJson(data[index]));
          }));
          _getData();
        },
      ),
    );
  }

  @override
  void initState() {
    riwayatPresensiBloc.init();

    // _getData().then((value) => setState((){}));
    riwayatPresensiBloc.reloadStream.listen((event) {
      _getData().then((value) => setState(() {}));
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    riwayatPresensiBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // padding: const EdgeInsets.only(bottom: 16),
        width: double.infinity,
        height: MediaQuery.of(context).size.height - 128 - 36,
        child: RefreshIndicator(
            onRefresh: () {
              return _getData();
            },
            child: StreamBuilder<bool>(
                stream: riwayatPresensiBloc.loadingStream,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (!snapshot.hasData || (snapshot.hasData && snapshot.data!))
                    return loadingSpinner();

                  if (err != null)
                    return CustomScrollView(
                      slivers: [
                       SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              err!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    );

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: const BouncingScrollPhysics()),
                    slivers: [
                      SliverAnimatedList(
                        key: _listKey,
                        itemBuilder: _buildItem,
                        initialItemCount: data.length,
                      )
                    ],
                  );
                })));
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
    _controller.text = widget.isAkhir
        ? riwayatPresensiBloc.filter.endDate!
        : riwayatPresensiBloc.filter.startDate!;
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
                        initialDate: DateTime.parse(widget.isAkhir &&
                                DateTime.parse(riwayatPresensiBloc.filter.startDate!)
                                    .isBefore(DateTime.parse(
                                        riwayatPresensiBloc.filter.endDate!))
                            ? riwayatPresensiBloc.filter.endDate!
                            : riwayatPresensiBloc.filter.startDate!),
                        firstDate: widget.isAkhir
                            ? DateTime.parse(riwayatPresensiBloc.filter.startDate!)
                            : DateTime(2022),
                        lastDate: DateTime(DateTime.now().year + 10))
                    .then((DateTime? value) {
                  if (value != null) {
                    if (widget.isAkhir) {
                      riwayatPresensiBloc.filter.endDate = formatDateOnly(value);
                    } else {
                      riwayatPresensiBloc.filter.startDate = formatDateOnly(value);
                    }
                    _controller.text = formatDateOnly(value);
                    riwayatPresensiBloc.triggerReload();
                    // widget.key.
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
                  initialDate: DateTime.parse(riwayatPresensiBloc.filter.startDate!),
                  firstDate: widget.isAkhir
                      ? DateTime.parse(riwayatPresensiBloc.filter.startDate!)
                      : DateTime.fromMillisecondsSinceEpoch(0),
                  lastDate: DateTime(DateTime.now().year + 10))
              .then((DateTime? value) {
            if (value != null) {
              if (widget.isAkhir) {
                riwayatPresensiBloc.filter.endDate = formatDateOnly(value);
              } else {
                riwayatPresensiBloc.filter.startDate = formatDateOnly(value);
              }
              _controller.text = formatDateOnly(value);
              setState(() {});
            }
          });
        });
  }
}
