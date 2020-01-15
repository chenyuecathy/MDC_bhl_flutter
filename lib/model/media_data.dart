import 'dart:io';

class MediaModel {
  final File mediafile;
  final MediaType type;
  final File thumbnailFile;   // 缩略图

  MediaModel(this.mediafile, this.type,{this.thumbnailFile});
}

/// The type of the retrieved data in a [LostDataResponse].
enum MediaType {
  MediaImage,
  MediaVideo,
  MediaAudio,
  MediaUnknown,
}
