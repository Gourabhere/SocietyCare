import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportUtilsImpl {
  static Future<void> saveAndShareBytes({
    required String filename,
    required List<int> bytes,
    required String mimeType,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path)],
      mimeTypes: [mimeType],
      subject: filename,
    );
  }
}
