import 'package:flutter/material.dart';

import '../../utils/navigation.dart';
import '../../utils/ocr_service.dart';
import '../../utils/snackbar.dart';
import '../../widgets/cards/action_card.dart';

class OcrHelpScreen extends StatefulWidget {
  const OcrHelpScreen({super.key});

  @override
  State<OcrHelpScreen> createState() => _OcrHelpScreenState();
}

class _OcrHelpScreenState extends State<OcrHelpScreen> {
  bool _isProcessing = false;
  final OcrService _ocrService = OcrService.instance;

  Future<void> _openCamera() async {
    if (_isProcessing) return;

    try {
      setState(() => _isProcessing = true);
      showSnackBar(context, 'Processing image...');

      final result = await _ocrService.extractTextFromCamera();

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (result.isSuccess) {
        openAddTask(context, extractedText: result.text);
      } else {
        showSnackBar(context, result.errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      showSnackBar(context, 'Camera unavailable. Please try again.');
    }
  }

  Future<void> _openGallery() async {
    if (_isProcessing) return;

    try {
      setState(() => _isProcessing = true);
      showSnackBar(context, 'Processing image...');

      final result = await _ocrService.extractTextFromGallery();

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (result.isSuccess) {
        openAddTask(context, extractedText: result.text);
      } else {
        showSnackBar(context, result.errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      showSnackBar(context, 'Could not open gallery. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Scan Notes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Turn handwritten notes into tasks',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Capture your handwritten notes, whiteboard, or printed documents to automatically extract tasks.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator())
          else ...[
            ActionCard(
              title: 'Capture from Camera',
              subtitle: 'Take a photo of your notes',
              actionLabel: 'Open camera',
              onAction: _openCamera,
            ),
            const SizedBox(height: 12),
            ActionCard(
              title: 'Select from Gallery',
              subtitle: 'Choose an existing photo',
              actionLabel: 'Browse photos',
              onAction: _openGallery,
            ),
          ],
          const SizedBox(height: 32),
          Text('Tips for best results', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildTip(
            Icons.light_mode_outlined,
            'Good lighting',
            'Use bright, even lighting. Avoid shadows.',
          ),
          _buildTip(
            Icons.text_fields,
            'Clear handwriting',
            'Write clearly and neatly for better accuracy.',
          ),
          _buildTip(
            Icons.crop,
            'Crop the image',
            'Focus on the text area. Remove extra background.',
          ),
          _buildTip(
            Icons.contrast,
            'High contrast',
            'Dark text on light background works best.',
          ),
          const SizedBox(height: 24),
          Text(
            'After capturing, review the extracted text and edit any mistakes before adding tasks.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}