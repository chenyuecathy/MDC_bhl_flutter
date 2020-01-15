import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/* 视频展示二级页面 */
class MaxDecondaryVideoPage extends StatefulWidget {
  File _imageFile;

  MaxDecondaryVideoPage(this._imageFile);

  @override
  State<StatefulWidget> createState() => _VideoState();
}

class _VideoState extends State<MaxDecondaryVideoPage> {
  VideoPlayerController _videoPlayerController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(widget._imageFile)
      ..initialize().then((_) {
        setState(() {
          _videoPlayerController.play();
        });
      })
      ..addListener(() {
        final bool isPlaying = _videoPlayerController.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Container(
            color: Colors.black,
            child: Stack(
                children: <Widget>[
                  Center(
                      child: AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: _videoPlayerController.value.initialized
                          // 加载成功
                              ? VideoPlayer(_videoPlayerController) : new Container()
                      )
                  ),
                  ConstrainedBox(
                      child: Container(
//                      color: Colors.white24,
                          padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                          alignment: AlignmentDirectional.topStart,
                          child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.chevron_left, size: 30, color: Colors.white70)
                          )
                      ),
                      constraints: new BoxConstraints.expand(
                          height: 80
                      )
                  )
                ]
            )
        ),
        floatingActionButton: new FloatingActionButton(
            backgroundColor: Colors.white24,
            onPressed: _videoPlayerController.value.isPlaying
                ? _videoPlayerController.pause
                : _videoPlayerController.play,
            child: new Icon(
              _videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
            )
        )
    );
  }
}