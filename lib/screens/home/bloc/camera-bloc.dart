import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:absensi_ypsim/utils/services/shared-service.dart';
import 'package:rxdart/rxdart.dart';

class CameraBloc {
  CameraBloc._sharedInstance();
  static final CameraBloc _shared = CameraBloc._sharedInstance();
  factory CameraBloc() => _shared;

  String snapTime = '';
  late BehaviorSubject<File?> _imageFile = BehaviorSubject<File?>.seeded(null);

  
  Stream<File?> get imageStream => _imageFile.stream;
  void reset() {
    _imageFile.sink.add(null);
  }
  
  File? get imageFile => _imageFile.value;

  // Future openCamera() async {
  //   try {
  //     XFile? img = await ImagePicker().pickImage(
  //       source: ImageSource.camera,
  //       imageQuality: 50,
  //       preferredCameraDevice: CameraDevice.front
  //     );
  //     if(img != null) this._imageFile.sink.add(File(img.path));
  //     snapTime = DateFormat('HH:mm:ss').format(DateTime.now()) + ' WIB';
  //     // final File imageTemp = File();
  //     // setState(() => this.image = imageTemp);
  //   } on PlatformException catch(e) {
  //     print('Failed to pick image: $e');
  //   } 
  //   return;
  // }


  pickImage(XFile img) {
    try {
      // XFile? img = await ImagePicker().pickImage(
      //   source: ImageSource.camera,
      //   imageQuality: 50,
      //   preferredCameraDevice: CameraDevice.front
      // );
      this._imageFile.sink.add(File(img.path));
      snapTime = formatTimeOnly(DateTime.now()) + ' WIB';
      // final File imageTemp = File();
      // setState(() => this.image = imageTemp);
    } on PlatformException catch(e) {
      print('Failed to pick image: $e');
    } 
    return;
  }

  void dispose() {
    _imageFile.close();
  }
}