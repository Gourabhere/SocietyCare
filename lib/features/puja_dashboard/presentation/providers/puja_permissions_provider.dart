import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/user_model.dart';
import '../../../../providers/auth_provider.dart';

final pujaIsAdminProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.maybeWhen(
    data: (u) => u?.role == UserRole.admin,
    orElse: () => false,
  );
});
