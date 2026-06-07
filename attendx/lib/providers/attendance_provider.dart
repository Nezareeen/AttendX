import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendx/providers/user_provider.dart';
import 'package:attendx/services/database_service.dart';

final attendanceProvider = FutureProvider<int>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  final userData = ref.watch(userProvider);

  if (userData.id.isEmpty) {
    return 0;
  }

  return await databaseService.getAttendanceCount(userData.id);
});
