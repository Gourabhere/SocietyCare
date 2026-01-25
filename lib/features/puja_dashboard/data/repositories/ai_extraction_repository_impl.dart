import '../datasources/ai_extraction_datasource.dart';
import '../../../../utils/text_extraction_utils.dart';
import '../../domain/entities/ai_extraction.dart';
import '../../domain/repositories/ai_extraction_repository.dart';

class AiExtractionRepositoryImpl implements AiExtractionRepository {
  final AiExtractionDatasource _datasource;

  AiExtractionRepositoryImpl(this._datasource);

  @override
  Future<AiExtractionResult> extractFromImage({
    required List<int> bytes,
    required String mimeType,
  }) async {
    final extractedText = await _datasource.extractText(bytes: bytes, mimeType: mimeType);
    return TextExtractionUtils.parseWhatsAppText(extractedText);
  }
}
