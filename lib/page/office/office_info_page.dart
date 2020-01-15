import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mdc_bhl/model/media_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';

import 'package:mdc_bhl/db/tab_office_record_manager.dart';
import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/page/max/max_home_page.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/utils/file_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:mdc_bhl/utils/userinfo_utils.dart';

import 'package:mdc_bhl/common/net/address.dart';
import '../../main.dart';
// import 'package:mdc_bhl/camera/take_photo_and_video.dart';

class OfficeInfoPage extends StatefulWidget {
  final TabOfficeRecordModel officeRecord;

  OfficeInfoPage(this.officeRecord);

  @override
  State<StatefulWidget> createState() => OfficeInfoPageState();
}

class OfficeInfoPageState extends State<OfficeInfoPage> {
  TextEditingController _areaCountController = TextEditingController();
  TextEditingController _explainController = TextEditingController();

  /// Slider
  double sliderValue = 1.0;
  String sliderLabel = "";
  Color sliderActiveTrackColor = Colors.green;
  Color sliderThumbColor = Colors.green;

  List<MediaModel> _mediaModels = [];
  // List<File> _mediaThumbnails = [];

  // 视频Map（key：imageFiles中的index，value：视频File）
  // Map<int, File> videoMap =  Map();

  static const int MaxImageCount = 9; // 最大照片
  bool _isShowSaveAndUploadBtn = true; // 是否显示保存和上传按钮

  @override
  void initState() {
    _initData();
    print('initState');
    super.initState();
  }

  _initData() async {
    /// 初始化slider
    double value = widget.officeRecord.crowdLevel.floorToDouble();
    if (value == 4) {
      sliderValue = 1;
      sliderActiveTrackColor = Colors.green;
      sliderThumbColor = Colors.green;
    } else if (value == 3) {
      sliderValue = 2;
      sliderActiveTrackColor = Colors.blueAccent;
      sliderThumbColor = Colors.blueAccent;
    } else if (value == 2) {
      sliderValue = 3;
      sliderActiveTrackColor = Colors.orangeAccent;
      sliderThumbColor = Colors.orangeAccent;
    } else {
      sliderValue = 4;
      sliderActiveTrackColor = Colors.redAccent;
      sliderThumbColor = Colors.redAccent;
    }

    /// initial textfield
    _areaCountController.text = widget.officeRecord.areaCount == 0
        ? ''
        : widget.officeRecord.areaCount.toString();
    _explainController.text = widget.officeRecord.explain;

    /// initial image and video
    if (widget.officeRecord.imagesPath != null &&
        widget.officeRecord.imagesPath.length > 0) {
      List imagePaths = widget.officeRecord.imagesPath.split(',');

      String documentsPath = await FileUtils.getDocumentPath();
      setState(() {
        for (var imagePath in imagePaths) {
          String fullPath = documentsPath + imagePath;
          _addMedia(fullPath);
        }
      });
    }

    // 是否显示保存和上传按钮
    if (widget.officeRecord.isUpload == 1) {
      _isShowSaveAndUploadBtn = false;
    } else {
      _isShowSaveAndUploadBtn = true;
    }
  }

  /// process meidaModel list and thumbnail list
  _addMedia(String mediaPath, {MediaType type = MediaType.MediaUnknown}) async {
    /// TODO: check path  is fullpath or reletivePath

    // if (mediaPath == null || mediaPath.length == 0) return;
    assert((mediaPath != null && mediaPath.length != 0),
        'mediaPath can not be null');

    File mediaFile = File(mediaPath);
    print('office_info_page <_initData> 图片路径：$mediaPath');

    if (type == MediaType.MediaUnknown) {
      // get format of meida recording meida path
      List partsOfPath = mediaPath.split('.');
      String imgFormat = partsOfPath[partsOfPath.length - 1];
      print('office page  - media format : $imgFormat');
      List imageFormats = ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'];
      type = imageFormats.contains(imgFormat)
          ? MediaType.MediaImage
          : MediaType.MediaVideo;
    }

    print('report page  - media format : $type');

    /// get thumnail of image and video
    if (type == MediaType.MediaImage) {
      setState(() {
        _mediaModels.add(MediaModel(mediaFile, type, thumbnailFile: mediaFile));
      });
    } else {
      File videoThumbnail = await _getVideoThumbnail(mediaFile);
      setState(() {
        _mediaModels
            .add(MediaModel(mediaFile, type, thumbnailFile: videoThumbnail));
      });
    }
  }

