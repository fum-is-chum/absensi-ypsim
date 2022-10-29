import 'dart:io';

import 'package:absensi_ypsim/screens/home/bloc/camera-bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PreviewPage extends StatelessWidget {
  final XFile picture;
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: !kIsWeb ? Image.file(File(picture.path), fit: BoxFit.cover) :
                        Image.network(picture.path, fit: BoxFit.cover)
                ,
              ),
              Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 36),
                height: MediaQuery.of(context).size.height * 0.20,
                decoration: const BoxDecoration(
                  // borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  // color: Color(0x10000000)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Color.fromARGB(210, 92, 92, 92)
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 24,
                        icon: Icon(
                          CupertinoIcons.xmark,
                          color: Colors.white
                        ),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Color.fromARGB(210, 92, 92, 92)
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 24,
                        icon: Icon(
                          CupertinoIcons.checkmark_alt,
                          color: Colors.white
                        ),
                        onPressed: () {
                          CameraBloc().pickImage(picture);
                          Navigator.pop(context, true);
                        },
                      ),
                    ),
                  ]
                ),
              )
            ),
            ],
          ),
        ),
      ),
    );
  }
}