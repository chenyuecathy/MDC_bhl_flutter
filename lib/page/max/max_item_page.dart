// import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:mdc_bhl/model/media_data.dart';

import 'max_secondary_video_page.dart';

class MaxItemPage extends StatefulWidget {
  final MediaModel mediaModel;

  MaxItemPage(this.mediaModel);

  @override
  State<StatefulWidget> createState() => MaxItemPageState();
}

class MaxItemPageState extends State<MaxItemPage> with AutomaticKeepAliveClientMixin {
  // File _imgFile = new File("");

  @override
  void initState() {
    // _getFile();
    super.initState();
  }

  // _getFile() async {
  //   // 图片
  //   setState(() {
  //     _imgFile = widget.mediaModel;
  //   });
  //   // 视频
  //   String filePath = _imgFile.path;
  //   String suffix = filePath.substring(filePath.lastIndexOf(".") + 1);
  //   if (suffix == "mp4") {
  //     File videoThumbnailFile = await _getVideoThumbnail(_imgFile);
  //     setState(() {
  //       _imgFile = videoThumbnailFile;
  //     });
  //   }
  // }

  // // 获取图片的缩略图
  // _getVideoThumbnail(File video) async {
  //   String imgPath = await VideoThumbnail.thumbnailFile(
  //     video: video.path,
  //     thumbnailPath: (await getTemporaryDirectory()).path,
  //     imageFormat: ImageFormat.JPEG,
  //     maxHeightOrWidth: 0,
  //     quality: 100,
  //   );
  //   return File(imgPath);
  // }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Container(
        decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: (widget.mediaModel.type == MediaType.MediaVideo) ? FileImage(widget.mediaModel.thumbnailFile) :FileImage(widget.mediaModel.mediafile),
            )
        ),
        alignment: AlignmentDirectional.center,
        child: (widget.mediaModel.type == MediaType.MediaVideo) ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).push<String>(new MaterialPageRoute(builder: (_) {
                return new MaxDecondaryVideoPage(widget.mediaModel.mediafile);
              }));
            },
            child: Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white54
                ),
                child: Icon(Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                )
            )
        ) : Container()
    );
  }

  // String _getSuffix() {
  //   String filePath = widget.mediaModel.path;
  //   String suffix = filePath.substring(filePath.lastIndexOf(".") + 1);
  //   return suffix;
  // }
}