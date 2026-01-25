abstract class AiExtractionDatasource {
  Future<String> extractText({
    required List<int> bytes,
    required String mimeType,
  });
}
