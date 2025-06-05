import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

enum FileSourceOption { camera, upload }

class FileService {
  FileService._privateConstructor();

  static final FileService _instance = FileService._privateConstructor();

  factory FileService() {
    return _instance;
  }

  final ImagePicker _imagePicker = ImagePicker();

  static const int maxFileSizeInBytes = 6 * 1024 * 1024; // 2 MB

  Future<File?> pickFile(FileSourceOption source) async {
    try {
      File? file;

      if (source == FileSourceOption.camera) {
        final XFile? pickedImage = await _imagePicker.pickImage(
          source: ImageSource.camera,
        );
        if (pickedImage != null) {
          file = File(pickedImage.path);
        }
      } else if (source == FileSourceOption.upload) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.isNotEmpty) {
          final path = result.files.first.path;
          if (path != null) {
            file = File(path);
          }
        }
      }

      if (file != null) {
        final int size = await file.length();
        if (size > maxFileSizeInBytes) {
          Toast.showError('File is larger than 6 MB');
          return null;
        }
        return file;
      }
    } catch (e) {
      Toast.showError('Error picking file: $e');
    }

    return null;
  }
}
