import 'ai_extraction_datasource_base.dart';
import 'ai_extraction_datasource_io.dart'
    if (dart.library.html) 'ai_extraction_datasource_web.dart';

export 'ai_extraction_datasource_base.dart';

class AiExtractionDatasourceFactory {
  static AiExtractionDatasource create() => AiExtractionDatasourceImpl();
}
