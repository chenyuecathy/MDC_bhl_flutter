import 'dart:convert';
import 'dart:io'; // file
import 'dart:ui'; //引入ui库，因为ImageFilter Widget在这个里边。

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/net/address.dart';

import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/model/media_data.dart';

import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/utils/file_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:mdc_bhl/utils/userinfo_utils.dart';

import 'package:mdc_bhl/widget/gradient_appbar.dart';
import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/page/max/max_home_page.dart';
import 'package:mdc_bhl/page/record/task/widget/disposal_widget.dart';
import '../../main.dart';

// 通过id查找图片存储的路径
const Map<String, dynamic> DepartmentToTypeMap = {
  Config.DEPARTMENT_ID_OFFICE: '0', // 办公室
  Config.DEPARTMENT_ID_DEVICE: '1', // 设备科
  Config.DEPARTMENT_ID_GUARD: '2', // 保卫科
};

class DeviceAbnormalPage extends StatefulWidget {
  final TabDeviceRecordModel taskRecordModel;
  final String title;
  final bool showDispoalView;

  DeviceAbnormalPage(this.taskRecordModel, this.title,
      {this.showDispoalView = false});

  @override
  State<StatefulWidget> createState() =>
      DeviceAbnormalPageState(this.taskRecordModel);
}

class DeviceAbnormalPageState extends State<DeviceAbnormalPage> {
  TextEditingController _explainController = TextEditingController();

  List<MediaModel> _mediaModels = [];
  TabDeviceRecordModel _taskRecordModel;
  DeviceAbnormalPageState(this._taskRecordModel);
  // List<File> _meidaThumbnails = [];

  // 视频Map（key：imageFiles中的index，value：视频File）
  // Map<int, File> videoMap =  Map();

  static const int MaxImageCount = 9; // 最大照片
  bool _isShowSaveAndUploadBtn = true; // 是否显示保存和上传按钮

  @override
  void initState() {
    _initData();
    // _getVideoMap(); // 获取视频下标和缩略图Map
    super.initState();
  }

  _initData() async {
    /// initial textfield
    if (_taskRecordModel.abnormalExplain != null) {
      _explainController.text = _taskRecordModel.abnormalExplain;
    }

    /// initial video and image
    if (_taskRecordModel.abnormalImagesPath != null &&
        _taskRecordModel.abnormalImagesPath.length > 0) {
      List imagePaths = _taskRecordModel.abnormalImagesPath.split(',');

      String documentsPath = await FileUtils.getDocumentPath();
      setState(() {
        for (var mediaPath in imagePaths) {
          String fullPath = documentsPath + mediaPath;
          _addMedia(fullPath);
        }
      });
    }

    /// 是否显示保存和上传按钮
    if (_taskRecordModel.isUpload == 1) {
      _isShowSaveAndUploadBtn = false;
    } else {
      _isShowSaveAndUploadBtn = true;
    }
  }