  _removeMedia(int index) {
    debugPrint('delete image of $index');

    setState(() {
      _mediaModels.removeAt(index);

      debugPrint('image ${_mediaModels.length}');
    });
  }

  // 获取图片的缩略图
  _getVideoThumbnail(File video) async {
    String imgPath = await VideoThumbnail.thumbnailFile(
      video: video.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeightOrWidth: 0,
      quality: 100,
    );
    return File(imgPath);
  }

  @override
  void dispose() {
    _areaCountController.dispose();
    _explainController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('didChangeDependencies');
  }

  @override
  void didUpdateWidget(oldWidget) {
    print('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
        print('build');
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          /// 通过GestureDetector捕获点击事件，再通过FocusScope将焦点转移至空焦点—— FocusNode()
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            appBar: GradientAppBar(
                gradientStart: Color(0xFF2171F5),
                gradientEnd: Color(0xFF49A2FC),
                centerTitle: true,
                title: Text('采集客流高峰期照片', //_tabOfficeRecordModel.collectionName,
                    style: TextStyle(fontSize: FontConfig.naviTextSize)),
                leading: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.chevron_left, size: 30)),
                actions: <Widget>[
                  _isShowSaveAndUploadBtn
                      ? Center(
                          child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _saveOfficeRecord(true, 0);
                              },
                              child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text("保存",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              FontConfig.tabbarTextSize)))))
                      : Center()
                ]),
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // BackdropFilter(
                      //     //背景滤镜器
                      //     filter: ImageFilter.blur(
                      //         sigmaX: 5.0, sigmaY: 5.0), //��片模糊过滤��横向竖向都设置5.0
                      //     child: Opacity(
                      //       //透明控件
                      //       opacity: 0.5,
                      // child:
                      Image.asset('images/ic_task_bg.jpg',
                          height: 65,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fill),
                      // )),
                      Container(
                          padding: EdgeInsets.all(20),
                          color: Colors.transparent,
                          child: Text(widget.officeRecord.collectionName,
                              style: TextStyle(
                                  color: const Color(ColorConfig.borderColor),
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontConfig.normalTextSize)))
                    ],
                  ),
                  //  Divider(
                  //   height: 1,
                  //   color: const Color(0xFFc9c9c9),
                  // ),
                  // 当前区域人数
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("当前区域人数:",
                                style: TextStyle(
                                    color:
                                        const Color(ColorConfig.darkTextColor),
                                    fontSize: FontConfig.titleTextSize)),
                            Expanded(
                                child: Container(
                                    margin:
                                        EdgeInsets.only(right: 15, left: 20),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: const Color(
                                                ColorConfig.borderColor),
                                            width: 0.5),
                                        borderRadius: BorderRadius.circular(3)),
                                    child: TextField(
                                        controller: _areaCountController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        enabled: _isShowSaveAndUploadBtn,
                                        style: TextStyle(
                                            color: const Color(
                                                ColorConfig.darkTextColor),
                                            fontSize:
                                                FontConfig.contentTextSize),
                                        inputFormatters: <TextInputFormatter>[
                                          WhitelistingTextInputFormatter
                                              .digitsOnly, // 只输入数字
                                          // LengthLimitingTextInputFormatter(
                                          //     6) // 最大长度
                                        ],
                                        decoration: const InputDecoration(
//                                            hintText: '请输入区域人数',
                                            contentPadding:
                                                const EdgeInsets.all(5.0),
                                            border: InputBorder.none),
                                        // 当value改变的时候，触发
                                        onChanged: (val) {
                                          widget.officeRecord.areaCount =
                                              int.parse(val);
                                        })),
                                flex: 3),
                            Text("人",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color:
                                        const Color(ColorConfig.darkTextColor),
                                    fontSize: FontConfig.contentTextSize)) //)
                          ])),
                  // 拥挤程度
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
//                          color: Colors.white,
                      child: Column(children: <Widget>[
                        Row(children: <Widget>[
                          Text("拥挤程度:",
                              style: TextStyle(
                                  color: const Color(ColorConfig.darkTextColor),
                                  fontSize: FontConfig.titleTextSize))
                        ]),
                        Stack(children: <Widget>[
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                // 已拖动的颜色
                                activeTrackColor: sliderActiveTrackColor,
                                // 未拖动的颜色
                                inactiveTrackColor: Colors.black12,

                                // 提示进度的气泡的背景色
                                valueIndicatorColor: sliderThumbColor,
                                // 提示进度的气泡文本的颜色
                                valueIndicatorTextStyle: TextStyle(
                                  color: Colors.white,
                                ),

                                // 滑块中心的颜色
                                thumbColor: sliderThumbColor,
                                // 滑块边缘的颜色
                                // overlayColor: Colors.white,

                                // divisions对进度线分割后，断续线中间间隔的颜色
                                // inactiveTickMarkColor: Colors.yellow,
                                // disabledActiveTrackColor: Colors.blueAccent,
                                trackHeight: 3),
                            child: Slider(
                              value: sliderValue,
                              label: sliderLabel,
                              min: 1.0,
                              max: 4.0,
                              divisions: 3,
                              onChanged: (val) {
                                setState(() {
                                  sliderValue = val.floorToDouble(); //转化成double
                                  switch (val.floor()) {
                                    case 1:
                                      sliderLabel = "舒适";
                                      widget.officeRecord.crowdLevel = 4;
                                      sliderActiveTrackColor = Colors.green;
                                      sliderThumbColor = Colors.green;
                                      break;
                                    case 2:
                                      sliderLabel = "一般";
                                      widget.officeRecord.crowdLevel = 3;
                                      sliderActiveTrackColor =
                                          Colors.blueAccent;
                                      sliderThumbColor = Colors.blueAccent;
                                      break;
                                    case 3:
                                      sliderLabel = "拥挤";
                                      widget.officeRecord.crowdLevel = 2;
                                      sliderActiveTrackColor =
                                          Colors.orangeAccent;
                                      sliderThumbColor = Colors.orangeAccent;
                                      break;
                                    default:
                                      widget.officeRecord.crowdLevel = 1;
                                      sliderLabel = "非常拥挤";
                                      sliderActiveTrackColor = Colors.redAccent;
                                      sliderThumbColor = Colors.redAccent;
                                  }
                                });
                              },
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 35),
                              child: Row(children: <Widget>[
                                Expanded(
                                    child: Text("舒适",
                                        style: TextStyle(color: Colors.green),
                                        textAlign: TextAlign.center),
                                    flex: 1),
                                Expanded(
                                    child: Text("一般",
                                        style:
                                            TextStyle(color: Colors.blueAccent),
                                        textAlign: TextAlign.center),
                                    flex: 1),
                                Expanded(
                                    child: Text("拥挤",
                                        style: TextStyle(color: Colors.orange),
                                        textAlign: TextAlign.center),
                                    flex: 1),
                                Expanded(
                                    child: Text("非常拥挤",
                                        style: TextStyle(color: Colors.red),
                                        textAlign: TextAlign.center),
                                    flex: 1)
                              ]))
                        ])
                      ])),
                  // 情况说明
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Column(children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text("情况说明:",
                                style: TextStyle(
                                    color:
                                        const Color(ColorConfig.darkTextColor),
                                    fontSize: FontConfig.titleTextSize))
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: const Color(ColorConfig.borderColor),
                                    width: 0.5),
                                borderRadius: BorderRadius.circular(3)),
                            child: TextField(
                                controller: _explainController,
                                enabled: _isShowSaveAndUploadBtn,
                                // inputFormatters: [
                                //   WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[\u4e00-\u9fa5]|[0-9]")), //只能输入汉字或者字母或数字
                                //   LengthLimitingTextInputFormatter(200), //最大长度
                                // ],
                                maxLength: 200,
                                style: TextStyle(
                                    color:
                                        const Color(ColorConfig.darkTextColor),
                                    fontSize: FontConfig.contentTextSize),
                                decoration: const InputDecoration(
                                    fillColor: Colors.white,
                                    hintText: '请输入情况说明',
                                    contentPadding: const EdgeInsets.all(10.0),
                                    border: InputBorder.none),
                                maxLines: 4,
                                // 当 value 改变的时候，触发
                                onChanged: (val) {}))
                      ])),
                  // 拍照
                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 150),
                      child: GridView.builder(
                          shrinkWrap: true,
                          // 关键属性 https://blog.csdn.net/qq_32319999/article/details/80353976
                          padding: const EdgeInsets.all(0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 横向Item个数
                            mainAxisSpacing: 8.0, // 横向间隔
                            crossAxisSpacing: 8.0, // 竖向间隔
                          ),
                          itemCount: _mediaModels.length < MaxImageCount
                              ? _mediaModels.length + 1
                              : MaxImageCount,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == _mediaModels.length &&
                                index < MaxImageCount) {
                              return _isShowSaveAndUploadBtn
                                  ? GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                          // add new picture
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.rectangle,
                                            border: Border.all(
                                                color: const Color(
                                                    ColorConfig.borderColor),
                                                width: 0.5),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(3.0)),
                                          ),
                                          alignment:
                                              AlignmentDirectional.center,
                                          child: Image.asset(
                                              'images/ic_camera.png',
                                              height: 25,
                                              width: 25)),
                                      onTap: () {
                                        showAlertDialog(context);
                                      })
                                  : Container();
                            } else {
                              return _buildImageContainer(index);
                            }
                          }))
                ])),
            floatingActionButton: _isShowSaveAndUploadBtn
                ? FloatingActionButton(
                    heroTag: 'office_info_btn',
                    onPressed: _uploadOfficeRecord,
                    tooltip: '提交',
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.file_upload),
                          Text("提交", style: TextStyle(fontSize: 10))
                        ]))
                : null));
  }

  // 保存办公室巡查内容
  _saveOfficeRecord(bool isShowToast, int isUpload) async {
    if (_checkNeedSave() == false) {
      CommonUtils.showTextToast("无需要保存的内容");
      return;
    }

    String _images = "";
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    /**
     * 该记录的图片存储目录
     * images/0——办公室
     * images/1——设备科
     * images/2——保卫科
     * images/3——异常上报
     */
    String recordImgPath =
        "${documentsDirectory.path}/images/0/${widget.officeRecord.id}";
    String simpleRecordImgPath =
        "/images/0/${widget.officeRecord.id}"; // 不带前缀的图片路径

    if (_mediaModels.length != 0) {
      for (int i = 0; i < _mediaModels.length; i++) {
        MediaModel media = _mediaModels[i];
        // 将图片保存到"该记录的图片存储目录"
        String imgName = FileUtils.getFileName(media.mediafile.path);
        var isExist = await FileUtils.isExistsFile("$recordImgPath/$imgName");
        print("图片$i存储结果：$isExist\n 图片路径：$recordImgPath/$imgName");
        if (!isExist) {
          await FileUtils.copyFile(
              media.mediafile.path, "$recordImgPath/$imgName");
          // 将图片文件更新为"该记录的图片存储目录"中的图片文件（之前为相册中的文件）  cy+ remove
          // imageFiles[i] =
          //     MediaModel(File("$recordImgPath/$imgName"), media.type);
        }

        // 拼接存储到数据库中的图片字符串
        _images = (i == 0)
            ? "$simpleRecordImgPath/$imgName"
            : (_images + "," + "$simpleRecordImgPath/$imgName");
        print(_images);
      }
    }

    if (sliderValue == 1) {
      widget.officeRecord.crowdLevel = 4;
    } else if (sliderValue == 2) {
      widget.officeRecord.crowdLevel = 3;
    } else if (sliderValue == 3) {
      widget.officeRecord.crowdLevel = 2;
    } else if (sliderValue == 4) {
      widget.officeRecord.crowdLevel = 1;
    }

    Map userMap = await UserinfoUtils.getUserInfo();
    widget.officeRecord.inspectorId = userMap[Config.USER_ID];
    widget.officeRecord.inspectorName = userMap[Config.USER_REALNAME];
    widget.officeRecord.areaCount = (_areaCountController.text == "")
        ? 0
        : int.parse(_areaCountController.text);
    widget.officeRecord.explain = _explainController.text;
    widget.officeRecord.imagesPath = _images;
    widget.officeRecord.time = DateUtils.getCurrentTime();
    widget.officeRecord.isUpload = isUpload;

    await TabOfficeRecordManager().insert(widget.officeRecord);
    // print('测试' + result.toString());
    if (isShowToast) {
      CommonUtils.showTextToast("保存成功");
    }
  }

  // 上传前检查上传情况
  _checkNeedSave() {
    if (_explainController.text.length == 0 &&
        _mediaModels.length == 0 &&
        (_areaCountController.text == '0' || _areaCountController.text == '')) {
      CommonUtils.showCenterTextToast('请填写情况说明');
      return false;
    }
    return true;
  }

  _checkOfficeRecord() {
    if (_areaCountController.text == '0' || _areaCountController.text == '') {
      CommonUtils.showCenterTextToast('当前区域人数不能为0');
      return false;
    }
    if (_explainController.text.length == 0) {
      CommonUtils.showCenterTextToast('请填写情况说明');
      return false;
    }
    if (_mediaModels.length == 0) {
      CommonUtils.showCenterTextToast('请选择至少一张图片');
      return false;
    }
    return true;
  }

  // 上传办公室巡查内容
  _uploadOfficeRecord() async {
    print('uploadAbnormalRecord');

    // 先检查上传内容
    if (_checkOfficeRecord() == false) return;

    CommonUtils.showLoadingDialog(
        context, '努力上传中...', SpinKitType.SpinKit_Circle);
    /**
     * 上传图片（支持多张图片）
     */
    String _picids = " "; // 图片guid拼接
    String _picpaths = ""; // 图片网络地址拼接（用于第三步中的数据库存储）
    if (_mediaModels.length != 0) {
      DataResult dataResult =
          await NetUtils.uploadImg(Address.uploadImg('14'), _mediaModels);
      if (dataResult.result) {
        dynamic responseList = dataResult.data;
        for (var i = 0; i < _mediaModels.length; i++) {
          if (i == 0) {
            _picids = responseList[i]['Guid'];
            _picpaths = responseList[i]['FilePath'];
          } else {
            _picids = _picids + "," + responseList[i]['Guid'];
            _picpaths = _picpaths + "," + responseList[i]['FilePath'];
          }
        }
      } else {
        Navigator.pop(context);
        CommonUtils.showTextToast(dataResult.description);
        return;
      }
    }
    print('picids:' + _picids);

    /**
     * 保存客流高峰数据
     */
    if (sliderValue == 1) {
      widget.officeRecord.crowdLevel = 4;
    } else if (sliderValue == 2) {
      widget.officeRecord.crowdLevel = 3;
    } else if (sliderValue == 3) {
      widget.officeRecord.crowdLevel = 2;
    } else if (sliderValue == 4) {
      widget.officeRecord.crowdLevel = 1;
    }
    Map<String, dynamic> userinfoMap = await UserinfoUtils.getUserInfo();
    widget.officeRecord.inspectorId = userinfoMap[Config.USER_ID];
    widget.officeRecord.areaCount = (_areaCountController.text == "")
        ? 0
        : int.parse(_areaCountController.text);
    widget.officeRecord.explain = _explainController.text;
    String _cjsj = json
        .encode(widget.officeRecord.toJson(userinfoMap[Config.USER_REALNAME]));
    print('cjsj：' + _cjsj);
    DataResult uploadDataResult = await NetUtils.uploadToNet(
        Address.saveCJSJ(), {'cjsj': _cjsj, 'picids': _picids});
    // print("saveCJSJ返回值:" + uploadDataResult.data);

    Navigator.pop(context); // hide loading dialog

    if (uploadDataResult.result) {
      // CommonUtils.showTextToast("数据上传成功");
    } else {
      CommonUtils.showTextToast(uploadDataResult.description);
      return;
    }

    /**
     * 数据库存储（修改数据库中 图片网络地址、是否上传、上传时间）
     */
    widget.officeRecord.imagesUrl = _picpaths;
    widget.officeRecord.isUpload = 1;
    widget.officeRecord.time = DateUtils.getCurrentTime();
    await _saveOfficeRecord(false, 1);

    CommonUtils.showAlertDialog(context, '温馨提示', "上传成功", () {}).then((_) {
      Navigator.pop(context);
    });
  }

  /// 构建Image和删除按钮的组合
  Widget _buildImageContainer(int index) {
    // 缩略图
    MediaType mediaType = _mediaModels[index].type;
    File thumnailFile = _mediaModels[index].thumbnailFile;

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) {
            return MaxHomePage(_mediaModels, index);
          }));
        },
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: const Color(ColorConfig.borderColor), width: 0.5),
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
                image: DecorationImage(
                    image: (thumnailFile == null)
                        ? ExactAssetImage('images/no_video.png')
                        : FileImage(thumnailFile),
                    fit: BoxFit.cover)),
            child: Stack(children: <Widget>[
              (mediaType == MediaType.MediaVideo)
                  ? Container(
                      alignment: AlignmentDirectional.center,
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ))
                  : Container(),
              (_isShowSaveAndUploadBtn)
                  ? Container(
                      alignment: AlignmentDirectional.topEnd,
                      child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Icon(Icons.clear, color: Colors.grey[200]),
                          onTap: () {
                            _removeMedia(index);
                          }))
                  : Container()
            ])));
  }

  /// Action：take photo from album or camera
  void showAlertDialog(BuildContext context) {
    showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(title: Text('选择'), children: <Widget>[
            SimpleDialogOption(
              child: Text('拍摄', style: TextStyle(fontSize: 16.0)),
              onPressed: () async {
                Navigator.of(context).pop(); // 提示框出栈
                final mediaPath =
                    await Navigator.of(context).pushNamed(CAMERA_SCREEN);
                print('media from camera $mediaPath');
                _addMedia(mediaPath);
              },
            ),
            SimpleDialogOption(
                child: Text('从相册中选择', style: TextStyle(fontSize: 16.0)),
                onPressed: () async {
                  Navigator.of(context).pop(); // 提示框出栈
                  File image =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  _addMedia(image.path, type: MediaType.MediaImage);
                }),
            // SimpleDialogOption(
            //     child: Text('从视频中选择', style: TextStyle(fontSize: 16.0)),
            //     onPressed: () async {
            //       Navigator.of(context).pop(); // 提示框出栈
            //       File video =
            //           await ImagePicker.pickVideo(source: ImageSource.gallery);
            //       if(video.lengthSync()  >= 10 * 1024 * 1024)  CommonUtils.showTextToast('选择的视频大小超过10M，请重新选择');
            //       else _addMedia(video.path, type: MediaType.MediaVideo);
            //     })
          ]);
        });
  }
}
