import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

enum OcrError {
  none,
  noTextFound,
  cameraUnavailable,
  galleryUnavailable,
  processingFailed,
  fileNotFound,
}

class OcrResult {
  const OcrResult({required this.text, required this.error});
  final String? text;
  final OcrError error;

  bool get isSuccess => error == OcrError.none && text != null && text!.isNotEmpty;
  bool get hasText => text != null && text!.isNotEmpty;

  String get errorMessage {
    switch (error) {
      case OcrError.none:
        return '';
      case OcrError.noTextFound:
        return 'No text found in image. Try with clearer text.';
      case OcrError.cameraUnavailable:
        return 'Camera unavailable. Check permissions.';
      case OcrError.galleryUnavailable:
        return 'Could not open gallery. Try again.';
      case OcrError.processingFailed:
        return 'OCR processing failed. Try a different image.';
      case OcrError.fileNotFound:
        return 'Image file not found.';
    }
  }
}

class OcrService {
  OcrService._();

  static final OcrService instance = OcrService._();

  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<OcrResult> extractTextFromCamera() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image == null) {
        return const OcrResult(text: null, error: OcrError.cameraUnavailable);
      }
      return await _processImage(File(image.path));
    } catch (e) {
      if (e.toString().contains('permission') || e.toString().contains('Camera')) {
        return const OcrResult(text: null, error: OcrError.cameraUnavailable);
      }
      return const OcrResult(text: null, error: OcrError.cameraUnavailable);
    }
  }

  Future<OcrResult> extractTextFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) {
        return const OcrResult(text: null, error: OcrError.galleryUnavailable);
      }
      return await _processImage(File(image.path));
    } catch (e) {
      return const OcrResult(text: null, error: OcrError.galleryUnavailable);
    }
  }

  Future<OcrResult> extractTextFromFile(File file) async {
    return _processImage(file);
  }

  Future<OcrResult> _processImage(File file) async {
    try {
      if (!file.existsSync()) {
        return const OcrResult(text: null, error: OcrError.fileNotFound);
      }

      final inputImage = InputImage.fromFile(file);
      final recognized = await _textRecognizer.processImage(inputImage);
      
      if (recognized.text.trim().isEmpty) {
        return const OcrResult(text: null, error: OcrError.noTextFound);
      }

      return OcrResult(text: recognized.text, error: OcrError.none);
    } catch (e) {
      debugPrint('OCR processing error: $e');
      return const OcrResult(text: null, error: OcrError.processingFailed);
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}