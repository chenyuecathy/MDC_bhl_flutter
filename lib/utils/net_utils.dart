import 'dart:async';
import 'dart:io';
import 'dart:convert';

// import 'package:cookie_jar/cookie_jar.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:mdc_bhl/utils/image_utils.dart' as image_utils;

import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/model/media_data.dart';

Map<String, dynamic> optHeader = {
  'accept-language': 'zh-cn',
  'content-type': 'application/json'
};

// enum MediaType {
//   MediaImage,
//   MediaVideo,
//   MediaAudio,
//   MediaUnknown,
// }

// class MediaModel {
//   File mediafile;
//   MediaType type;

//   MediaModel(this.mediafile,this.type);
// }

// init dio object
var dio = new Dio(BaseOptions(connectTimeout: 15000 /*, headers: optHeader*/));

class NetUtils {
  ///判断是否联网
  static Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  static Future get(String url, [Map<String, dynamic> params]) async {
    Response response;
    // String PEM = "XXXXX"; //可以从文件读取

    // ///设置代理 便于本地 charles 抓包
    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (HttpClient client) {
    //   client.findProxy = (uri) {
    //     return "PROXY 30.10.26.193:8888";
    //   };

    //   //校验证书
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) {
    //     if (cert.pem == PEM) {
    //       return true; //证书一致，则允许发送数据
    //     }
    //     return false;
    //   };
    // };

    // Directory documentsDir = await getApplicationDocumentsDirectory();
    // String documentsPath = documentsDir.path; // 获取Document目录路径
    // var dir = new Directory("$documentsPath/cookies");
    // await dir.create(); // 创建cookie目录
    // print('documentPath:${dir.path}');
    // dio.interceptors
    //     .add(CookieManager(PersistCookieJar(dir: dir.path))); // 缓存cookie

    // send request
    if (params != null) {
      response = await dio.get(url, queryParameters: params);
    } else {
      response = await dio.get(url);
    }

    return response.data;
  }

  /// 针对特定response封装的get方法
  static Future getFromNet(String url, [Map<String, dynamic> params]) async {
    print("url:$url");
    print("params:$params");
    try {
      /// 1.判断网络连通性
      bool isConnect = await isConnected();
      if (!isConnect) {
        return DataResult(null, false, description: '设备未联网');
      }

      /// 2.配置URI和参数
      Response response;
      if (params != null) {
        response = await dio.get(url, queryParameters: params);
      } else {
        response = await dio.get(url);
      }
      print("response:$response");

      /// 3.处理response出错
      if (response.statusCode != 200)
        return DataResult(null, false, description: '服务出错，请稍后再试');

      /// 4.解析response，包括成功和失败两种情况
      ///A JsonCodec encodes JSON objects to strings and decodes strings to JSON objects.
      ///https://api.dartlang.org/stable/1.24.3/dart-convert/JsonCodec-class.html
      Map<String, dynamic> mapResponse = json.decode(response.data); // json map

      dynamic isSuccess = mapResponse['IsSuccess'];

      if (isSuccess) {
        dynamic mapResultValue = mapResponse['ResultValue']; // Map<String, dynamic>
        return DataResult(mapResultValue, true, description: '获取数据成功');
      } else {
        return DataResult(null, false, description: mapResponse['ResultDescription'] ?? '未知错误，请稍后再试');
      }
    } on DioError catch (e) {
      String description = dioErrorTipExtract(e);
      return DataResult(null, false, description: description);
    }
  }

  

  static String dioErrorTipExtract(dynamic error) {
    String description = error.message;
    if (error.type == DioErrorType.CONNECT_TIMEOUT) {
      description = '连接超时';
    } else if (error.type == DioErrorType.CANCEL) {
      description = '取消连接';
    } else if (error.type == DioErrorType.RECEIVE_TIMEOUT) {
      description = '接收超时';
    } else if (error.type == DioErrorType.SEND_TIMEOUT) {
      description = '发送超时';
    }
    return description;
  }

  /*  POST */
  static Future post(String url, Map<String, dynamic> params) async {
    var response = await dio.post(url,
        data: params,
        options: new Options( contentType: ContentType.parse("application/x-www-form-urlencoded")));
    return response.data;
  }

  /// POST 普通
  static Future uploadToNet(String url, Map<String, dynamic> params) async {
    try {
      /// 1.判断网络连通性
      bool isConnect = await isConnected();
      if (!isConnect) {
        return DataResult(null, false, description: '设备未联网');
      }

      /// 2.发出POST
      print('post url $url paras$params');
      Response response = await dio.post(url,
          data: params,
          options: new Options( contentType: ContentType.parse("application/x-www-form-urlencoded")));

      /// 3.处理response出错
      if (response.statusCode != 200)
        return DataResult(null, false, description: '服务出错，请稍后再试');

      print(response.data);

      /// 4.解析response，包括成功和失败两种情况
      ///A JsonCodec encodes JSON objects to strings and decodes strings to JSON objects.
      ///https://api.dartlang.org/stable/1.24.3/dart-convert/JsonCodec-class.html
      Map<String, dynamic> mapResponse = json.decode(response.data); // json map

      dynamic isSuccess = mapResponse['IsSuccess'];

      if (isSuccess) {
        return DataResult(null, true, description: '上传数据成功');
      } else {
        return DataResult(null, false, description: mapResponse['ResultDescription'] ?? '未知错误，请稍后再试');
      }
    } catch (e) {
      String description = dioErrorTipExtract(e);

      return DataResult(null, false, description: description);
    }
  }

  /// POST上传头像(单张图片)
  static Future uploadAvator(String url, File imageFile) async {
    try {
      /// 1.判断网络连通性
      bool isConnect = await isConnected();
      if (!isConnect) {
        return DataResult(null, false, description: '设备未联网');
      }

      /// 2.配置Formdata
      String path = imageFile.path;
      String name = path.substring(path.lastIndexOf("/") + 1, path.length);
      List partsOfPath = path.split('.');
      String imgFormat = partsOfPath[partsOfPath.length - 1];
      String imageName = Uuid().v1() + '.$imgFormat';

      /// 压缩图片
      var dir = await path_provider.getTemporaryDirectory();
      var targetPath = dir.absolute.path + '/' + imageName + '.' + imgFormat;
      print('target path = $targetPath');
      var compressImgFile =
          await image_utils.compressAndGetFile(imageFile, targetPath);
      if (compressImgFile == null) {
        compressImgFile = imageFile;
        imageName = name;
      }
      FormData formData =
          FormData.from({'file': UploadFileInfo(compressImgFile, name)});

      /// 3.发出POST
      Response response = await dio.post(url, data: formData);

      /// 4.处理response出错
      if (response.statusCode != 200)
        return DataResult(null, false, description: '服务出错，请稍后再试');

      /// 4.解析response，包括成功和失败两种情况
      ///A JsonCodec encodes JSON objects to strings and decodes strings to JSON objects.
      ///https://api.dartlang.org/stable/1.24.3/dart-convert/JsonCodec-class.html
      Map<String, dynamic> mapResponse = json.decode(response.data); // json map

      dynamic isSuccess = mapResponse['IsSuccess'];

      if (isSuccess) {
        return DataResult(mapResponse['ResultValue'], true, description: '上传图片成功');
      } else {
        return DataResult(null, false,
            description: mapResponse['ResultDescription'] ?? '未知错误，请稍后再试');
      }
    } catch (e) {
      String description = dioErrorTipExtract(e);

      return DataResult(null, false, description: description);
    }
  }

  /// 上传图片（支持多张图片）
  static Future uploadImg(String url, List<MediaModel> imgfileList) async {
    try {
      /// 1.判断网络连通性
      bool isConnect = await isConnected();
      if (!isConnect) {
        return DataResult(null, false, description: '设备未联网');
      }

      /// 2.配置Formdata
      List uploadFileInfoList = [];
      // List imageFormats = ['png','jpg','jpeg','gif','bmp','webp'];
      for (MediaModel media in imgfileList) {
        String path = media.mediafile.path;
        String name = path.substring(path.lastIndexOf("/") + 1, path.length);

        print('path = $path  name = $name');
        List partsOfPath = path.split('.');
        String imgFormat = partsOfPath[partsOfPath.length - 1];
        String imageName = Uuid().v1() + '.$imgFormat';
        if (media.type == MediaType.MediaImage) {
          /// 压缩图片
          var dir = await path_provider.getTemporaryDirectory();
          var targetPath = dir.absolute.path + '/' + imageName + '.' + imgFormat;
          print('target path = $targetPath');
          var compressImgFile = await image_utils.compressAndGetFile(media.mediafile, targetPath);
          if (compressImgFile == null) {
            compressImgFile = media.mediafile;
            imageName = name;
          }

          uploadFileInfoList.add(UploadFileInfo(compressImgFile, imageName));
        } else {
          uploadFileInfoList.add(UploadFileInfo(media.mediafile, name));
        }
      }
      print('post url = $url');
      FormData formData = new FormData.from({"files": uploadFileInfoList});
      Response response = await dio.post(url, data: formData);
      if (response.statusCode != 200)
        return DataResult(null, false, description: '服务出错，请稍后再试');

      /// 4.解析response，包括成功和失败两种情况
      ///A JsonCodec encodes JSON objects to strings and decodes strings to JSON objects.
      ///https://api.dartlang.org/stable/1.24.3/dart-convert/JsonCodec-class.html
      Map<String, dynamic> mapResponse = json.decode(response.data); // json map

      dynamic isSuccess = mapResponse['IsSuccess'];
      if (isSuccess) {
        return DataResult(mapResponse['ResultValue'], true,
            description: '上传图片成功');
      } else {
        return DataResult(null, false,
            description: mapResponse['ResultDescription'] ?? '未知错误，请稍后再试');
      }
    } catch (e) {
      String description = dioErrorTipExtract(e);

      return DataResult(null, false, description: description);
    }
  }
}
