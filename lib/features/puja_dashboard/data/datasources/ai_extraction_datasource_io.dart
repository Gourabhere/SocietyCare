import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'ai_extraction_datasource_base.dart';

class AiExtractionDatasourceImpl implements AiExtractionDatasource {
  @override
  Future<String> extractText({
    required List<int> bytes,
    required String mimeType,
  }) async {
    final dir = await getTemporaryDirectory();
    final ext = mimeType.contains('png')
        ? 'png'
        : (mimeType.contains('jpeg') || mimeType.contains('jpg'))
            ? 'jpg'
            : 'img';
    final path = '${dir.path}/puja_ai_${const Uuid().v4()}.$ext';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    final input = InputImage.fromFilePath(file.path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognized = await recognizer.processImage(input);
      return recognized.text;
    } finally {
      await recognizer.close();
      try {
        await file.delete();
      } catch (_) {}
    }
  }
}
