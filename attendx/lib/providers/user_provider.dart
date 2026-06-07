import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class UserData {
  final String id;
  final String name;

  UserData({required this.id, required this.name});
}

class UserNotifier extends Notifier<UserData> {
  @override
  UserData build() {
    _loadUserData();
    return UserData(id: "", name: "Loading...");
  }

  Future<void> _loadUserData() async {
    final storage = ref.read(secureStorageProvider);
    final name = await storage.read(key: 'EmployeeName');
    final id = await storage.read(key: 'employeeId');
    state = UserData(id: id ?? "", name: name ?? "Employee");
  }

  void updateName(String name) {
    state = UserData(id: state.id, name: name);
  }
}

final userProvider = NotifierProvider<UserNotifier, UserData>(() {
  return UserNotifier();
});
