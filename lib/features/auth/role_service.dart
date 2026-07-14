import 'package:firebase_auth/firebase_auth.dart';

enum AppRole { customer, staff, owner }

class RoleService {
  const RoleService();

  Future<AppRole> currentRole({bool forceRefresh = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return AppRole.customer;
    final token = await user.getIdTokenResult(forceRefresh);
    final role = token.claims?['role']?.toString();
    if (role == 'owner') return AppRole.owner;
    if (role == 'staff') return AppRole.staff;
    return AppRole.customer;
  }

  Future<bool> get canManageBookings async {
    final role = await currentRole();
    return role == AppRole.owner || role == AppRole.staff;
  }
}
