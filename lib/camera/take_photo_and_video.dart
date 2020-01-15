import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

import 'package:mdc_bhl/camera/camera_bottom_widget.dart';

class TakePhotoAndVideo extends StatefulWidget {
  final List<CameraDescription> cameras;

  TakePhotoAndVideo(this.cameras);

  @override
  State<StatefulWidget> createState() {
    return _TakePhotoAndVideoState();
  }
}

class _TakePhotoAndVideoState extends State<TakePhotoAndVideo>
    with TickerProviderStateMixin {
  CameraController cameraController;

  CameraType cameraType = CameraType.CameraImage ;

  String imagePath;
  String videoPath;

  @override
  void initState() {
    try {
      onCameraSelected(widget.cameras[0]);
    } catch (e) {
      print(e.toString());
    }
    super.initState();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      print('camera build 1');
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No Camera Found',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      );
    }
    if (!cameraController.value.isInitialized) {
      print('camera build 2');
      return Container();
    }

    print('camera build  3');
    return Container(
        child: Stack(children: <Widget>[
      Align(
          alignment: Alignment.center,
          child: AspectRatio(
              aspectRatio: cameraController.value.aspectRatio,
              child: CameraPreview(cameraController))),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          height: 85.0,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          color: Color.fromRGBO(00, 00, 00, 1),
          child: CameraBottomWidget(cameraType, (CameraType type) {
            print("camera type" + type.toString());
            if (type == CameraType.CameraImage) {
              _onClickCaptureImage();
            } else if (type == CameraType.CameraVideoStart) {
              _onClickStartVideoRecording();
            } else {
              _onClickStopVideoRecording();
            }
          }, (bool isFront) {
            print('camera direction ' + isFront.toString());
            int cameraDirection = isFront ? 1 : 0;
            onCameraSelected(widget.cameras[cameraDirection]);
          }),
        ),
      ),
    ]));
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void setCameraResult(String filePath) {
    Navigator.pop(context, filePath);
  }

  void showException(CameraException e) {
    logError(e.code, e.description);
    showMessage('Error: ${e.code}\n${e.description}');
  }

  void showMessage(String message) {
    print(message);
  }

  void logError(String code, String message) =>
      print('Error: $code\nMessage: $message');

  // 设置前置后置摄像头
  void onCameraSelected(CameraDescription cameraDescription) async {
    if (cameraController != null) await cameraController.dispose();
    cameraController =
        CameraController(cameraDescription, ResolutionPreset.medium);
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        showMessage('Camera Error: ${cameraController.value.errorDescription}');
      }
    });
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      showException(e);
    }
    if (mounted) setState(() {});
  }

  // 照相
  void _onClickCaptureImage() {
    takePicture().then((String filePath) {
      if (mounted) {
        // setState(() {
        imagePath = filePath;
        // });
        if (filePath != null) {
          showMessage('Picture saved to $filePath');
          setCameraResult(imagePath);
        }
      }
    });
  }

  Future<String> takePicture() async {
    if (!cameraController.value.isInitialized) {
      showMessage('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/temporary'; // 图片、视频临时存储文件夹
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';
    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      await cameraController.takePicture(filePath);
    } on CameraException catch (e) {
      showException(e);
      return null;
    }
    return filePath;
  }

  // 开始拍摄
  void _onClickStartVideoRecording() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      startVideoRecording().then((String filePath) {
        if (mounted) setState(() {});
      });
    });

    // startVideoRecording().then((String filePath) {
    //   if (mounted) setState(() {});
    // });
  }

  Future<String> startVideoRecording() async {
    if (!cameraController.value.isInitialized) {
      showMessage('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/temporary'; // 图片、视频临时存储文件夹
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';
    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }
    try {
      videoPath = filePath;
      await cameraController.startVideoRecording(filePath);
    } on CameraException catch (e) {
      showException(e);
      return null;
    }
    return filePath;
  }

  // 停止拍摄
  void _onClickStopVideoRecording() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      showMessage('Video saved to: $videoPath');
      setCameraResult(videoPath);
    });
  }

  Future<String> stopVideoRecording() async {
    if (!cameraController.value.isRecordingVideo) {
      return null;
    }
    try {
      await cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      showException(e);
      return null;
    }
    return videoPath;
  }
}
