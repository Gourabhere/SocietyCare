class PujaAttachment {
  final String id;
  final String transactionId;
  final String filePath;
  final String? fileType;
  final DateTime uploadedAt;

  const PujaAttachment({
    required this.id,
    required this.transactionId,
    required this.filePath,
    required this.uploadedAt,
    this.fileType,
  });
}
