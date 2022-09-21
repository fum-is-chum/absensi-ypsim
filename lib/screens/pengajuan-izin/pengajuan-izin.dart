import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_kit_flutter/services/shared-service.dart';

import '../../constants/Theme.dart';
import '../../services/hide_keyboard.dart';
import '../../widgets/drawer.dart';
import 'bloc/pengajuan-izin-bloc.dart';

final pengajuanIzinBloc = new PengajuanIzinBloc();

class Request extends StatelessWidget {
  Request({Key? key}): super(key: key);
  final GlobalKey<FormState> _key = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
      },
      child: Scaffold(
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
                        onPressed: () async {
                          if(_key.currentState!.validate()) {
                            _key.currentState!.save();
                            if(await pengajuanIzinBloc.createIzin(context))
                              _key.currentState!.reset();
                          }
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
      ),
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
    _controller.text = pengajuanIzinBloc.getValue('endDate');
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? val) {

        if(val != null && widget.isAkhir && DateTime.parse(val).isBefore(DateTime.parse(pengajuanIzinBloc.getValue('startDate')))) {
          return '';
        }
        return null;
      },
      decoration: InputDecoration(
        suffixIcon: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.date_range),
          // color: MaterialColors.muted,
          onPressed: (){
            showDatePicker(
              context: context,
              initialDate: DateTime.parse(pengajuanIzinBloc.getValue('startDate')),
              firstDate: widget.isAkhir? DateTime.parse(pengajuanIzinBloc.getValue('startDate')) : DateTime.now(),
              lastDate: DateTime(DateTime.now().year + 10)
            ).then((DateTime? value) {
              if(value != null){
                pengajuanIzinBloc.setValue(widget.isAkhir? 'endDate': 'startDate', formatDateOnly(value));
                _controller.text = formatDateOnly(value);
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
          initialDate: DateTime.parse(pengajuanIzinBloc.getValue('startDate')),
          firstDate: widget.isAkhir? DateTime.parse(pengajuanIzinBloc.getValue('startDate')) : DateTime.fromMillisecondsSinceEpoch(0),
          lastDate: DateTime(DateTime.now().year + 10)
        ).then((DateTime? value) {
          if(value != null){
            pengajuanIzinBloc.setValue(widget.isAkhir? 'endDate': 'startDate', formatDateOnly(value).toString());
            _controller.text = formatDateOnly(value);
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? val) {
        if(val == null || val.isEmpty) {
          return 'Silahkan isi keterangan';
        }
        return null;
      },
      onSaved: (String? value) {
        pengajuanIzinBloc.setValue('remark', value);
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.grey[300])
                  ),
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if(result != null) {
                      pickedFile = File(result.files.single.path!);
                      pengajuanIzinBloc.setValue('file', pickedFile);
                      // pengajuanIzinBloc.setValue('file')
                      setState(() {
                        
                      });
                    }
                  }, 
                  child: Text(
                    'Browse',
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
          ),
          pickedFile == null ? Container(): 
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () {
                pickedFile = null;
                setState(() {});
              },
              icon: Icon(CupertinoIcons.xmark, size: 16)
            ), 
        ],
      ),
    );
  }
}
