import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FileHelper {
  // Private constructor to prevent external instantiation.
  FileHelper._();

  // The single instance of the class.
  static final FileHelper _instance = FileHelper._();

  // Factory constructor to provide access to the singleton instance.
  factory FileHelper() {
    return _instance;
  }

  Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["xlsx"]);

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      return null;
    }
  }
}
