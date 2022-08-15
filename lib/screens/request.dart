import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../bloc/request-bloc.dart';
import '../constants/Theme.dart';
import '../widgets/drawer.dart';

final requestBloc = new RequestBloc();

class Request extends StatelessWidget {
  Request({Key? key}): super(key: key);
  final GlobalKey<FormState> _key = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    print('request rebuilds');
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
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tanggal Awal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 4,),
                TanggalField(),
                const SizedBox(height: 16,),
                Text(
                  'Tanggal Akhir',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 4,),
                TanggalField(isAkhir: true,),
                const SizedBox(height: 16,),
                Text(
                  'Keterangan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 4,),
                KeteranganField(),
                const SizedBox(height: 16),
                Text(
                  'Lampiran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(height: 4,),
                LampiranField(),
                const SizedBox(height: 16,),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                      onPressed: (){
                        _key.currentState!.save();
                        inspect(requestBloc.getRawValue());
                      },
                        child: Text('Submit')
                      ),
                    )
                  ],
                )
              ]
            ),
          )
        ),
      )
    );
  }
}

class TanggalField extends StatefulWidget {
  final bool isAkhir;
  TanggalField({Key? key, this.isAkhir = false}): super(key: key);
  
  @override
  _TanggalField createState() => _TanggalField();
}

class _TanggalField extends State<TanggalField> {
  final TextEditingController _controller = TextEditingController();
  @override 
  void initState() {
    super.initState();
    _controller.text = DateFormat('yyyy-MM-dd').format(DateTime.parse(requestBloc.getValue('tanggalAkhir')));
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.date_range),
          // color: MaterialColors.muted,
          onPressed: (){
            showDatePicker(
              context: context,
              initialDate: DateTime.parse(requestBloc.getValue('tanggalAwal')),
              firstDate: widget.isAkhir? DateTime.parse(requestBloc.getValue('tanggalAwal')) : DateTime.fromMillisecondsSinceEpoch(0),
              lastDate: DateTime(DateTime.now().year + 10)
            ).then((DateTime? value) {
              if(value != null){
                requestBloc.setValue(widget.isAkhir? 'tanggalAkhir': 'tanggalAwal', DateFormat('yyyy-MM-dd').format(value).toString());
                _controller.text = DateFormat('yyyy-MM-dd').format(value);
                setState(() {
                  
                });
              }
            });
          }
        ),
        hintText: widget.isAkhir? "Tanggal Akhir" : "Tanggal Awal",
        border: OutlineInputBorder(),
      ),
      onTap: (){
        showDatePicker(
          context: context,
          initialDate: DateTime.parse(requestBloc.getValue('tanggalAwal')),
          firstDate: widget.isAkhir? DateTime.parse(requestBloc.getValue('tanggalAwal')) : DateTime.fromMillisecondsSinceEpoch(0),
          lastDate: DateTime(DateTime.now().year + 10)
        ).then((DateTime? value) {
          if(value != null){
            requestBloc.setValue(widget.isAkhir? 'tanggalAkhir': 'tanggalAwal', DateFormat('yyyy-MM-dd').format(value).toString());
            _controller.text = DateFormat('yyyy-MM-dd').format(value);
            setState(() {
              
            });
          }
        });
      }
    );
  }
}

class KeteranganField extends StatefulWidget {
  const KeteranganField({Key? key}): super(key: key);

  @override
  _KeteranganField createState() => _KeteranganField();
}

class _KeteranganField extends State<KeteranganField> {

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      minLines: 5,
      onSaved: (String? value) {
        requestBloc.setValue('keterangan', value);
      },
      decoration: InputDecoration(
        hintText: 'Keterangan Izin',
        border: OutlineInputBorder()
      ),
    );
  }
}

class LampiranField extends StatefulWidget {
  const LampiranField({Key? key}): super(key: key);

  @override
  _LampiranField createState() => _LampiranField();
}

class _LampiranField extends State<LampiranField> {
  File? pickedFile;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
          style: BorderStyle.solid
        ),
        borderRadius: BorderRadius.circular(4.0)
      ),
      padding: EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.grey[300])
            ),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if(result != null) {
                pickedFile = File(result.files.single.path!);
                // requestBloc.setValue('file')
                setState(() {
                  
                });
              }
            }, 
            child: Text(
              'Tambah Lampiran',
              style: TextStyle(
                color: Colors.black
              )
            )
          ),
          const SizedBox(width: 5,),
          Expanded(
            child: Text(pickedFile != null? pickedFile!.path.split('/').last : ''),
          )
        ],
      ),
    );
  }
}
