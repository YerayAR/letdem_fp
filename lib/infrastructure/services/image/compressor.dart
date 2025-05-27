import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class CompressionError extends Error {
  final String message;

  CompressionError(this.message);

  @override
  String toString() {
    return message;
  }
}

class ImageCompressor {
  static Future<String> compressImageToBase64(File imageFile,
      {int quality = 50}) async {
    try {
      Uint8List imageBytes = await imageFile.readAsBytes();

      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception("Failed to decode image.");
      }

      List<int> compressedBytes = img.encodeJpg(image, quality: quality);

      String base64String = base64Encode(compressedBytes);

      return base64String;
    } catch (e) {
      throw CompressionError("Failed to compress image: $e");
    }
  }
}
