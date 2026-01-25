import 'dart:typed_data';

import 'package:universal_html/html.dart' as html;

class ExportUtilsImpl {
  static Future<void> saveAndShareBytes({
    required String filename,
    required List<int> bytes,
    required String mimeType,
  }) async {
    final blob = html.Blob([Uint8List.fromList(bytes)], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = filename
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}
