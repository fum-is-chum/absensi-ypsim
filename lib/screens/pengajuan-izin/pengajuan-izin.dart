import 'dart:io';

import 'package:absensi_ypsim/utils/constants/Theme.dart';
import 'package:absensi_ypsim/utils/services/hide_keyboard.dart';
import 'package:absensi_ypsim/utils/services/shared-service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/drawer.dart';
import 'bloc/pengajuan-izin-bloc.dart';
import 'models/pengajuan-izin-model.dart';

final _pengajuanIzinBloc = new PengajuanIzinBloc();

bool get _isEdit {
  return _pengajuanIzinBloc.model.id > 0;
}

bool get _hasFile {
  return _isEdit && _pengajuanIzinBloc.model.file != null;
}

bool get _fileLoading {
  return _pengajuanIzinBloc.model.file.runtimeType.toString() == 'String';
}

class PengajuanIzin extends StatefulWidget {
  final PengajuanIzinModel? editData;
  PengajuanIzin({Key? key, this.editData}): super(key: key);

  @override
  State<PengajuanIzin> createState() => _PengajuanIzin();
}

class _PengajuanIzin extends State<PengajuanIzin> {

  final GlobalKey<FormState> _key = new GlobalKey<FormState>();
  final GlobalKey<_LampiranField> _lampiranKey = new GlobalKey<_LampiranField>();

  @override
  void initState() {
    if(widget.editData != null) {
      _pengajuanIzinBloc.setInitialValue(widget.editData!);
      // inspect(_pengajuanIzinBloc.model);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pengajuanIzinBloc.dispose();
  }

  Widget? _drawer() {
    if(widget.editData == null) 
      return MaterialDrawer(currentPage: "Pengajuan Izin");
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
      },
      child: WillPopScope(
        onWillPop: () async {
          if(_isEdit) Navigator.pop(context);
          else Navigator.pushReplacementNamed(context, '/home');
          return false;
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
            // automaticallyImplyLeading: editData != null,
          ),
          backgroundColor: MaterialColors.bgColorScreen,
          // key: _scaffoldKey,
          drawer: _drawer(),
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
                    const Text(
                      'Tanggal Awal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 4,),
                    TanggalField(),
                    const SizedBox(height: 16,),
                    const Text(
                      'Tanggal Akhir',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 4,),
                    TanggalField(isAkhir: true,),
                    const SizedBox(height: 16,),
                    const Text(
                      'Keterangan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 4,),
                    KeteranganField(),
                    const SizedBox(height: 16),
                    const Text(
                      'Lampiran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const SizedBox(height: 4,),
                    LampiranField(key: _lampiranKey),
                    const SizedBox(height: 16,),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if(_key.currentState!.validate()) {
                                _key.currentState!.save();
                                try {
                                  if(_isEdit) {
                                    if(_hasFile && _fileLoading) throw 'File Loading';
                                    if(await _pengajuanIzinBloc.updateIzin(context)) {
                                      await Future.delayed(Duration(milliseconds: 500));
                                      Navigator.popUntil(context, ModalRoute.withName('/riwayat-izin'));
                                    }
                                  } else if(!_isEdit) {
                                    if(await _pengajuanIzinBloc.createIzin(context)) {
                                      _key.currentState!.reset();
                                      _lampiranKey.currentState!.reset();
                                    }
                                  }
                                } catch (e) {
                                  await handleError(e);;
                                }
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
    _controller.text = widget.isAkhir ? _pengajuanIzinBloc.model.end_date : _pengajuanIzinBloc.model.start_date;
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.parse(widget.isAkhir? _pengajuanIzinBloc.model.end_date: _pengajuanIzinBloc.model.start_date),
      firstDate: widget.isAkhir? DateTime.parse(_pengajuanIzinBloc.model.start_date) : DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: DateTime(DateTime.now().year + 10)
    ).then((DateTime? value) {
      if(value != null){
        if(widget.isAkhir)
          _pengajuanIzinBloc.model.end_date = formatDateOnly(value);
        else
          _pengajuanIzinBloc.model.start_date = formatDateOnly(value);
        _controller.text = formatDateOnly(value);
        setState(() {
          
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? val) {
        if(val != null && widget.isAkhir && DateTime.parse(val).isBefore(DateTime.parse(_pengajuanIzinBloc.model.start_date))) {
          return '';
        }
        return null;
      },
      decoration: InputDecoration(
        suffixIcon: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.date_range),
          // color: MaterialColors.muted,
          onPressed: _showDatePicker
        ),
        hintText: widget.isAkhir? "Tanggal Akhir" : "Tanggal Awal",
        border: OutlineInputBorder(),
      ),
      onTap: _showDatePicker
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
      initialValue: _pengajuanIzinBloc.model.remark,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? val) {
        if(val == null || val.isEmpty) {
          return 'Silahkan isi keterangan';
        }
        return null;
      },
      onSaved: (String? value) {
        _pengajuanIzinBloc.model.remark = value ?? '';
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
  String? error;

  void reset() {
    pickedFile = null;
    setState(() {
      
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    if(_hasFile) { // if edit mode
      _pengajuanIzinBloc.fetchFile().then((value) {
        pickedFile = value;
        if(pickedFile != null) 
          setState(() {
            
          });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                      onPressed: _fileLoading ? null : () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: [
                            'JPG',
                            'jpg',
                            'jpeg',
                            'png',
                            'PNG',
                            'doc',
                            'docx',
                            'PDF',
                            'pdf'
                          ]
                        );
                        if(result != null) {
                          if(result.files[0].size > 2048000) {
                            error = 'Ukuran file maks 2 MB';
                            setState(() {
                              
                            });
                            return;
                          }
                          error = null;
                          pickedFile = File(result.files.single.path!);
                          _pengajuanIzinBloc.model.file = pickedFile;
                          // _pengajuanIzinBloc.setValue('file')
                          setState(() {
                            
                          });
                        }
                      }, 
                      child: const Text(
                        'Browse',
                        style: TextStyle(
                          color: Colors.black
                        )
                      )
                    ),
                    const SizedBox(width: 5,),
                    Expanded(
                      child: Text(pickedFile != null? pickedFile!.path.split('/').last : _hasFile ? 'Loading...' : ''),
                    )
                  ],
                ),
              ),
              pickedFile == null ? Container(): 
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: reset,
                  icon: Icon(CupertinoIcons.xmark, size: 16)
                ), 
            ],
          ),
        ),
        (() {
          if(error == null) return Container();
          return Text(error!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: MaterialColors.error
            ),
          );
        }()),
        Text('Ekstensi file: .pdf, .docx, .doc, .png, .jpg, .jpeg\nUkuran maks: 2 MB',
          style: TextStyle(
            fontSize: 12,
            color: MaterialColors.muted
          ),
        )
      ],
    );
  }
}
