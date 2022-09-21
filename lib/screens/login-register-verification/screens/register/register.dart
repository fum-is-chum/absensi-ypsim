import 'package:flutter/material.dart';
import 'package:material_kit_flutter/screens/Login-Register-Verification/screens/register/bloc/register-bloc.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/widgets/custom-button.dart';

late RegisterBloc _bloc;

void onSaved(String? val, String field) {
  _bloc.model[field] = val;
}

class RegisterView extends StatefulWidget {
  final AnimationController animationController;
  const RegisterView({Key? key, required this.animationController}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterView();
}

class _RegisterView extends State<RegisterView> {

  final _formKey = GlobalKey<FormState>();

  @override 
  void initState() {
    _bloc = RegisterBloc();
    super.initState();
  }
  @override 
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final _firstHalfAnimation = Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          0.0,
          0.2,
          curve: Curves.fastOutSlowIn
        )
      )
    );
    
    final _secondHalfAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(-1, 0)).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          0.2,
          0.4,
          curve: Curves.fastOutSlowIn
        )
      )
    );

    return SlideTransition(
      position: _firstHalfAnimation,
      child: SlideTransition(
        position: _secondHalfAnimation,
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: Offset(0, 4), // changes position of shadow
                  ),
                ]
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/img/logo-ypsim.jpeg",
                        width: 150,
                        fit: BoxFit.fitWidth
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "NIK",
                            isDense: true
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String? value) {
                            if(value == null || value.isEmpty) {
                              return 'NIK tidak boleh kosong';
                            }
                            return null;
                          },
                          onSaved: (String? value) => onSaved(value, 'nik'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Username",
                            isDense: true,
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String? value) {
                            if(value == null || value.isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            return null;
                          },
                          onSaved: (String? value) => onSaved(value, 'username'),
                        ),
                      ),
                      PasswordField(),
                      Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: CustomButton(
                          text: "Daftar",
                          onClick: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _bloc.setLoading(true);
                              bool resp = await _bloc.registerUser(context);
                              if(resp) {
                                _formKey.currentState!.reset();
                              }
                              // print('HIDE');
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: CustomButton(
                          text: "Kembali",
                          bgColor: MaterialColors.defaultButton,
                          textColor: Colors.black,
                          onClick: () {
                            widget.animationController.animateTo(0.0);
                            // Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                      ),
                    ],
                  ),
                )
              )
            ),
          )
        ),
      )
    );
  }
}

class PasswordField extends StatefulWidget {
  static final GlobalKey<_PasswordField> globalKey = GlobalKey();

  PasswordField({Key? key}) : super(key: globalKey);
  @override
  _PasswordField createState() => _PasswordField();
}

class _PasswordField extends State<PasswordField> {
  @override

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _bloc.obscureObservable,
      builder: (context, snapshot) {
        // print('password field build');
        return Padding(
          padding: EdgeInsets.only(top: 12),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: "Kata Sandi",
              isDense: true,
              suffixIcon:  IconButton(
                padding: EdgeInsets.zero,
                icon: snapshot.data ?? true ? const Icon(Icons.visibility_outlined) : const Icon(Icons.visibility_off_outlined),
                color: MaterialColors.muted,
                iconSize: 24,
                onPressed: (){
                  _bloc.toggleObscure();
                },
              )
            ),
            obscureText: snapshot.data ?? true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String? value) {
              if(value == null || value.isEmpty) return 'Password tidak boleh kosong';
              if(value.length < 8) return 'Password minimal 8 karakter';
              return null;
            },
            onSaved: (String? value) => onSaved(value, 'password'),
          )
          // child: Input(
          //   labelText: "Kata Sandi",
          //   obscureText: snapshot.data ?? true,
          //   focusedBorderColor: MaterialColors.muted,
          //   suffixIcon:  IconButton(
          //     padding: EdgeInsets.zero,
          //     icon: const Icon(Icons.visibility_outlined),
          //     color: MaterialColors.muted,
          //     onPressed: (){
          //       _bloc.toggle();
          //     },
          //   ),
          //   suffixIconConstraints: BoxConstraints(maxHeight: 16),
          // ),
        );
      },
    );
  }
}