import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class UserData {
  final String id;
  final String name;
  final String role;
  final String designation;

  UserData({
    required this.id,
    required this.name,
    required this.role,
    required this.designation,
  });
}

class UserNotifier extends Notifier<UserData> {
  @override
  UserData build() {
    _loadUserData();
    return UserData(id: "", name: "Loading...", role: "", designation: "");
  }

  Future<void> _loadUserData() async {
    final storage = ref.read(secureStorageProvider);
    final name = await storage.read(key: 'EmployeeName');
    final id = await storage.read(key: 'employeeId');
    final role = await storage.read(key: 'role');
    final designation = await storage.read(key: 'designation');
    state = UserData(
      id: id ?? "",
      name: name ?? "Employee",
      role: role ?? "User",
      designation: designation ?? "Employee",
    );
  }

  void updateName(String name) {
    state = UserData(
      id: state.id,
      name: name,
      role: state.role,
      designation: state.designation,
    );
  }

  void clear() {
    state = UserData(id: "", name: "", role: "", designation: "");
  }
}

final userProvider = NotifierProvider<UserNotifier, UserData>(() {
  return UserNotifier();
});
