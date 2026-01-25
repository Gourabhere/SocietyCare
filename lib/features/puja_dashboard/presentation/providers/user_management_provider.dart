import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/puja_remote_datasource.dart';
import 'puja_dependencies.dart';

class PujaUserRow {
  final String id;
  final String email;
  final String role;
  final String name;

  const PujaUserRow({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
  });
}

final pujaUsersProvider = FutureProvider.autoDispose<List<PujaUserRow>>((ref) async {
  final remote = ref.watch(pujaRemoteDatasourceProvider);
  final rows = await remote.listUsers();
  return rows
      .map(
        (r) => PujaUserRow(
          id: r['id'] as String,
          email: (r['email'] as String?) ?? '',
          role: (r['role'] as String?) ?? 'staff',
          name: (r['name'] as String?) ?? '',
        ),
      )
      .toList();
});

final pujaUserActionsProvider = Provider<PujaUserActions>((ref) {
  final remote = ref.watch(pujaRemoteDatasourceProvider);
  return PujaUserActions(remote);
});

class PujaUserActions {
  final PujaRemoteDatasource _remote;

  PujaUserActions(this._remote);

  Future<void> updateRole({
    required String userId,
    required String role,
  }) async {
    await _remote.updateUserRole(userId: userId, role: role);
  }
}
