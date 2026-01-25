import '../entities/ai_extraction.dart';

abstract class AiExtractionRepository {
  Future<AiExtractionResult> extractFromImage({
    required List<int> bytes,
    required String mimeType,
  });
}
