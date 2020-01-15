import 'package:flutter/material.dart';
import 'package:mdc_bhl/camera/video_progress.dart';

const double NormalButtonSize = 40;
const double LargeButtonSize = 72;

enum CameraType {
  CameraImage,
  CameraVideoStart,
  CameraVideoEnd,
}

class CameraBottomWidget extends StatefulWidget {
  final CameraType cameraType;
  final ValueChanged<CameraType> cameratypeChange;
  final ValueChanged<bool> cameraToggleChange;
  CameraBottomWidget(
      this.cameraType, this.cameratypeChange, this.cameraToggleChange);

  _CameraBottomWidgetState createState() =>
      _CameraBottomWidgetState(this.cameraType);
}

class _CameraBottomWidgetState extends State<CameraBottomWidget>
    with TickerProviderStateMixin {
  CameraType _cameraType;
  bool _toggleCamera = false; // 用于设置前置、后置
  AnimationController _animationController; // 动画

  // 视频时长
  int _videoDuration = 60;

  _CameraBottomWidgetState(this._cameraType);

  @override
  void initState() {
    // 动画
    _animationController = new AnimationController(
        vsync: this, duration: Duration(seconds: _videoDuration));
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
      } else if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        // _onStopButtonPressed(); // 停止录制视频
        widget.cameratypeChange(CameraType.CameraVideoEnd);  // 停止录制视频

      } else if (status == AnimationStatus.reverse) {}
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Align(
          alignment: Alignment.center,
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius:
                      BorderRadius.all(Radius.circular(LargeButtonSize / 2)),
                  onTap: () {
                    widget.cameratypeChange(_cameraType);
                    if (_cameraType == CameraType.CameraVideoStart) {
                      _cameraType = CameraType.CameraVideoEnd;
                      _animationController.forward();
                    } 
                    else if (_cameraType == CameraType.CameraVideoEnd) {
                      _cameraType = CameraType.CameraVideoStart;
                    }
                  },
                  child: (_cameraType == CameraType.CameraImage ||
                          _cameraType == CameraType.CameraVideoStart)
                      ?
                      // 拍照
                      Container(
                          padding: EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/images/ic_shutter_1.png',
                            width: LargeButtonSize,
                            height: LargeButtonSize,
                          ))
                      :
                      // 摄像
                      AnimatedBuilder(
                          animation: _animationController,
                          builder: (BuildContext context, Widget child) {
                            return Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  VideoProgress(
                                    colors: [Colors.red, Colors.orange],
                                    radius: 35.0,
                                    stokeWidth: 3.0,
                                    value: _animationController.value,
                                  ),
                                  Text(
                                      ((_videoDuration *
                                                  _animationController.value)
                                              .toInt())
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18.0))
                                ]);
                          })))),
      Align(
          /// 切换照相模式和录像模式的按钮
          alignment: Alignment.centerLeft,
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius:
                      BorderRadius.all(Radius.circular(NormalButtonSize / 2)),
                  onTap: () {
                    if (_cameraType == CameraType.CameraImage) {
                      setState(() {
                        _cameraType = CameraType.CameraVideoStart;
                      });
                    } else {
                      setState(() {
                        _cameraType = CameraType.CameraImage;
                      });
                    }
                  },
                  child: Container(
                      padding: EdgeInsets.all(4.0),
                      child: Image.asset(
                        _cameraType == CameraType.CameraImage
                            ? 'assets/images/ic_video.png'
                            : 'assets/images/ic_camera.png',
                        width: NormalButtonSize,
                        height: NormalButtonSize,
                      ))))),
      Align(
        /// 切换前置和后置模式
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
                BorderRadius.all(Radius.circular(NormalButtonSize / 2)),
            onTap: _toggleCameraAction,
            child: Container(
              padding: EdgeInsets.all(4.0),
              child: Image.asset(
                'assets/images/ic_switch_camera_3.png',
                color: Colors.grey[200],
                width: NormalButtonSize,
                height: NormalButtonSize,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

// switch camera front an rear
  void _toggleCameraAction() {
    setState(() {
      _toggleCamera = !_toggleCamera;
      widget.cameraToggleChange(_toggleCamera);
    });
  }
}
