import 'dart:io';

import 'package:SIMAt/env.dart';
import 'package:SIMAt/utils/constants/Theme.dart';
import 'package:SIMAt/utils/services/hide-keyboard.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:flutter/material.dart';

import '../../widgets/drawer.dart';
import 'bloc/ganti-password-bloc.dart';
import 'models/ganti-password-model.dart';

final _gantiPasswordBloc = new GantiPasswordBloc();

bool get _isEdit {
  return _gantiPasswordBloc.model.id > 0;
}

class GantiPassword extends StatefulWidget {
  final GantiPasswordModel? editData;
  GantiPassword({Key? key, this.editData}): super(key: key);

  @override
  State<GantiPassword> createState() => _GantiPassword();
}

class _GantiPassword extends State<GantiPassword> {

  final GlobalKey<FormState> _key = new GlobalKey<FormState>();
  @override
  void initState() {
    if(widget.editData != null) {
      _gantiPasswordBloc.setInitialValue(widget.editData!);
      
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _gantiPasswordBloc.dispose();
  }

  Widget? _drawer() {
    if(widget.editData == null) 
      return MaterialDrawer(currentPage: "Ganti Password");
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
              "Ganti Password",
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
                      'Password Lama',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    PasswordField(type: 1, label: "Password Lama"),
                    const SizedBox(height: 16,),
                    const Text(
                      'Password Baru',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    PasswordField(type: 2, label: "Password Baru"),
                    const SizedBox(height: 16),
                    const Text(
                      'Konfirmasi Password Baru',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    PasswordField(type: 3, label: "Konfirmasi Password Baru"),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if(_key.currentState!.validate()) {
                                _key.currentState!.save();
                                try {
                                  if(await _gantiPasswordBloc.gantiPassword(context)){
                                    await Future.delayed(Duration(milliseconds: 500));
                                    Navigator.popUntil(context,ModalRoute.withName('/ganti-password'));
                                  }
                                } catch (e) {
                                  await handleError(e);;
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text('Submit'),
                            )
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


class PasswordField extends StatefulWidget {  
  PasswordField({Key? key, this.type = 0, this.label = ''});

  final int type;
  final String label;

  @override
  _PasswordField createState() => _PasswordField();
}

class _PasswordField extends State<PasswordField> {

  bool isObsecure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      initialValue: widget.type == 1
          ? _gantiPasswordBloc.model.password_lama
          : widget.type == 2 ? _gantiPasswordBloc.model.password_baru : _gantiPasswordBloc.model.konfirmasi_password_baru,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? val) {
        if (val == null || val.isEmpty) {
          return 'Silahkan isi '+widget.label;
        }
        return null;
      },
      onSaved: (String? value) {
        switch (widget.type) {
          case 1:
              _gantiPasswordBloc.model.password_lama = value ?? '';
            break;
          case 2:
            _gantiPasswordBloc.model.password_baru = value ?? '';
            break;
          case 3:
            _gantiPasswordBloc.model.konfirmasi_password_baru = value ?? '';
            break;
          default:
        }
      },
      obscureText: isObsecure,
      decoration: InputDecoration(
          hintText: widget.label,
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            padding: EdgeInsets.zero,
            icon: isObsecure ? const Icon(Icons.visibility_outlined) : const Icon(Icons.visibility_off_outlined),
            color: MaterialColors.muted,
            onPressed: () {
              setState(() {
                this.isObsecure = !this.isObsecure;
              });
            },
          )),
    );
  }
}
