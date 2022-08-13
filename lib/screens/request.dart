import 'package:flutter/material.dart';

import '../constants/Theme.dart';
import '../widgets/drawer.dart';

class Request extends StatefulWidget {
  const Request({Key? key}): super(key: key);

  @override
  _Request createState() => _Request();
}

class _Request extends State<Request> {
  final GlobalKey<FormState> _key = new GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pengajuan Izin",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      // key: _scaffoldKey,
      drawer: MaterialDrawer(currentPage: "Request"),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _key,
            child: Column(
              children: [
                TanggalAwalField(key: _key)
              ]
            ),
          )
        ),
      )
    );
  }
}

class TanggalAwalField extends StatefulWidget {
  TanggalAwalField({Key? key}): super(key: key);
  
  @override
  _TanggalAwalField createState() => _TanggalAwalField();
}

class _TanggalAwalField extends State<TanggalAwalField> {   
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        suffixIcon: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.date_range),
          // color: MaterialColors.muted,
          onPressed: (){
            showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
              lastDate: DateTime.now()
            );
          },
        ),
        hintText: "Tanggal Awal",
        border: OutlineInputBorder()
      ),
    );
    }
}