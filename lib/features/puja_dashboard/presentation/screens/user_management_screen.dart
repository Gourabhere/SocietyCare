import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/puja_strings.dart';
import '../providers/puja_permissions_provider.dart';
import '../providers/user_management_provider.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(pujaIsAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(PujaStrings.users)),
      body: !isAdmin
          ? const Center(
              child: Text(
                PujaStrings.readOnlyHint,
                style: TextStyle(color: AppColors.textGrey),
              ),
            )
          : ref.watch(pujaUsersProvider).when(
              data: (users) {
                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found or access denied by RLS.',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.lightBlue,
                        child: Text(
                          (u.name.isNotEmpty ? u.name : u.email).substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: AppColors.primaryBlue),
                        ),
                      ),
                      title: Text(u.name.isEmpty ? u.email : u.name),
                      subtitle: Text(u.email),
                      trailing: DropdownButton<String>(
                        value: u.role,
                        items: const [
                          DropdownMenuItem(value: 'staff', child: Text('Viewer')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (v) async {
                          if (v == null) return;
                          try {
                            await ref.read(pujaUserActionsProvider).updateRole(userId: u.id, role: v);
                            ref.invalidate(pujaUsersProvider);
                            Fluttertoast.showToast(msg: 'Updated');
                          } catch (e) {
                            Fluttertoast.showToast(msg: 'Failed: $e');
                          }
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load users: $e',
                    style: const TextStyle(color: AppColors.errorRed),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
    );
  }
}
