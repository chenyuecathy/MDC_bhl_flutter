import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/net/address.dart';
import 'package:mdc_bhl/db/tab_inspection.dart';
import 'package:mdc_bhl/db/tab_report_record_manager.dart';
import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/model/media_data.dart';
import 'package:mdc_bhl/page/max/max_home_page.dart';
import 'package:mdc_bhl/page/record/task/widget/disposal_widget.dart';
import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';
import 'package:mdc_bhl/utils/file_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:mdc_bhl/utils/userinfo_utils.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../main.dart';

class ReportPage extends StatefulWidget {
  final bool isFromRecord;
  final TabReportRecordModel reportRecord;
  final bool showDispoalView;

  ReportPage(this.isFromRecord, {this.reportRecord, this.showDispoalView = false}); // 从"我的采集"进入会有该参数

  @override
  State<StatefulWidget> createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Codec<String, String> stringToBase64 = utf8.fuse(base64); // 用于编码

  // 生成两种uuid（巡查表id、巡查内容id）
  String _inspectionId;
  String _recordId = Uuid().v1();

  String _userId;
  String _userName;

  TextEditingController _locationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  FocusNode _locationFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();

  List<MediaModel> _mediaModels = [];

  ///configuretion object
  static const int MaxImageCount = 9; // 最大照片
  bool _isShowSaveAndUploadBtn = true; // 是否显示保存和上传按钮

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() async {
    /// initial useinfo
    Map<String, dynamic> userInfo = await UserinfoUtils.getUserInfo();
    _userId = userInfo[Config.USER_ID];
    _userName = userInfo[Config.USER_REALNAME];

    if (widget.reportRecord == null) {
      return;
    }

    /// initial insepection id  and record id
    _inspectionId = widget.reportRecord.inspectionId;
    _recordId = widget.reportRecord.id;

    /// initial textfield
    _locationController.text = stringToBase64.decode(widget.reportRecord.location);
    _descriptionController.text = stringToBase64.decode(widget.reportRecord.explain);

    /// initial image and video
    if (widget.reportRecord.imagesPath != null && widget.reportRecord.imagesPath.length > 0) {
      List imagePaths = widget.reportRecord.imagesPath.split(',');

      String documentsPath = await FileUtils.getDocumentPath();
      setState(() {
        for (var mediaPath in imagePaths) {
          String fullPath = documentsPath + mediaPath;
          _addMedia(fullPath);
        }
      });
    }

    // initial button tag 是否显示保存和上传按钮
    if (widget.reportRecord.isUpload == 1) {
      setState(() {
        _isShowSaveAndUploadBtn = false;
      });
    } else {
      setState(() {
        _isShowSaveAndUploadBtn = true;
      });
    }
  }

