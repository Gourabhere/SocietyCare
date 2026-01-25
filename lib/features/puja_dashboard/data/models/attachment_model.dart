import '../../domain/entities/attachment.dart';

class PujaAttachmentModel {
  final String id;
  final String transactionId;
  final String filePath;
  final String? fileType;
  final DateTime uploadedAt;

  const PujaAttachmentModel({
    required this.id,
    required this.transactionId,
    required this.filePath,
    required this.uploadedAt,
    this.fileType,
  });

  factory PujaAttachmentModel.fromJson(Map<String, dynamic> json) {
    return PujaAttachmentModel(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      filePath: json['file_path'] as String,
      fileType: json['file_type'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'file_path': filePath,
      'file_type': fileType,
    };
  }

  PujaAttachment toEntity() {
    return PujaAttachment(
      id: id,
      transactionId: transactionId,
      filePath: filePath,
      fileType: fileType,
      uploadedAt: uploadedAt,
    );
  }
}
