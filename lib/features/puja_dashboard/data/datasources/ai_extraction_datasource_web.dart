import 'ai_extraction_datasource_base.dart';

class AiExtractionDatasourceImpl implements AiExtractionDatasource {
  @override
  Future<String> extractText({
    required List<int> bytes,
    required String mimeType,
  }) async {
    return '';
  }
}