  /// process meidaModel list and thumbnail list
  _addMedia(String mediaPath, {MediaType type = MediaType.MediaUnknown}) async {
    /// TODO: check path  is fullpath or reletivePath

    // if (mediaPath == null || mediaPath.length == 0) return;
    assert((mediaPath != null && mediaPath.length != 0), 'mediaPath can not be null');

    File mediaFile = File(mediaPath);
    print('report_page <_initData> 图片路径：$mediaPath');

    if (type == MediaType.MediaUnknown) {
      // get format of meida recording meida path
      List partsOfPath = mediaPath.split('.');
      String imgFormat = partsOfPath[partsOfPath.length - 1];
      print('report  page  - media format : $imgFormat');
      List imageFormats = ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'];
      type = imageFormats.contains(imgFormat) ? MediaType.MediaImage : MediaType.MediaVideo;
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
        _mediaModels.add(MediaModel(mediaFile, type, thumbnailFile: videoThumbnail));
      });
    }
  }

  void _removeMedia(int index) {
    debugPrint('report delete image of $index');
    setState(() {
      _mediaModels.removeAt(index);
      debugPrint('report image ${_mediaModels.length}');
    });
  }

  // 获取图片的缩略图
  _getVideoThumbnail(File video) async {
    String imgPath = await VideoThumbnail.thumbnailFile(
      video: video.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeightOrWidth: 0,
      quality: 100,
    );
    print(imgPath);
    return File(imgPath);
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    // 发送订阅消息刷新异常上报列表
    eventBus.fire(EventUtil(Config.REFRESH_MY_REPORT_LIST, null));
    super.dispose();
  }

  Future _initReportId() async {
    String reportId;
    /******************************/
    TabInspectionManager tabInspectionManager = TabInspectionManager();
    // 服务——获取异常上报id
    var rcxcbURL = Address.getRCXCB();
    var response = await NetUtils.get(rcxcbURL, {'xclx': 3});
    Map<String, dynamic> responseDictionary = json.decode(response);
    dynamic isSuccess = responseDictionary['IsSuccess'];
    if (isSuccess) {
      reportId = responseDictionary['ResultValue']['Xcjlid'];
    }
    // 数据库——将异常上报记录插入本地库"巡查表"
    TabInspectionModel _tabInspectionModel = TabInspectionModel();
    _tabInspectionModel.id = reportId;
    _tabInspectionModel.inspectorId = _userId;
    _tabInspectionModel.inspectionType = 3;
    _tabInspectionModel.inspectionState = 0;
    _tabInspectionModel.inspectionTime = DateUtils.getCurrentDay();
    await tabInspectionManager.insert(_tabInspectionModel);
    _inspectionId = reportId;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // print('report page ${widget.reportRecord.toString()}');
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          /// 通���GestureDetector捕获点击事件，再通�����FocusScope将焦点转移至空焦点—— FocusNode()
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            appBar: GradientAppBar(
                gradientStart: Color(0xFF2171F5),
                gradientEnd: Color(0xFF49A2FC),
                centerTitle: true,
                title: Text('异常上报', style: TextStyle(fontSize: FontConfig.naviTextSize)),
                actions: <Widget>[
                  _isShowSaveAndUploadBtn
                      ? Center(
                          child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _initReportId().then((_) {
                                  _saveReportRecord(false, null);
                                });
                              },
                              child: Padding(padding: EdgeInsets.all(15), child: Text("保存", style: TextStyle(color: Colors.white, fontSize: FontConfig.titleTextSize)))))
                      : Container()
                ]),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(0.0),
              scrollDirection: Axis.vertical,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 位置
                      Row(children: <Widget>[
                        Text('* ', style: TextStyle(color: Colors.redAccent, fontSize: FontConfig.titleTextSize)),
                        Text('位置:', style: TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.titleTextSize))
                      ]),
                      const SizedBox(height: 5.0), // 占位图
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(ColorConfig.borderColor), width: 0.5), borderRadius: BorderRadius.circular(3)),
                          child: TextField(
                              controller: _locationController,
                              focusNode: _locationFocusNode,
                              // 是否自动更正
                              autocorrect: true,
                              // 是否自动对焦
                              autofocus: false,
                              //输入文本的样式
                              style: TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.contentTextSize),
                              decoration: InputDecoration.collapsed(hintText: ''),
                              enabled: true)),
                      const SizedBox(height: 20.0), // 占位图
                      // 情况说明
                      Text('情况说明:', style: TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.titleTextSize)),
                      const SizedBox(height: 5.0), // 占位图
                      buildTextField(_descriptionController, _descriptionFocusNode, 2),
                      const SizedBox(height: 30.0), // 占位图
                      // 拍照
                      GridView.builder(
                          shrinkWrap: true,
                          // 关键属性 https://blog.csdn.net/qq_32319999/article/details/80353976
                          padding: const EdgeInsets.all(0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 横向Item个数
                            mainAxisSpacing: 8.0, // 横向间隔
                            crossAxisSpacing: 8.0, // 竖向间隔
                          ),
                          itemCount: _mediaModels.length < MaxImageCount ? _mediaModels.length + 1 : MaxImageCount,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == _mediaModels.length && index < MaxImageCount) {
                              return _isShowSaveAndUploadBtn
                                  ? GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                          margin: EdgeInsets.only(bottom: 0.3),
                                          // add  picture
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.rectangle,
                                            border: Border.all(color: const Color(ColorConfig.borderColor), width: 0.5),
                                            borderRadius: BorderRadius.all(Radius.circular(3.0)),
                                          ),
                                          alignment: AlignmentDirectional.center,
                                          child: Image.asset('images/ic_camera.png', height: 25, width: 25)),
                                      onTap: () {
                                        _showAlertDialog(context);
                                      })
                                  : Container();
                            } else {
                              return _buildImageContainer(index);
                            }
                          }),
                    ],
                  ),
                ),
                widget.showDispoalView
                    // ? Card(
                    //     color: Colors.white,
                    //     elevation: 0,
                    //     margin: EdgeInsets.symmetric(
                    //         horizontal: 0.0, vertical: 10.0),
                    // shape: const RoundedRectangleBorder(
                    //   borderRadius:
                    //       BorderRadius.all(Radius.circular(14.0)), // 圆角
                    // ),
                    ? Column(
                        children: <Widget>[
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 6.0, spreadRadius: 2.0)],
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                            child: DisposalWidget(widget.reportRecord.isChecked,
                                disposalModel: DisposalModel(
                                    date: widget.reportRecord.checkTime == 'null' ? DateTime.now().toString().substring(0, 10) : widget.reportRecord.checkTime,
                                    method: widget.reportRecord.checkWay == 'null' ? '' : widget.reportRecord.checkWay,
                                    disposer: widget.reportRecord.checkerName == 'null' ? '' : widget.reportRecord.checkerName), onClickDisposal: (DisposalModel model) {
                              print(model);
                              if (!checkDisposalInfo(model)) return;

                              widget.reportRecord.checkWay = model.method;
                              widget.reportRecord.checkTime = model.date;
                              widget.reportRecord.checkerName = model.disposer;

                              uploadDisposalInfo();
                            }),
                          )
                        ],
                      )
                    : Container()
              ]),
            ),
            floatingActionButton: _isShowSaveAndUploadBtn
                ? FloatingActionButton(
                    heroTag: 'report_btn',
                    onPressed: () {
                      _initReportId().then((_) {
                        _uploadReportRecord();
                      });
                    },
                    tooltip: '提交',
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Icon(Icons.file_upload), Text("提交", style: TextStyle(fontSize: 10))]))
                : null));
  }

  /// custom textfield
  Widget buildTextField(TextEditingController controller, FocusNode focusNode, int type) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        alignment: Alignment.center,
        height: type == 1 ? 50 : 100,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(ColorConfig.borderColor), width: 0.5), borderRadius: BorderRadius.circular(3)),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          // 最大长度，设置此项会让TextField右下角有一个输入数量的统计字符串
          maxLength: type == 1 ? null : 140,
          // 最大行数
          maxLines: type == 1 ? 1 : 3,
          // 是否自动更正
          autocorrect: true,
          // 是否自动对焦
          autofocus: false,
          textAlignVertical: type == 1 ? TextAlignVertical.center : TextAlignVertical.top,
          //输入文本的样式
          style: TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.contentTextSize),
          decoration: InputDecoration.collapsed(hintText: ''),
          enabled: true,
          // inputFormatters: [
          //   WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[\u4e00-\u9fa5]|[0-9]")), //只能输入汉字或者字母或数字
          //   LengthLimitingTextInputFormatter(200), //最大长度
          // ]
        ));
  }

  /// 构建Image和删除按钮的组合
  Widget _buildImageContainer(int index) {
    /// 缩略图
    MediaType mediaType = _mediaModels[index].type;
    File thumnailFile = _mediaModels[index].thumbnailFile;

    // // 图片
    // String filePath = file.path;
    // String suffix = filePath.substring(filePath.lastIndexOf(".") + 1);
    // if (suffix == "mp4") {
    //   file = videoMap[index];
    // }
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) {
            return MaxHomePage(_mediaModels, index);
          }));
        },
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: const Color(ColorConfig.borderColor), width: 0.5),
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
                image: DecorationImage(image: (thumnailFile == null) ? ExactAssetImage('images/no_video.png') : FileImage(thumnailFile), fit: BoxFit.cover)),
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
  void _showAlertDialog(BuildContext context) {
    showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(title: Text('选择'), children: <Widget>[
            SimpleDialogOption(
              child: Text('拍摄', style: TextStyle(fontSize: 16.0)),
              onPressed: () async {
                Navigator.of(context).pop(); // 提示框出栈
                final mediaPath = await Navigator.of(context).pushNamed(TAKE_PHOTO_AND_VIDEO);
                _addMedia(mediaPath);
              },
            ),
            SimpleDialogOption(
                child: Text('从相册中选择', style: TextStyle(fontSize: 16.0)),
                onPressed: () async {
                  Navigator.of(context).pop(); // 提示框出栈
                  File image = await ImagePicker.pickImage(source: ImageSource.gallery);
                  _addMedia(image.path, type: MediaType.MediaImage);
                }),
            SimpleDialogOption(
                child: Text('从视频中选择', style: TextStyle(fontSize: 16.0)),
                onPressed: () async {
                  Navigator.of(context).pop(); // 提示框出栈
                  File video = await ImagePicker.pickVideo(source: ImageSource.gallery);
                  if (video.lengthSync() >= 10 * 1024 * 1024)
                    CommonUtils.showTextToast('选择的视频大小超过10M，请重新选择');
                  else
                    _addMedia(video.path, type: MediaType.MediaVideo);
                })
          ]);
        });
  }

  // 保存异常上报记录
  _saveReportRecord(bool isFromUpload, String imagesUrl) async {
    if (_locationController.text == "") {
      CommonUtils.showTextToast("请输入位置");
      return;
    }

    // 将异常上报记录插入"异常上报记录表"
    String _images = "";
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String documentsPath = documentsDirectory.path; // 应用文档目录
    /**
     * 该记录的图片存储目录
     * images/0——办公室
     * images/1——设备科
     * images/2——保卫科
     * images/3——异常上报
     */
    String recordImgPath = "$documentsPath/images/3/$_recordId";
    String simpleRecordImgPath = "/images/3/$_recordId"; // 不带前缀的图片路径
    if (_mediaModels.length != 0) {
      for (var i = 0; i < _mediaModels.length; i++) {
        MediaModel media = _mediaModels[i];
        // 将图片保存到"该记录的图片存储目录"
        String imgName = FileUtils.getFileName(media.mediafile.path);
        var isExists = await FileUtils.isExistsFile("$recordImgPath/$imgName");
        if (!isExists) {
          await FileUtils.copyFile(media.mediafile.path, "$recordImgPath/$imgName");
        }
        print("图片$i存储结果：\n存储位置：$recordImgPath\n图片路径：$recordImgPath/$imgName");
        // 拼接存储到数据库中的图片字符串
        if (i == 0) {
          _images = "$simpleRecordImgPath/$imgName";
        } else {
          _images = _images + "," + "$simpleRecordImgPath/$imgName";
        }
        // 将图片文件更新为"该记录的图片存储目录"中的图片文件（之前为相册中的文件）
        // _imageFiles[i] = File("$recordImgPath/$imgName");
      }
    }

    TabReportRecordModel _reportRecordModel = TabReportRecordModel();
    _reportRecordModel.id = _recordId;
    _reportRecordModel.inspectionId = _inspectionId;
    _reportRecordModel.location = stringToBase64.encode(_locationController.text);
    _reportRecordModel.explain = stringToBase64.encode(_descriptionController.text);
    _reportRecordModel.imagesPath = _images;
    _reportRecordModel.time = DateUtils.getCurrentTime();
    if (isFromUpload) {
      _reportRecordModel.imagesUrl = imagesUrl;
      _reportRecordModel.isUpload = 1;
      setState(() {
        _isShowSaveAndUploadBtn = false;
        // widget.reportRecord = _reportRecordModel;
      });
    }
    TabReportRecordManager tabReportRecordManager = TabReportRecordManager();
    await tabReportRecordManager.insert(_reportRecordModel);

    String tip = widget.isFromRecord ? '保存成功' : '保存成功, 请至异常记录中上传';
    if (!isFromUpload) {
      CommonUtils.showAlertDialog(context, '温馨提示', tip, () {});
    }

    /**
     * 重置状态
     */
    if (!widget.isFromRecord) {
      _resetData();
    }
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
    CommonUtils.showLoadingDialog(context, '努力上传中...', SpinKitType.SpinKit_Circle);

    Map czsj = {
      "ID": widget.reportRecord.id,
      "CJSJID": widget.reportRecord.id, //异常数据ID
      "CZSJ": widget.reportRecord.checkTime, //处置时间
      "CZFF": widget.reportRecord.checkWay, //处置方式
      "CZR": widget.reportRecord.checkerName //处置人
    };
    print(json.encode(czsj));
    DataResult uploadDataResult = await NetUtils.uploadToNet(Address.saveYccz(), {'czsj': json.encode(czsj)});
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
    widget.reportRecord.isChecked = 1;
    await TabReportRecordManager.updateDisposalStateWithRecordId(widget.reportRecord);

    CommonUtils.showAlertDialog(context, '温馨提示', "处置数据上传成功", () {}).then((_) {
      Navigator.pop(context, '1'); // 返回已处置
    });
  }

  // 上传异常上报记录
  _uploadReportRecord() async {
    if (_locationController.text == "") {
      CommonUtils.showTextToast("请输入位置");
      return;
    }

    CommonUtils.showLoadingDialog(context, '努力上传中...', SpinKitType.SpinKit_Circle);

    /**
     * 上传图片（支持多张图片）
     */
    String _picids = " "; // 图片guid拼接
    String _picpaths = ""; // 图片网络地址拼接（用于第三步中的数据库存储）
    if (_mediaModels.length != 0) {
      DataResult dataResult = await NetUtils.uploadImg(Address.uploadImg('12'), _mediaModels);
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
        Navigator.pop(context, '0'); // hide loading dialog
        CommonUtils.showAlertDialog(context, '温馨提示', dataResult.description, () {});
        return;
      }
    }
    print('picids:' + _picids);

    /**
     * 保存异常上报数据
     */
    // var userInfo = await LocalStorage.get(Config.USER_INFO_KEY);
    // Map<String, dynamic> responseDictionary = json.decode(userInfo);
    // String inspectorId = responseDictionary["ID"];
    // 异常记录toJson
    TabInspectionModel _tabInspectionModel = TabInspectionModel();
    _tabInspectionModel.id = _inspectionId;
    _tabInspectionModel.inspectorId = _userId;
    _tabInspectionModel.inspectionType = 3;
    _tabInspectionModel.inspectionState = 0;
    String _dataxcjl = json.encode(_tabInspectionModel.toJson(_userName));
    print('dataxcjl：' + _dataxcjl);

    // 巡查内容toJson
    TabReportRecordModel _tabReportRecordModel = TabReportRecordModel();
    _tabReportRecordModel.id = _recordId;
    _tabReportRecordModel.inspectionId = _inspectionId;
    _tabReportRecordModel.location = _locationController.text;
    _tabReportRecordModel.explain = _descriptionController.text;
    String _dataycjl = json.encode(_tabReportRecordModel.toJson(_userId, _userName));
    print('dataycjl：' + _dataycjl);

    // 上传到服务
    DataResult dataResult = await NetUtils.uploadToNet(Address.saveYCJL(), {'xcjl': _dataxcjl, 'ycjl': _dataycjl, 'picids': _picids});
    Navigator.pop(context); // hide loading dialog

    if (dataResult.result) {
      /*
     * 数据库存储（修改数据库中 图片网络地址、是否上传、上传时间）
     */
      await _saveReportRecord(true, _picpaths);
      if (!widget.isFromRecord) {
        _resetData();
      } else {
        CommonUtils.showAlertDialog(context, '温馨提示', "上传成功", () {}).then((_) {
          Navigator.pop(context, '0');
        });
      }
    } else {
      CommonUtils.showTextToast(dataResult.description);
    }

    // var uploadReportRecordURL = Address.saveYCJL();
    // var uploadReportRecordResponse = await NetUtils.post(uploadReportRecordURL,
    //     {'xcjl': _xcjl, 'ycjl': _ycjl, 'picids': _picids});
    // print("saveYCJL返回值:" + uploadReportRecordResponse);
    // if (json.decode(uploadReportRecordResponse)['IsSuccess'] == false) {
    //   Navigator.pop(context); // hide loading dialog
    //   CommonUtils.showAlertDialog(context, '温馨提示', "数据上传失败，请稍后重试", () {});
    //   return;
    // } else {
    //   Navigator.pop(context); // hide loading dialog
    //   CommonUtils.showAlertDialog(context, '温馨提示', "数据上传成功", () {});
    // }
    // /**
    //  * 数据库存储
    //  */
    // await _saveReportRecord(false, _picpaths);
  }

  // 重置状态
  _resetData() {
    // 生成新巡查内容id
    _recordId = Uuid().v1();
    // 清空文本框
    _locationController.text = "";
    _descriptionController.text = "";
    // 重置变量
    setState(() {
      _isShowSaveAndUploadBtn = true;
      _mediaModels.clear();
    });

    // 让文本框失去焦点（否则没有提示）
    _locationFocusNode.unfocus();
    _descriptionFocusNode.unfocus();
    CommonUtils.showTextToast("数据上传成功");
  }
}
