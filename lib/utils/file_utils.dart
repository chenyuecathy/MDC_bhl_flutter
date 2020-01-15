import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  // 获取文件名
  static getFileName(String path) {
    return path.substring(path.lastIndexOf("/") + 1);
  }

  // 创建文件夹
  static createDirectory(String directoryPath) async {
    var directory = await new Directory(directoryPath).create(recursive: true);
    return directory.path;
  }

  // 判断文件是否存在
  static isExistsFile(String path) async {
    File file = File(path);
    if (await file.exists()) {
      return true;
    } else {
      return false;
    }
  }

  // 拷贝文件
  static copyFile(String oldPath, String newPath) async {
    // 判断被拷贝的文件是否存在
    if (await isExistsFile(oldPath)) {
      // 创建新文件目录
      String newDirectoryPath = newPath.substring(0, newPath.lastIndexOf("/"));
      await createDirectory(newDirectoryPath);
      // 拷贝文件
      File file = File(oldPath);
      await file.copy(newPath);
    }
  }

  static getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory(); // 会变化？？？
    return '${documentsDirectory.path}/mdc_bhl.db'; //join(documentsDirectory.path,'mdc_bhl.db');
  }

  static getDocumentPath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return documentsDirectory.path;
  }

  static getTempDirectoryPath() async {
    Directory documentsDirectory = await getTempDirectoryPath(); // 会变化？？？？？？
    return documentsDirectory.path;
  }

  static Future getLocalFile() async {
  // 获取应用目录
  Directory dir =
      new Directory((await getApplicationDocumentsDirectory()).path + "/temImage");
  if (!await dir.exists()) {
    dir.createSync();
  }
  return new File('${dir.absolute.path}/screenshot_${DateTime.now()}.png');
}
}
