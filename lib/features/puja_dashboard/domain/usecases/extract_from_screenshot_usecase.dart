import '../entities/ai_extraction.dart';
import '../repositories/ai_extraction_repository.dart';

class ExtractFromScreenshotUsecase {
  final AiExtractionRepository _repo;

  const ExtractFromScreenshotUsecase(this._repo);

  Future<AiExtractionResult> call({
    required List<int> bytes,
    required String mimeType,
  }) {
    return _repo.extractFromImage(bytes: bytes, mimeType: mimeType);
  }
}
