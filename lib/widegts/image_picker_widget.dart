import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/image_utils.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();

  File? originalImage;
  File? compressedImage;

  int? originalSize;
  int? compressedSize;

  bool isLoading = false; // 🔄 loader state

  /// Picks image, compresses it and updates UI
  Future<void> pickAndCompressImage() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => isLoading = true);

    final File original = File(picked.path);
    final File compressed =
        await ImageUtils.compressImage(original);

    setState(() {
      originalImage = original;
      compressedImage = compressed;
      originalSize = original.lengthSync();
      compressedSize = compressed.lengthSync();
      isLoading = false;
    });
  }

  String kb(int bytes) => (bytes / 1024).toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Image preview
        Stack(
          alignment: Alignment.center,
          children: [
            (compressedImage ?? originalImage) != null
                ? Image.file(
                    compressedImage ?? originalImage!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/1stay trans.png',
                    width: 200,
                    height: 200,
                  ),

            /// Loader overlay
            if (isLoading)
              Container(
                width: 200,
                height: 200,
                color: Color.fromARGB(80, 0, 0, 0),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        /// Upload button
        ElevatedButton.icon(
          onPressed: isLoading ? null : pickAndCompressImage,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.upload),
          label: Text(isLoading ? 'Compressing...' : 'Upload Image'),
        ),

        const SizedBox(height: 12),

        /// File size info
        if (originalSize != null && compressedSize != null) ...[
          Text('Original: ${kb(originalSize!)} KB'),
          Text('Compressed: ${kb(compressedSize!)} KB'),
          Text(
            'Saved: ${(100 - (compressedSize! / originalSize! * 100)).toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.green),
          ),
        ],
      ],
    );
  }
}
