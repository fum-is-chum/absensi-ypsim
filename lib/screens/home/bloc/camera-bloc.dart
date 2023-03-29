import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

class CameraBloc {
  CameraBloc._sharedInstance();
  static final CameraBloc _shared = CameraBloc._sharedInstance();
  factory CameraBloc() => _shared;

  String snapTime = '';
  late BehaviorSubject<dynamic> _imageFile =
      BehaviorSubject<dynamic>.seeded(null);

  Stream<dynamic> get imageStream => _imageFile.stream;
  void reset() {
    _imageFile.sink.add(null);
  }

  dynamic get imageFile => _imageFile.value;

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
      this._imageFile.sink.add(File(img.path));
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    return;
  }

  void dispose() {
    _imageFile.close();
  }
}
