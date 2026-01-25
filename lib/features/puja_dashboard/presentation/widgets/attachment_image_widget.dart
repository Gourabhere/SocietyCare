import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class AttachmentImageWidget extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AttachmentImageWidget({
    super.key,
    required this.imageUrl,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              placeholder: (context, _) => Container(
                width: 120,
                height: 120,
                color: AppColors.cardBackground,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, _, __) => Container(
                width: 120,
                height: 120,
                color: AppColors.cardBackground,
                child: const Icon(Icons.broken_image, color: AppColors.textGrey),
              ),
            ),
          ),
        ),
        if (onDelete != null)
          Positioned(
            right: 6,
            top: 6,
            child: InkWell(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
