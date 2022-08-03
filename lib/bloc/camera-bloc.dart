import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class CameraBloc {
  CameraBloc._();
  static final _instance = CameraBloc._();
  
  String snapTime = '';
  late BehaviorSubject<File?> _imageFile = BehaviorSubject<File?>.seeded(null);

 factory CameraBloc() {
    return _instance; // singleton service
  }

  Stream<File?> get imageStream {
    return _imageFile.stream;
  }

  Future pickImage() async {
    try {
      XFile? img = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.front
      );
      if(img != null ) this._imageFile.sink.add(File(img.path));
      snapTime = DateFormat('HH:mm:ss').format(DateTime.now()) + ' WIB';
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