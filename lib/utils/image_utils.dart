import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class ImageUtils {
  /// Compresses image, prints size before & after, returns File
  static Future<File> compressImage(File file) async {
    // 📏 Size before compression
    final int beforeBytes = await file.length();
    final double beforeKB = beforeBytes / 1024;

    debugPrint('📸 Original image size: ${beforeKB.toStringAsFixed(2)} KB');

    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.webp';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      // 🔽 QUALITY (0–100)
      quality: 60,

      // 🔽 RESOLUTION (max bounds)
      minWidth: 1080,
      minHeight: 1080,

      // Optional but recommended
      format: CompressFormat.webp,
    );

    if (result == null) {
      debugPrint('❌ Compression failed, using original image');
      return file;
    }

    final compressedFile = File(result.path);

    // 📉 Size after compression
    final int afterBytes = await compressedFile.length();
    final double afterKB = afterBytes / 1024;

    debugPrint('🗜️ Compressed image size: ${afterKB.toStringAsFixed(2)} KB');

    // 📊 Percentage saved
    final double saved = ((beforeBytes - afterBytes) / beforeBytes) * 100;

    debugPrint('✅ Size reduced by: ${saved.toStringAsFixed(1)}%');

    return compressedFile;
  }
}
