import 'dart:io';

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
                    PasswordLamaField(),
                    const SizedBox(height: 16,),
                    const Text(
                      'Password Baru',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    PasswordBaru(),
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

class PasswordLamaField extends StatefulWidget {
  const PasswordLamaField({Key? key}): super(key: key);

  @override
  _PasswordLamaField createState() => _PasswordLamaField();
}

class _PasswordLamaField extends State<PasswordLamaField> {

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      initialValue: _gantiPasswordBloc.model.password_lama,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? val) {
        if(val == null || val.isEmpty) {
          return 'Silahkan isi password lama';
        }
        return null;
      },
      onSaved: (String? value) {
        _gantiPasswordBloc.model.password_lama = value ?? '';
      },
      decoration: InputDecoration(
        hintText: 'Password Lama',
        border: OutlineInputBorder()
      ),
    );
  }
}

class PasswordBaru extends StatefulWidget {
  const PasswordBaru({Key? key}) : super(key: key);

  @override
  _PasswordBaru createState() => _PasswordBaru();
}

class _PasswordBaru extends State<PasswordBaru> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      initialValue: _gantiPasswordBloc.model.password_baru,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (String? val) {
        if (val == null || val.isEmpty) {
          return 'Silahkan isi password baru';
        }
        return null;
      },
      onSaved: (String? value) {
        _gantiPasswordBloc.model.password_baru = value ?? '';
      },
      decoration: InputDecoration(
          hintText: 'Password Baru', border: OutlineInputBorder()),
    );
  }
}
