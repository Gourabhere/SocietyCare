import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/attachment.dart';
import 'puja_dependencies.dart';

final pujaAttachmentsProvider = StreamProvider.family<List<PujaAttachment>, String>((ref, transactionId) {
  final repo = ref.watch(pujaRepositoryProvider);
  return repo.watchAttachments(transactionId);
});

final pujaAttachmentUrlProvider = Provider.family<String, String>((ref, filePath) {
  final remote = ref.watch(pujaRemoteDatasourceProvider);
  return remote.getAttachmentPublicUrl(filePath);
});
