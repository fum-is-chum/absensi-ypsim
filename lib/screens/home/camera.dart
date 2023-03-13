import 'dart:io';
import 'dart:math' as math;

import 'package:SIMAt/screens/home/preview_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.camera}) : super(key: key);

  final CameraDescription? camera;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isRearCameraSelected = false;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  @override
  void dispose() {
    // SystemChrome.restoreSystemUIOverlays();
    _cameraController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();

    Future.delayed(Duration(seconds: 1)).then((value) =>
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values)); // to re-show bars
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    initCamera(widget.camera!);
    super.initState();
  }

  Future takePicture() async {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null ||
        !cameraController.value.isInitialized ||
        cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      if (!kIsWeb) await cameraController.setFlashMode(FlashMode.off);
      XFile picture = await cameraController.takePicture();
      final imageBytes = await picture.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      img.Image fixedImage = img.flipHorizontal(originalImage!);

      if (!kIsWeb) {
        File file = File(picture.path);

        XFile fixedFile = new XFile((await file.writeAsBytes(
          img.encodeJpg(fixedImage),
          flush: true,
        ))
            .path);
        bool result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewPage(
                      picture: fixedFile,
                    )));
        if (result) Navigator.pop(context, true);
        return result;
      }
      bool result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreviewPage(
                    picture: picture,
                  )));
      if (result) Navigator.pop(context, true);
      return result;
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = _cameraController;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      _cameraController = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.medium : ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _cameraController = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb
            ? <Future<Object?>>[
                cameraController.getMinExposureOffset().then(
                    (double value) => _minAvailableExposureOffset = value),
                cameraController
                    .getMaxExposureOffset()
                    .then((double value) => _maxAvailableExposureOffset = value)
              ]
            : <Future<Object?>>[],
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showCameraException(CameraException e) {
    // _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future initCamera(CameraDescription cameraDescription) async {
    onNewCameraSelected(cameraDescription);
  }

  @override
  Widget build(BuildContext context) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null) {
      return Container();
    }
    var tmp = MediaQuery.of(context).size;

    final screenH = math.max(tmp.height, tmp.width);
    final screenW = math.min(tmp.height, tmp.width);

    tmp = cameraController.value.previewSize ?? Size(1080, 1920);

    final previewH = math.max(tmp.height, tmp.width);
    final previewW = math.min(tmp.height, tmp.width);
    final screenRatio = screenH / screenW;
    final previewRatio = previewH / previewW;

    return Scaffold(
        body: SafeArea(
      child: Stack(fit: StackFit.expand, children: [
        (cameraController.value.isInitialized)
            ? ClipRRect(
                child: OverflowBox(
                  maxHeight: screenRatio > previewRatio
                      ? screenH
                      : screenW / previewW * previewH,
                  maxWidth: screenRatio > previewRatio
                      ? screenH / previewH * previewW
                      : screenW,
                  child: CameraPreview(
                    cameraController,
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
                          color: Color.fromARGB(210, 92, 92, 92)),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 24,
                        icon: Icon(CupertinoIcons.xmark, color: Colors.white),
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
                          color: Color.fromARGB(210, 92, 92, 92)),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 24,
                        icon: Icon(
                            _isRearCameraSelected
                                ? CupertinoIcons.switch_camera
                                : CupertinoIcons.switch_camera_solid,
                            color: Colors.white),
                        onPressed: () {
                          // setState(() =>
                          //     _isRearCameraSelected = !_isRearCameraSelected);
                          // initCamera(
                          //     widget.camera[_isRearCameraSelected ? 0 : 1]);
                        },
                      ),
                    )
                  ]),
            )),
      ]),
    ));
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
    return disabled
        ? CircularProgressIndicator()
        : IconButton(
            onPressed: () async {
              if (!disabled) {
                disabled = true;
                setState(() {});
                if (!(await widget.onPressed())) {
                  disabled = false;
                  setState(() {});
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
