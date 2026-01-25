import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/puja_strings.dart';
import '../providers/ai_extraction_provider.dart';
import 'ai_preview_confirmation_screen.dart';

class AiScreenshotUploadScreen extends ConsumerStatefulWidget {
  const AiScreenshotUploadScreen({super.key});

  @override
  ConsumerState<AiScreenshotUploadScreen> createState() => _AiScreenshotUploadScreenState();
}

class _AiScreenshotUploadScreenState extends ConsumerState<AiScreenshotUploadScreen> {
  XFile? _image;
  List<int>? _previewBytes;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiExtractionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(PujaStrings.aiScan)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Upload a WhatsApp screenshot and we\'ll try to extract amount, name, date and category.',
            style: TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_previewBytes == null)
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 56, color: AppColors.textLight),
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        Uint8List.fromList(_previewBytes!),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: state.isLoading ? null : () => _pick(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Gallery'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: state.isLoading ? null : () => _pick(ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Camera'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: (_image == null || state.isLoading) ? null : _extract,
                    icon: state.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(state.isLoading ? 'Extracting...' : 'Extract'),
                  ),
                ],
              ),
            ),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(
              'Failed: ${state.error}',
              style: const TextStyle(color: AppColors.errorRed),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: source, imageQuality: 90);
    if (img == null) return;
    final bytes = await img.readAsBytes();
    setState(() {
      _image = img;
      _previewBytes = bytes;
    });
    ref.read(aiExtractionProvider.notifier).clear();
  }

  Future<void> _extract() async {
    try {
      final bytes = await _image!.readAsBytes();
      final mime = _guessMime(_image!.name);
      await ref.read(aiExtractionProvider.notifier).extract(bytes: bytes, mimeType: mime);
      final state = ref.read(aiExtractionProvider);
      if (state.result == null) return;
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AiPreviewConfirmationScreen(
            imageBytes: bytes,
            mimeType: mime,
            result: state.result!,
            originalFilename: _image!.name,
          ),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Extraction failed: $e');
    }
  }

  String _guessMime(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream';
  }
}
