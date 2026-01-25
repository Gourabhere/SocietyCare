import 'export_utils_io.dart' if (dart.library.html) 'export_utils_web.dart';

abstract class ExportUtils {
  static Future<void> saveAndShareBytes({
    required String filename,
    required List<int> bytes,
    required String mimeType,
  }) {
    return ExportUtilsImpl.saveAndShareBytes(
      filename: filename,
      bytes: bytes,
      mimeType: mimeType,
    );
  }
}