  /// process meidaModel list and thumbnail list
  _addMedia(String mediaPath, {MediaType type = MediaType.MediaUnknown}) async {
    // TODO: check path  is fullpath or reletivePath

    // if (mediaPath == null || mediaPath.length == 0) return;
    assert((mediaPath != null && mediaPath.length != 0),
        'mediaPath can not be null');

    File mediaFile = File(mediaPath);
    print('device_abnormal_page <_initData> 图片路径：$mediaPath');

    if (type == MediaType.MediaUnknown) {
      // get format of meida recording meida path
      List partsOfPath = mediaPath.split('.');
      String imgFormat = partsOfPath[partsOfPath.length - 1];
      print('device abnormal page  - media format : $imgFormat');
      List imageFormats = ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'];
      type = imageFormats.contains(imgFormat)
          ? MediaType.MediaImage
          : MediaType.MediaVideo;
    }

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
    debugPrint('abnormal delete image of $index');
    setState(() {
      _mediaModels.removeAt(index);
      debugPrint('abnormal image ${_mediaModels.length}');
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
    _explainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("abnormal page🧭 🏳️\u200d🌈");
    // print(widget.taskRecordModel);
    // print(_taskRecordModel);
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
              title: Text(widget.title,
                  style: TextStyle(fontSize: FontConfig.naviTextSize)),
              leading: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.pop(context, "0");
                  },
                  child: Icon(Icons.chevron_left, size: 30)),
              actions: <Widget>[
                _isShowSaveAndUploadBtn
                    ? Center(
                        child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _saveAbnormalRecord(true, 0);
                            },
                            child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Text("保存",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: FontConfig.titleTextSize)))))
                    : Container()
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
                    //         sigmaX: 5.0, sigmaY: 5.0), //图片模糊过滤，横向竖向都设置5.0
                    //     child: Opacity(
                    //       //透明控件
                    //       opacity: 0.5,
                    // child:
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // BackdropFilter(
                        //     //背���滤镜器
                        //     filter: ImageFilter.blur(
                        //         sigmaX: 5.0, sigmaY: 5.0), //图片��糊过滤，横向竖向都设置5.0
                        //     child: Opacity(
                        //       //透明控件
                        //       opacity: 0.5,
                        // child:
                        Image.asset('images/ic_task_bg.jpg',
                            height: 65,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill),
                        Container(
                            padding: EdgeInsets.fromLTRB(20, 3, 20, 3),
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(_taskRecordModel.recordTitle,
                                    style: TextStyle(
                                        color: const Color(
                                            ColorConfig.darkTextColor),
                                        fontWeight: FontWeight.bold,
                                        fontSize: FontConfig.normalTextSize)),
                                Image.asset('images/ic_abnormal.png',
                                    height: 45, width: 45)
                              ],
                            )),
                      ],
                    ),
                    // )),
                  ],
                ),
                //  Divider(
                //   height: 1,
                //   color: const Color(0xFFc9c9c9),
                // ),
                // 情况说明
                Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("情况说明:",
                              style: TextStyle(
                                  color: const Color(ColorConfig.darkTextColor),
                                  fontSize: FontConfig.titleTextSize))
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(ColorConfig.borderColor),
                                  width: 0.5),
                              borderRadius: BorderRadius.circular(3)),
                          child: TextField(
                              controller: _explainController,
                              enabled: _isShowSaveAndUploadBtn,
                              // inputFormatters: [
                              //   WhitelistingTextInputFormatter(RegExp(
                              //       "[a-zA-Z]|[\u4e00-\u9fa5]|[0-9]")), //只能输入汉字或者字母或数字
                              //   LengthLimitingTextInputFormatter(200), //最大长度
                              // ],
                              maxLength: 200,
                              style: TextStyle(
                                  color: const Color(ColorConfig.darkTextColor),
                                  fontSize: FontConfig.contentTextSize),
                              decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  hintText: '请输入情况说明',
                                  contentPadding: const EdgeInsets.all(10.0),
                                  border: InputBorder.none),
                              maxLines: 5,
                              // 当 value 改变的时候，触发
                              onChanged: (val) {}))
                    ])),
                // 拍照
                Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: GridView.builder(
                        shrinkWrap: true,
                        // 关键属性 https://blog.csdn.net/qq_32319999/article/details/80353976
                        padding: const EdgeInsets.all(0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 横向Item个数
                          mainAxisSpacing: 8.0, // 横向间隔
                          crossAxisSpacing: 8.0, // 竖向间隔
                        ),
                        itemCount: (_mediaModels.length == MaxImageCount ||
                                _taskRecordModel.isUpload == 1)
                            ? _mediaModels.length
                            : _mediaModels.length + 1,
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
                                        alignment: AlignmentDirectional.center,
                                        child: Image.asset(
                                            'images/ic_camera.png',
                                            height: 25,
                                            width: 25)),
                                    onTap: () {
                                      showAlertDialog(context);
                                    },
                                  )
                                : Container();
                          } else {
                            return _buildImageContainer(index);
                          }
                        })),
                widget.showDispoalView
                    // ? Card(
                    //     color: Colors.white,
                    //     elevation: 3,
                    //     margin: EdgeInsets.symmetric(
                    //         horizontal: 20.0, vertical: 20.0),
                    //     shape: const RoundedRectangleBorder(
                    //       borderRadius:
                    //           BorderRadius.all(Radius.circular(14.0)), // 圆角
                    //     ),
                    ? Column(children: <Widget>[
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow:[BoxShadow(color: Colors.black26,offset: Offset(2, 2), blurRadius: 6.0, spreadRadius: 2.0)],),
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          child: DisposalWidget(_taskRecordModel.isChecked,
                              disposalModel: DisposalModel(
                                  date: _taskRecordModel.checkTime == 'null'
                                      ? ''
                                      : _taskRecordModel.checkTime,
                                  method: _taskRecordModel.checkWay == 'null'
                                      ? ''
                                      : _taskRecordModel.checkWay,
                                  disposer:
                                      _taskRecordModel.checkerName == 'null'
                                          ? ''
                                          : _taskRecordModel.checkerName),
                              onClickDisposal: (DisposalModel model) {
                            // print(model);
                            if (!checkDisposalInfo(model)) return;

                            _taskRecordModel.checkWay = model.method;
                            _taskRecordModel.checkTime = model.date;
                            _taskRecordModel.checkerName = model.disposer;

                            uploadDisposalInfo();
                          }),
                        )
                      ])
                    : Container()
              ])),
          floatingActionButton: _isShowSaveAndUploadBtn
              ? FloatingActionButton(
                  heroTag: 'device_abnormal_page_btn',
                  onPressed: _uploadAbnormalRecord,
                  tooltip: '提交',
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.file_upload),
                        Text("提交", style: TextStyle(fontSize: 10))
                      ]))
              : null),
    );
  }

  bool checkDisposalInfo(DisposalModel model) {
    if (model.date == null || model.date.length == 0) {
      CommonUtils.showTextToast('请输入处置时间!');
      return false;
    }
    if (model.method == null || model.method.length == 0) {
      CommonUtils.showTextToast('请输入处置方法!');
      return false;
    }
    if (model.disposer == null || model.disposer.length == 0) {
      CommonUtils.showTextToast('请输入处置人!');
      return false;
    }
    return true;
  }

  uploadDisposalInfo() async {
    CommonUtils.showLoadingDialog(
        context, '努力上传中...', SpinKitType.SpinKit_Circle);

    Map czsj = {
      "ID": _taskRecordModel.id,
      "CJSJID": _taskRecordModel.id, //异常数据ID
      "CZSJ": _taskRecordModel.checkTime, //处置时间
      "CZFF": _taskRecordModel.checkWay, //处置方式
      "CZR": _taskRecordModel.checkerName //处置人
    };
    print(json.encode(czsj));
    DataResult uploadDataResult = await NetUtils.uploadToNet(
        Address.saveYccz(), {'czsj': json.encode(czsj)});
    // print("saveCZSJ返回值:${uploadDataResult.description}");

    Navigator.pop(context); // hide loading dialog

    if (uploadDataResult.result) {
      // CommonUtils.showTextToast("数据上传成功");
    } else {
      CommonUtils.showTextToast(uploadDataResult.description);
      return;
    }

    /**
     * 数据库存储（修改数据库中 处置状态）
     */
    _taskRecordModel.isChecked = 1;
    await TabDeviceRecordManager.updateDisposalStateWithRecordId(
        _taskRecordModel);

    CommonUtils.showAlertDialog(context, '温馨提示', "处置数据上传成功", () {}).then((_) {
      Navigator.pop(context, '1'); // 返回已处置
    });
  }

  // 保存异常巡查内容
  _saveAbnormalRecord(bool isShowToast, int isUpload) async {
    if (_checkNeedSave() == false) {
      CommonUtils.showTextToast("无需要保存的内容");
      return;
    }

    String _images = "";
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    Map userinfoMap = await UserinfoUtils.getUserInfo();
    _taskRecordModel.inspectorId = userinfoMap[Config.USER_ID];
    _taskRecordModel.inspectorName = userinfoMap[Config.USER_REALNAME];
    String imageIndex = DepartmentToTypeMap[userinfoMap[Config.USER_DWID]];

    /**
     * 该记录的图片存储目录
     * images/0——办公室
     * images/1—��设备科
     * images/2——���卫科
     * images/3——异常上报
     */
    String recordImgPath =
        "${documentsDirectory.path}/images/$imageIndex/${_taskRecordModel.id}";
    String simpleRecordImgPath =
        "/images/$imageIndex/${_taskRecordModel.id}"; // 不带前缀的图��路径

    if (_mediaModels.length != 0) {
      for (var i = 0; i < _mediaModels.length; i++) {
        MediaModel media = _mediaModels[i];
        // 将图片保存到"该记录的图片存储目录"
        String imgName = FileUtils.getFileName(media.mediafile.path);
        var isExist = await FileUtils.isExistsFile("$recordImgPath/$imgName");
        print("图片$i存储结果：$isExist\n 图片路径：$recordImgPath/$imgName");
        if (!isExist) {
          await FileUtils.copyFile(
              media.mediafile.path, "$recordImgPath/$imgName");
        }

        // 拼接存储到数据库中的图片字符串
        _images = (i == 0)
            ? "$simpleRecordImgPath/$imgName"
            : (_images + "," + "$simpleRecordImgPath/$imgName");
        print('存储到数据库中的本地图片存储路径：' + _images);
        // 将图片文件更新为"该记录的图片存储目录"中的图片文件（之前为相册中的文件）cy+ remove
        // imageFiles[i] = File("$recordImgPath/$imgName");
      }
    }

    _taskRecordModel.recordType = 0;
    _taskRecordModel.isAbnormal = 2;
    _taskRecordModel.abnormalExplain = _explainController.text;
    _taskRecordModel.abnormalImagesPath = _images;
    _taskRecordModel.time = DateUtils.getCurrentTime();
    _taskRecordModel.isUpload = isUpload;

    print('TaskDeviceHasItem insert method $_taskRecordModel');

    await TabDeviceRecordManager().insert(_taskRecordModel);

    // print('测试' + result.toString());

    if (isShowToast) {
      CommonUtils.showTextToast("保存成功");
    }
  }

  // 上传前检查上传情况
  _checkAbnormalRecord() {
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

  // 保存前检查上传内容
  _checkNeedSave() {
    if (_explainController.text.length == 0 && _mediaModels.length == 0) {
      return false;
    }
    return true;
  }

  // 上传巡查内容
  _uploadAbnormalRecord() async {
    // print('uploadAbnormalRecord');

    // 先检查上传内容
    if (_checkAbnormalRecord() == false) return;

    CommonUtils.showLoadingDialog(
        context, '努力上传中...', SpinKitType.SpinKit_Circle);
    /**
     * 上传图片（支持多张图片）
     */
    String _picids = ""; // 图片guid拼接 后期删除
    String _picpaths = ""; // 图片网络地址拼接（用于第三步中的数据库存储）
    if (_mediaModels.length != 0) {
      DataResult dataResult =
          await NetUtils.uploadImg(Address.uploadImg('12'), _mediaModels);
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
        Navigator.pop(context, '0');
        CommonUtils.showTextToast(dataResult.description);
        return;
      }
    }
    print('picids:' + _picids);

    /**
     * 保存日常巡查的 数据
     */
    Map userinfoMap = await UserinfoUtils.getUserInfo();
    _taskRecordModel.inspectorId = userinfoMap[Config.USER_ID];
    _taskRecordModel.inspectorName = userinfoMap[Config.USER_REALNAME];

    _taskRecordModel.abnormalExplain = _explainController.text;
    print('record type ${_taskRecordModel.recordState}');
    String _cjsj = json.encode(_taskRecordModel.toJson()); // 正常异常
    print('cjsj：' + _cjsj);
    DataResult uploadDataResult = await NetUtils.uploadToNet(
        Address.saveRCXCCJSJ(), {'cjsj': _cjsj, 'picids': _picids});
    print("saveCJSJ返回值:${uploadDataResult.description}");

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
    _taskRecordModel.abnormalImagesUrl = _picpaths;
    _taskRecordModel.isUpload = 1;
    _taskRecordModel.time = DateUtils.getCurrentTime();
    await _saveAbnormalRecord(false, 1);

    CommonUtils.showAlertDialog(context, '温馨提示', "数据上传成功", () {}).then((_) {
      Navigator.pop(context);
    });
  }

  /// 构建Image和删除按钮的组合
  Widget _buildImageContainer(int index) {
    // 照片
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
                    await Navigator.of(context).pushNamed(TAKE_PHOTO_AND_VIDEO);
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
            SimpleDialogOption(
                child: Text('从视频中选择', style: TextStyle(fontSize: 16.0)),
                onPressed: () async {
                  Navigator.of(context).pop(); // 提示框出栈
                  File video =
                      await ImagePicker.pickVideo(source: ImageSource.gallery);
                  if(video.lengthSync()  >= 10 * 1024 * 1024)  CommonUtils.showTextToast('选择的视频大小超过10M，请重新选择');
                  else _addMedia(video.path, type: MediaType.MediaVideo);
                })
          ]);
        });
  }
}

