import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

const Set<String> allowedImageContentTypes = {
  'image/jpeg',
  'image/png',
};

String? imageContentTypeFor(XFile file) {
  final mimeType = file.mimeType?.toLowerCase();
  if (mimeType != null && allowedImageContentTypes.contains(mimeType)) {
    return mimeType;
  }

  final fileName = _fileNameFor(file).toLowerCase();
  if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  if (fileName.endsWith('.png')) {
    return 'image/png';
  }

  return null;
}

bool isAllowedUploadImage(XFile file) => imageContentTypeFor(file) != null;

Future<MultipartFile> imageMultipartFileFromXFile(XFile file) async {
  final contentType = imageContentTypeFor(file);
  if (contentType == null) {
    throw const FormatException('Only JPG and PNG images are allowed.');
  }

  final fileName = _fileNameFor(file);
  if (kIsWeb) {
    final bytes = await file.readAsBytes();
    return MultipartFile(
      bytes,
      filename: fileName,
      contentType: contentType,
    );
  }

  return MultipartFile(
    file.path,
    filename: fileName,
    contentType: contentType,
  );
}

String _fileNameFor(XFile file) {
  if (file.name.isNotEmpty) return file.name;
  return file.path.split('/').last.split('\\').last;
}
