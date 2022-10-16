import 'dart:io';
import 'dart:math' as math;

import 'package:absensi_ypsim/screens/home/preview_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = false;

  @override
  void dispose() {
    // SystemChrome.restoreSystemUIOverlays();
    super.dispose();
    _cameraController.dispose();

    Future.delayed(Duration(seconds: 1)).then((value) => SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values)); // to re-show bars
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    initCamera(widget.cameras![1]);
    super.initState();
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      final imageBytes = await picture.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      img.Image fixedImage = img.flipHorizontal(originalImage!);

      File file = File(picture.path);

      XFile fixedFile = new XFile((await file.writeAsBytes(
        img.encodeJpg(fixedImage),
        flush: true,
      )).path);

      bool result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewPage(
                  picture: fixedFile,
                )));
      return result;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(
          cameraDescription, 
          ResolutionPreset.high,
          enableAudio: false
        );
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var tmp = MediaQuery.of(context).size;

    final screenH = math.max(tmp.height, tmp.width);
    final screenW = math.min(tmp.height, tmp.width);

    tmp = _cameraController.value.previewSize ?? Size(1080, 1920);

    final previewH = math.max(tmp.height, tmp.width);
    final previewW = math.min(tmp.height, tmp.width);
    final screenRatio = screenH / screenW;
    final previewRatio = previewH / previewW;


    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            (_cameraController.value.isInitialized)
              ? ClipRRect(
                  child: OverflowBox(
                    maxHeight: screenRatio > previewRatio
                        ? screenH
                        : screenW / previewW * previewH,
                    maxWidth: screenRatio > previewRatio
                        ? screenH / previewH * previewW
                        : screenW,
                    child: CameraPreview(
                      _cameraController,
                    ),
                  ),
                )
              : Container(
                  color: Colors.black,
                  child: const Center(child: CircularProgressIndicator())),
            IgnorePointer(
              child: ClipPath(
                clipper: InvertedCircleClipper(),
                child: Container(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.20,
                padding: EdgeInsets.symmetric(horizontal: 24),
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
                        iconSize: 30,
                        icon: Icon(
                          CupertinoIcons.xmark,
                          color: Colors.white
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    ShutterButton(
                      onPressed: takePicture,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Color.fromARGB(210, 92, 92, 92)
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 30,
                        icon: Icon(
                          _isRearCameraSelected
                              ? CupertinoIcons.switch_camera
                              : CupertinoIcons.switch_camera_solid,
                          color: Colors.white
                        ),
                        onPressed: () {
                          setState(
                              () => _isRearCameraSelected = !_isRearCameraSelected);
                          initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
                        },
                      ),
                    )
                ]),
              )
            ),
          ]
        ),
      )
    );
  }
}

class ShutterButton extends StatefulWidget {
  final Function onPressed;
  ShutterButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<ShutterButton> createState() => _ShutterButton();
}

class _ShutterButton extends State<ShutterButton> {
  bool disabled = false;

  @override
  Widget build(BuildContext context) {
    return disabled ? 
    CircularProgressIndicator()
    : IconButton(
      onPressed: () async {
        if(!disabled) {
          disabled = true;
          setState(() {
            
          });
          if(!(await widget.onPressed())) {
            disabled = false;
            setState(() {
              
            });
          }
        }
      },
      iconSize: 64,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.circle, color: Colors.white),
    );
  }
}

class InvertedCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width * 0.4))
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}