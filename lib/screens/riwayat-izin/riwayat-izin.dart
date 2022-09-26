import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/screens/riwayat-izin/bloc/riwayat-izin-bloc.dart';
import 'package:material_kit_flutter/screens/riwayat-izin/models/riwayat-izin.dart';
import 'package:material_kit_flutter/screens/riwayat-izin/riwayat-izin-detail.dart';
import 'package:material_kit_flutter/screens/riwayat-izin/riwayat-izin-edit.dart';
import 'package:material_kit_flutter/screens/riwayat-izin/widgets/riwayat-izin-item.dart';
import 'package:material_kit_flutter/services/shared-service.dart';
import 'package:material_kit_flutter/widgets/drawer.dart';
import 'package:material_kit_flutter/widgets/spinner.dart';

late RiwayatIzinBloc riwayatIzinBloc;

class RiwayatIzin extends StatefulWidget {
  RiwayatIzin({Key? key}) : super(key: key);
  
  @override
  State<RiwayatIzin> createState() => _HistoryIzin();
}

class _HistoryIzin extends State<RiwayatIzin> {
  @override 
  void initState() {
    riwayatIzinBloc = new RiwayatIzinBloc();
    super.initState();
  }

  @override 
  void dispose() {
    // riwayatIzinBloc.dispose();
    super.dispose();
  }
  // late Future<List<dynamic>> Function() data = 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MaterialDrawer(currentPage: "Riwayat Izin",),
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
              // floating: true,
              // snap: false,
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
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: RiwayatIzinList()
              )
            )
          ],
        ),
      )
    );
  }
}

class RiwayatIzinList extends StatefulWidget {

  const RiwayatIzinList({Key? key}): super(key: key);

  @override
  State<RiwayatIzinList> createState() => _ListWidget();
}

class _ListWidget extends State<RiwayatIzinList> {
  GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();
  List<dynamic> data = [];
  String? err;

  _reset() {
    int len = data.length;
    if(len > 0) {
      for(int i = len-1; i >= 0; i--) {
        data.removeAt(i);
        _listKey.currentState?.removeItem(i, (context, animation) => SizeTransition( 
          sizeFactor: animation,
          child: Container(),
        ), duration: const Duration(seconds: 0));
      }
    }
  }

  _getData() async {
    _reset();
    try{
      List<dynamic> newData = await riwayatIzinBloc.getPermission();
      if(newData.length == 0) return;
      else {
        for(int i = 0; i < newData.length; i++) {
          data.insert(i, newData[i]);
          _listKey.currentState?.insertItem(i);
          await Future<void>.delayed(const Duration(milliseconds: 30));
        }
      }
    } catch (e) {
      err = e as String;
    }
  }

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: HistoryIzinItem(
        item: RiwayatIzinModel.fromJson(data[index]),
        tap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              inspect(DateTime.parse(formatDateOnly(DateTime.now())));
              print(DateTime.parse(formatDateOnly(DateTime.now())).toIso8601String());
              // if(DateTime.parse(data[index]['startDate']).isBefore())
              if(data[index]['status'] != 'Menunggu')
                return RiwayatIzinDetail(item: RiwayatIzinModel.fromJson(data[index]));
              return RiwayatIzinEdit(item: RiwayatIzinModel.fromJson(data[index]));
            })
          );
        },
      ),
    );
  }

  @override
  void initState() {
    riwayatIzinBloc.init();

    // _getData().then((value) => setState((){}));
    riwayatIzinBloc.reloadStream.listen((event) {
      _getData().then((value) => setState((){}));
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    riwayatIzinBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    err = null;
    return Container(
      // padding: EdgeInsets.only(bottom: 24),
      width: double.infinity,
      height: MediaQuery.of(context).size.height - 144 - 56,
      child: RefreshIndicator(
        onRefresh: () {
          return _getData();
        },
        child: StreamBuilder<bool>(
          stream: riwayatIzinBloc.loadingStream,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if(!snapshot.hasData || (snapshot.hasData && snapshot.data!)) 
              return loadingSpinner();

            if(err != null)
              return Center(
                child: Text(err!,
                  textAlign: TextAlign.center,
                ),
              );
            
            if(data.length == 0) 
              return Center(
                child: Text('Tidak ada data',
                  textAlign: TextAlign.center,
                ),  
              );
            
            return CustomScrollView(
              slivers: [
                SliverAnimatedList(
                  key: _listKey,
                  itemBuilder: _buildItem,
                  initialItemCount: data.length,
                )
              ],
            );
          }
        )
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
    _controller.text = widget.isAkhir ? riwayatIzinBloc.filter.endDate! : riwayatIzinBloc.filter.startDate!;
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
                initialDate: DateTime.parse(widget.isAkhir && DateTime.parse(riwayatIzinBloc.filter.startDate!).isBefore(DateTime.parse(riwayatIzinBloc.filter.endDate!))? 
                              riwayatIzinBloc.filter.endDate! :
                              riwayatIzinBloc.filter.startDate!
                            ),
                firstDate: widget.isAkhir? DateTime.parse(riwayatIzinBloc.filter.startDate!) : DateTime(2022),
                lastDate: DateTime(DateTime.now().year + 10)
              )
              .then((DateTime? value) {
                if (value != null) {
                  if(widget.isAkhir) {
                    riwayatIzinBloc.filter.endDate = formatDateOnly(value);
                  } else {
                    riwayatIzinBloc.filter.startDate = formatDateOnly(value);
                  }
                  _controller.text = formatDateOnly(value);
                  riwayatIzinBloc.triggerReload();
                  // widget.key.
                  setState(() {});
                }
              });
            }
          ),
          hintText: widget.isAkhir ? "Tanggal Akhir" : "Tanggal Awal",
          border: OutlineInputBorder(),
        ),
        onTap: () {
          showDatePicker(
              context: context,
              initialDate:
                  DateTime.parse(riwayatIzinBloc.filter.startDate!),
              firstDate: widget.isAkhir
                  ? DateTime.parse(riwayatIzinBloc.filter.startDate!)
                  : DateTime.fromMillisecondsSinceEpoch(0),
              lastDate: DateTime(DateTime.now().year + 10))
          .then((DateTime? value) {
        if (value != null) {
          if(widget.isAkhir) {
            riwayatIzinBloc.filter.endDate = formatDateOnly(value);
          } else {
            riwayatIzinBloc.filter.startDate = formatDateOnly(value);
          }
          _controller.text = formatDateOnly(value);
          setState(() {});
        }
      });
    });
  }
}
